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

module PagerDuty
  module ChefServer
    module SyncHelper

      def ignored?(path)
        ignore_patterns && ignore_patterns.any?{|pattern| File.fnmatch?(pattern, path)}
      end

      def converge_by(msg)
        if why_run
          ui.info(ui.color("Would ", :cyan)+ msg)
        else
          yield
        end
      end

      def chef_repo_dir
        File.expand_path('..', cookbook_dir)
      end

      def role_dir
        File.join(chef_repo_dir, 'roles')
      end

      def databag_dir
        File.join(chef_repo_dir, 'data_bags')
      end

      def environment_dir
        File.join(chef_repo_dir, 'environments')
      end


      def data_bag_from_file(name, path)
        converge_by "Create data bag #{name} from #{path}" do
          knife Chef::Knife::DataBagFromFile, name, path
        end
      end

      def upload_environments
        Dir[environment_dir+'/*'].reject{|f| File.directory?(f)}.each do |path|
          converge_by "Create environment from #{path}" do
            knife Chef::Knife::EnvironmentFromFile, path
          end
        end
      end

      def upload_roles
        Dir[role_dir+'/*'].each do |path|
          converge_by "Create role from #{path}" do
            knife Chef::Knife::RoleFromFile, path
          end
        end
      end

      def upload_all_cookbooks
        converge_by 'Upload all cookbooks' do
          knife(Chef::Knife::CookbookUpload) do |config|
            config[:all] = true
            config[:cookbook_path] = cookbook_dir
          end
        end
      end

      def upload_cookbook(cb)
        converge_by "Upload cookbook #{cb}" do
          knife(Chef::Knife::CookbookUpload, cb) do |config|
            config[:cookbook_path] = cookbook_dir
            config[:depends] = false
          end
        end
      end

      def upload_cookbooks(cbcb)
        sorted_cookbooks = cbcb.sort # definite order + nice printout for why_run
        converge_by "Upload cookbooks #{sorted_cookbooks.join(', ')}" do
          knife Chef::Knife::CookbookUpload, *sorted_cookbooks do |config|
            config[:cookbook_path] = cookbook_dir
            config[:depends] = false
          end
        end
      end

      def delete_cookbook(cb)
        converge_by "Delete cookbook #{cb}" do
          knife Chef::Knife::CookbookDelete, cb do |config|
            config[:yes] = true
            config[:all] = true
          end
        end
      end

      def upload_databags
        ui.info(ui.color('updating data bags in batch mode', :yellow))
        existing_databags = Chef::DataBag.list.keys
        Dir[databag_dir+'/*'].each do |db_path|
          if ignored?(db_path)
            ui.info(ui.color("Ignored:", :magenta) + db_path)
            next
          end
          db_name = File.basename(db_path)
          unless existing_databags.include?(db_name)
            create_databag(db_name)
          end
          Dir[db_path+'/*'].each do |path|
            unless ignored?(path)
              data_bag_from_file(File.basename(db_path), path)
            end
          end
        end
      end

      def create_databag(data_bag_name)
        converge_by "Create data bag #{data_bag_name}" do
          knife Chef::Knife::DataBagCreate, data_bag_name
        end
      end

      def data_bag_from_hash(databag_name, data)
        tmp = Tempfile.new(['restorechef', '.json'])
        begin
          tmp.write(JSON.dump(data))
          tmp.close
          converge_by "create data bag #{databag_name}" do
            data_bag_from_file(databag_name, tmp.path)
          end
        ensure
          tmp.unlink
        end
      end

      def knife(klass, *name_args)
        klass.load_deps
        plugin = klass.new
        yield plugin.config if Kernel.block_given?
        plugin.name_args = name_args
        plugin.run
      end

      def ignore_file
        File.join(chef_repo_dir, '.pd-ignore')
      end
    end
  end
end

