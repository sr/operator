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

require 'pagerduty/chef_server/sync_helper'

module PagerDuty
  module ChefServer
    # rubocop:disable Metrics/ClassLength
    class Sync

      # require_relative 'sync_helper'
      include PagerDuty::ChefServer::SyncHelper

      attr_reader :ui, :why_run, :cookbook_dir, :ignore_patterns

      def initialize(opts={})
        require 'tempfile'
        require 'json'
        require 'mixlib/shellout'
        require 'chef/cookbook_version'
        require 'chef/data_bag_item'
        require 'chef/data_bag'
        require 'berkshelf'
        require 'berkshelf/berksfile'
        @cookbook_dir =  opts[:vendor_dir]
        @why_run = opts[:why_run]
        @ui = opts[:ui] || Chef::Knife.ui
        if File.exist?(ignore_file)
          @ignore_patterns = File.read(ignore_file).lines.map{|l| File.join(chef_repo_dir, l).strip}
        else
          ui.info('.pd-ignore absent, nothing will be ignored')
          @ignore_patterns = false
        end
      end

      def run
        berkshelf_install
        sync_cookbooks
        upload_databags
        upload_environments
        upload_roles
      end

      def sync_cookbooks
        altered_cookbooks = Hash.new{|h, k| h[k] = []}

        if remote_cookbooks.empty?
          upload_all_cookbooks
        else
          unless new_cookbooks.empty?
            upload_cookbooks(new_cookbooks)
            altered_cookbooks[:added] = new_cookbooks
          end
          stale_cookbooks.each do |cb|
            delete_cookbook(cb)
            altered_cookbooks[:deleted] << cb
          end
          updated_cookbooks.each do |cb|
            replace_cookbook(cb)
            altered_cookbooks[:updated] << cb
          end
        end
      end

      def berkshelf_install
        path = File.expand_path(File.join(chef_repo_dir, 'Berksfile'))
        ui.info(ui.color("using Berksfile: #{path} for berkshelf install", :yellow))
        berksfile = Berkshelf::Berksfile.from_file(path, { except: 'tests' } )
        FileUtils.rm_rf(cookbook_dir)
        berksfile.vendor(cookbook_dir)
      end

      def local_cookbooks
        local_checksums.keys.sort
      end

      def remote_cookbooks
        @remote_cookbooks ||= Chef::CookbookVersion.list.keys.sort
      end

      def remote_commit
        @remote_commit ||= begin
          if Chef::DataBag.list.keys.include?('metadata')
            Chef::DataBagItem.load('metadata', 'commit').raw_data['commit']
          else
            {}
          end
        end
      end

      def cookbook_segments
        Chef::CookbookVersion::COOKBOOK_SEGMENTS
      end

      def remote_checksums
        @remote_checksums ||= begin
          c = {}
          remote_cookbooks.each do |cb|
            c[cb] = {}
            cbm = Chef::CookbookVersion.load(cb).manifest
            cookbook_segments.each do |m|
              cbm_sort = cbm[m].sort { |x, y| x['name'] <=> y['name'] }
              cbm_sort = cbm_sort.sort { |x, y| x['checksum'] <=> y['checksum'] }
              cbm_sort.each do |file|
                file.delete(:url)
                file.delete(:path)
                file.delete(:specificity)
              end
              c[cb][m] = cbm_sort
            end
          end
          c
        end
      end

      def local_checksums
        @local_checksums ||= begin
          c = {}
          cbl = Chef::CookbookLoader.new(Array(cookbook_dir))
          cbl.load_cookbooks
          cbl_sort = cbl.values.map(&:name).map(&:to_s).sort

          cbl_sort.each do |cb|
            print "#{cb} => "
            c[cb] = {}
            cookbook_segments.each do |m|
              cbm_sort = cbl[cb].manifest[m].sort { |x, y| x['name'] <=> y['name'] }
              cbm_sort = cbm_sort.sort { |x, y| x['checksum'] <=> y['checksum'] }
              cbm_sort.each do |file|
                file.delete(:path)
                file.delete(:specificity)
              end
              c[cb][m] = cbm_sort
            end
            diff = diff(c[cb], remote_checksums[cb])
            if diff.empty?
              ui.info(ui.color( 'match', :green))
            else
              ui.info(ui.color( 'mismatch', :yellow))
              ui.output(diff(c[cb], remote_checksums[cb]))
            end
            sleep 0.1 # was printing too fast to be useful :(
          end
          c
        end
      end

      def diff(mf1, mf2)
        diffs = Hash.new{|h, k| h[k]= []}
        mf2 = {} if mf2.nil?
        mf1 = {} if mf1.nil?
        segments = (mf1.keys + mf2.keys).sort.uniq
        different_parts = segments.select{|segment| mf1[segment]!= mf2[segment]}
        different_parts.each do |segment|
          files = (Array(mf1[segment]) + Array(mf2[segment])).map{|f| f['name']}.uniq
          files.each do |file|
            f1 = Array(mf1[segment]).detect{|f|f['name'] == file} || {}
            f2 = Array(mf2[segment]).detect{|f|f['name'] == file} || {}
            unless f1['checksum'] == f2['checksum']
              diffs[segment] << file #unless file =~ /metadata\.(rb|json)/
            end
          end
        end
        diffs
      end

      def different_cookbook?(cb)
        !diff(local_checksums[cb], remote_checksums[cb]).empty?
      end

      def new_cookbooks
        local_cookbooks - remote_cookbooks
      end

      def stale_cookbooks
        remote_cookbooks - local_cookbooks
      end

      def updated_cookbooks
        (local_cookbooks & remote_cookbooks).select do |cb|
          different_cookbook?(cb)
        end
      end

      def replace_cookbook(cb)
        converge_by "Replace cookbook #{cb}" do
          delete_cookbook(cb)
          upload_cookbook(cb)
        end
      end
    end
    # rubocop:enable Metrics/ClassLength
  end
end
