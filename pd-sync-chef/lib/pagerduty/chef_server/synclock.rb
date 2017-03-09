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

require 'fileutils'
require 'chef/knife'

module PagerDuty
  module ChefServer
    class LockUnavailable < IOError; end
    class ChefCronRunning < StandardError; end

    class SyncLock
      def initialize(lockfile, server_hostname, local_hostname, user, branch, force_lock = false)
        @lockfile = lockfile
        @server_hostname = server_hostname.include?('.') ? server_hostname.split('.')[0] : server_hostname
        @local_hostname = local_hostname
        @user = user
        @branch = branch
        @opts = parse_opts({ announce: true, lock: true, force: force_lock })
      end

      # get lock
      def lock(time = Time.now)
        verify_lockable

        @f_lock = procure_lock if @opts[:lock] || @opts[:force]
      end

      # remove lock
      def unlock
        if @opts[:lock]
          Chef::Knife.ui.info 'removing lockfile'
          @f_lock.flock(File::LOCK_UN)
          @f_lock.close
          FileUtils.rm(@f_lock.path)
        end
      end

      private

      def verify_lockable
        unless local_chef_server? && @opts[:force]
          @opts[:lock] = false
          Chef::Knife.ui.warn(
            'Please be careful, this looks to be running on a system other than a chef server. '\
              'As such, there will be *no* locking. Hold on to your butts...'
          )
          sleep 5
        end
      end

      def parse_opts(options)
        options[:announce] &&= false unless remote_chef_server?
        options[:lock] &&= false unless local_chef_server?
        options
      end

      def local_chef_server?
        @local_hostname.include? 'chef'
      end

      def remote_chef_server?
        @server_hostname.include? 'chef'
      end

      def procure_lock
        Chef::Knife.ui.info 'trying to obtain exclusive lock...'

        # create a file handle for the lockfile -- create if it doesn't exist and
        # make it read/write
        lf = File.open(@lockfile, File::CREAT|File::RDWR, 0644)

        unless lf.flock(File::LOCK_NB|File::LOCK_EX)
          # if we fail to obtain the lock figure out who has lock and for
          # how long so we can display that information
          ld = JSON.parse(lf.read.strip)
          msg = if (ld['user'].strip == @user)
                  "according to lockfile you've had lock for" \
                  " #{Time.now.to_i - ld['ts']} second(s)."
                else
                  "unable to get exclusive lock, currently held by" \
                  " #{ld['user']} for #{Time.now.to_i - ld['ts']} second(s)" \
                end
          # close the file handle
          lf.close
          Chef::Knife.ui.fatal msg
          raise LockUnavailable, msg
        end
        # we could get lock, so write our information to the file
        lf.write(JSON.dump({ user: @user, ts: Time.now.to_i }))
        lf.flush
        Chef::Knife.ui.info 'lock obtained'
        lf
      end
    end
  end
end
