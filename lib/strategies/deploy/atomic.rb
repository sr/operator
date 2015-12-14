require_relative "base"
require 'shell_helper'
require 'build_version'
require 'logger'
require 'fileutils'

module Strategies
  module Deploy
    class Atomic < Base
      def deploy(artifact_path, deploy)
        dpath = deploy_path
        if dpath.nil?
          Logger.log(:err, "Deploy path not found: #{dpath}")
          false
        else
          if success = extract_artifact(dpath, artifact_path)
            move_symlinks(:forward, dpath)
          end
          success
        end
      end

      def rollback?(deploy)
        if current_build_version = BuildVersion.load("#{deploy_path(:reverse)}/build.version")
          current_build_version.instance_of_deploy?(deploy)
        else
          false
        end
      end

      def rollback
        move_symlinks(:reverse)
      end

      private

      def current_remote_pointed_at
        if File.symlink?(environment.payload.current_link) && real_path = File.readlink(environment.payload.current_link)
          Logger.log(:info, "LINK: current -> '#{real_path}'")
          real_path
        else
          nil # First deployment
        end
      end

      def deploy_path(direction = :forward)
        if current = current_remote_pointed_at
          pick_next_choice(environment.payload.path_choices, current, direction)
        else
          # First deployment - pick first one
          environment.payload.path_choices.first
        end
      end

      def pick_next_choice(array, current, direction)
        result = nil
        array = array.reverse unless direction == :forward
        choices = array.cycle
        array.length.times do
          if path_with_trailing_slash(current) == path_with_trailing_slash(choices.next)
            result = choices.next
            break
          end
        end
        result
      end

      def move_symlinks(direction = :forward, dpath = nil)
        dpath ||= deploy_path(direction)
        new_path = path_without_trailing_slash(dpath)

        Logger.log(:info, "LINK: [MOVE] current -> '#{new_path}'")
        # Atomic switch of the symlink requires creating it in a temporary
        # location, then `rename`ing it to the current_link. `ln -sf` _is not
        # atomic_ on its own.
        temp_current_link = "#{environment.payload.current_link}_temp"
        FileUtils.ln_sf(new_path, temp_current_link)
        File.rename(temp_current_link, environment.payload.current_link)
      end

      def path_with_trailing_slash(path)
        return nil if path.nil?
        path = path.to_s
        path += "/" unless path.strip[-1] == "/"
        path
      end

      def path_without_trailing_slash(path)
        # symlinks to dirs shouldn't end in /
        return nil if path.nil?
        path.to_s.strip.gsub(/\/$/,"")
      end

      def extract_artifact(deploy_path, artifact)
        # We deploy to a temporary deploy path to minimize the time when the
        # release directory is not present at all.
        new_deploy_path = "#{path_without_trailing_slash(deploy_path)}.new.#{$$}"
        begin
          FileUtils.rm_rf(new_deploy_path)
          FileUtils.mkdir_p(new_deploy_path)

          output = ShellHelper.execute_shell(["tar", "xzf", artifact, "-C", new_deploy_path])
          success = $?.success?
          if success
            old_deploy_path = "#{path_without_trailing_slash(deploy_path)}.old.#{$$}"
            begin
              FileUtils.rm_rf(old_deploy_path)
              File.rename(deploy_path, old_deploy_path) if File.exists?(deploy_path)
              File.rename(new_deploy_path, deploy_path)
            ensure
              FileUtils.rm_rf(old_deploy_path)
            end
          else
            Logger.log(:err, "Unable to extract artifact: #{output}")
          end

          success
        ensure
          FileUtils.rm_rf(new_deploy_path)
        end
      end
    end
  end

  register(:deploy, :atomic, Deploy::Atomic)
end
