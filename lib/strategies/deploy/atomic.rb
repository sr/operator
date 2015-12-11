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
          if extract_artifact(dpath, artifact_path)
            move_symlinks(:forward, dpath)
            true
          else
            Logger.log(:err, "Failed to extract artifact")
            false
          end
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
        FileUtils.rm_rf(deploy_path)
        FileUtils.mkdir_p(deploy_path)
        ShellHelper.execute_shell(["tar", "xzf", artifact, "-C", deploy_path])
        $?.success?
      end
    end
  end

  register(:deploy, :atomic, Deploy::Atomic)
end
