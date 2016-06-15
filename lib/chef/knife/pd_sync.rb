#
# Author:: Tim Heckman (<ops@pagerduty.com>)
# Copyright:: Copyright (c) 2016 PagerDuty, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'berkshelf'
require 'chef/knife'

class Chef
  class Knife
    class PdSync < Knife

      attr_reader :altered_cookbooks

      banner 'knife pd sync [--restore --why-run]'

      deps do
        require 'uri'
        require 'socket'
        require 'timeout'
        require 'chef/cookbook_version'
        require 'chef/data_bag_item'
        require 'chef/data_bag'
        require 'chef/knife/cookbook_bulk_delete'
        require 'chef/knife/data_bag_create'
        require 'chef/knife/data_bag_delete'
        require 'chef/knife/data_bag_from_file'
        require 'chef/knife/environment_from_file'
        require 'chef/knife/role_from_file'
        require 'chef/knife/cookbook_upload'
        require 'berkshelf'
        require 'berkshelf/berksfile'
        require 'mixlib/shellout'

        require 'pagerduty/chef_server/synclock'
        require 'pagerduty/chef_server/sync'

        Chef::Knife::CookbookUpload.load_deps
        Chef::Knife::CookbookBulkDelete.load_deps
        Chef::Knife::DataBagCreate.load_deps
        Chef::Knife::DataBagDelete.load_deps
        Chef::Knife::DataBagFromFile.load_deps
        Chef::Knife::EnvironmentFromFile.load_deps
        Chef::Knife::RoleFromFile.load_deps
      end

      option :restore,
        short:        '-r',
        long:         '--restore',
        description:  'Upload all cookbooks regardless of whether checksums have changed',
        boolean:      true,
        default:      false

      option :why_run,
        short:        '-W',
        long:         '--why-run',
        description:  'Show what operations will be made, without actually performing them (does not work with --restore)',
        boolean:      true,
        default:      false

      def run
        @altered_cookbooks = nil
        if config[:restore]
          ui.warn 'pd sync will delete and reupload all cookbooks!'
          plugin = Chef::Knife::CookbookBulkDelete.new
          plugin.name_args = Array('.')
          plugin.config[:yes] = true
          plugin.config[:purge] = true
          converge_by "delete all existing cookbooks" do
            plugin.run
          end
        end
        lockfile = '/tmp/restore_chef.lock'
        user = Chef::Config[:node_name] || 'unknown'
        converge_by 'perform pre-syn checks' do
          preflight_checks
        end
        lock = PagerDuty::ChefServer::SyncLock.new(
            lockfile, chef_server, localhost, user, local_branch
          )
        converge_by 'acquire lock' do
          lock.lock
        end
        sync = PagerDuty::ChefServer::Sync.new(
          vendor_dir: vendor_dir,
          why_run: config[:why_run]
          )
        begin
          @altered_cookbooks = sync.run
          update_commit
        rescue StandardError => e
          ui.warn(e.message)
          ui.warn(e.backtrace)
        ensure
          converge_by 'release lock' do
            lock.unlock
          end
        end
      end

      def preflight_checks
        vdir = File.join(Dir.pwd, 'vendor')
        if vendor_dir != vdir
          ui.confirm("vendor directory (#{vendor_dir}) is different than standard one(#{vdir}), continue?")
        end
        if local_branch != 'master'
          ui.confirm("You are deploying a non-master branch(#{local_branch}), continue?")
        end
        check_commit
      end

      def check_commit
        if origin_commit.nil?
          ui.confirm('failed to determine the origin/master. sync anyway?')
        elsif local_branch == 'master' && local_commit != origin_commit
          ui.confirm('local master branch is different than origin, sync anyway?')
        end
      end

      def vendor_dir
        Chef::Config[:cookbook_path].first
      end

      def local_branch
        %x(git symbolic-ref --short HEAD).strip! || 'unknown'
      end

      def chef_server
        URI(Chef::Config[:chef_server_url]).host
      end

      def origin_commit
        @origin_commit||= begin
          Timeout::timeout(5) do
            commit = Mixlib::ShellOut.new("git ls-remote origin master | awk '{ print $1 }'")
            commit.run_command
            commit.exitstatus == 0 ? commit.stdout.strip : nil
          end
        rescue Timeout::Error
          nil
        end
      end

      def local_commit
        @local_commit ||= %x(git rev-parse master).strip! || 'unknown'
      end

      def localhost
        @localhost ||= Socket.gethostname
      end

      def converge_by(msg)
        if config[:why_run]
          ui.info('Will '+msg)
        else
          yield if block_given?
        end
      end

      def update_commit
        ui.info("updating commit from #{origin_commit} => #{local_commit}")
        file = Tempfile.new(['restorechef', '.json'])

        unless Chef::DataBag.list.keys.include?('metadata')
          plugin = Chef::Knife::DataBagCreate.new
          plugin.name_args = Array('metadata')
          converge_by 'create data bag metadata' do
            plugin.run
          end
        end
        begin
          file.write(JSON.dump({ id: 'commit', commit: local_commit }))
          file.flush
          dbag = Chef::Knife::DataBagFromFile.new
          dbag.name_args = ['metadata', file.path]
          converge_by 'update commit' do
            dbag.run
          end
        ensure
          file.close
          file.unlink
        end
      end
    end
  end
end
