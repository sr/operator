require_relative "base"
require 'shell_helper'
require 'build_version'
require 'logger'

module Strategies
  module Deploy
    class Atomic < Base
      def deploy(artifact_path, deploy)
        dpath = deploy_path
        if dpath.nil?
          Logger.log(:err, "Deploy path not found: #{dpath}")
          response = DEPLOY_FAILED
        else
          response = extract_artifact(dpath, artifact_path)
          fix_index_php
          move_symlinks(:forward, dpath)
        end
        response
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
        output = ShellHelper.execute_shell("ls -l #{environment.payload.current_link}")
        # http://rubular.com/r/wRL3vKUhQU
        if m = output.match(/\s(?<current_link>\.?\/.*?)\s->\s(?<real_path>.*)$/)
          # Double check current link
          Logger.log(:err, "Remote dir does not match") if m[:current_link] != environment.payload.current_link
          # second is either a relative or absolute path
          real_path = m[:real_path]
          unless %w[/ .].include?(real_path[0])
            real_path = File.join(File.dirname(environment.payload.current_link), real_path)
          end
          Logger.log(:info, "LINK: current -> '#{real_path.strip}'")
          real_path.strip
        else
          nil # First deployment
        end
      end

      def deploy_path(direction = :forward)
        current = current_remote_pointed_at
        if current.nil?
          # First deployment - pick first one
          environment.payload.path_choices.first
        else
          pick_next_choice(environment.payload.path_choices, current, direction)
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

        symlink_cmd = \
          if RUBY_PLATFORM =~ /darwin/ # "hack" for dev testing where OSX doesn't support the -T flag on mv
            "ln -sfn #{new_path} #{environment.payload.current_link}"
          else
            # trying an alternative approach: create "current_new" symlink and then move it to "current"
            "ln -sf #{new_path} #{environment.payload.current_link}_new;" + \
            "mv -T #{environment.payload.current_link}_new #{environment.payload.current_link};"
          end

        Logger.log(:info, "LINK: [MOVE] current -> '#{new_path}'")
        output = ShellHelper.execute_shell(symlink_cmd)
        Logger.log(:debug, output) unless output.strip.empty?
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
        ShellHelper.execute_shell("
          rm -rf #{deploy_path}
          mkdir -p #{deploy_path} &&
          tar xzf #{artifact} -C #{deploy_path}")
      end

      # TODO: This is a temporary hack. Let's fix https://jira.dev.pardot.com/browse/BREAD-312
      def fix_index_php
        return if environment.production?
        return if File.read("#{deploy_path}/web/index.php") =~ /PI_ENV/
        File.delete("#{deploy_path}/web/index.php")
        File.symlink("#{deploy_path}/web/index_staging_s.php", "#{deploy_path}/web/index.php")
      end
    end
  end

  register(:deploy, :atomic, Deploy::Atomic)
end
