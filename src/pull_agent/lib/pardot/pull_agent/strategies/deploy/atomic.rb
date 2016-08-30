module Pardot
  module PullAgent
    module Strategies
      module Deploy
        class Atomic < Base
          def deploy(artifact_path, deploy)
            deploy_path = determine_next_deploy_path
            if deploy_path.nil?
              Logger.log(:error, "Unable to determine deploy path")
              return false
            end

            extract_artifact(deploy_path, artifact_path).tap do |success|
              if success
                add_build_version(deploy, deploy_path)
                move_current_link(deploy_path)
              end
            end
          end

          def rollback?(deploy)
            if find_existing_deploy_on_disk(deploy)
              true
            else
              false
            end
          end

          def rollback(deploy)
            rollback_path = find_existing_deploy_on_disk(deploy)
            if rollback_path.nil?
              # We shouldn't get here because `rollback` is only invoked if
              # `rollback?` returns true, but in the case of a code bug, we
              # definitely want to bomb out if we can't find the deploy
              Logger.log(:error, "Unable to find rollback deploy on disk: #{deploy}")
              return false
            end

            if move_current_link(rollback_path)
              true
            else
              false
            end
          end

          private

          def add_build_version(deploy, deploy_path)
            v = BuildVersion.new(deploy.build_number, deploy.sha, deploy.artifact_url)
            v.save_to_file(File.join(deploy_path, "build.version"))
          end

          def current_link_pointed_at
            if File.symlink?(environment.payload.current_link)
              File.readlink(environment.payload.current_link)
            end
          end

          def move_current_link(deploy_path)
            Logger.log(:info, "Setting current symlink to '#{deploy_path}'")
            # Atomic switch of the symlink requires creating it in a temporary
            # location, then `rename`ing it to the current_link. `ln -sf` _is not
            # atomic_ on its own.
            temp_current_link = "#{environment.payload.current_link}_temp"
            FileUtils.ln_sf(deploy_path, temp_current_link)
            File.rename(temp_current_link, environment.payload.current_link)
          end

          def find_existing_deploy_on_disk(deploy)
            environment.payload.path_choices.find do |path|
              if (current_build_version = BuildVersion.load(File.join(path, "build.version")))
                current_build_version.instance_of_deploy?(deploy)
              else
                false
              end
            end
          end

          def determine_next_deploy_path
            path = \
              if (current = current_link_pointed_at)
                if (next_choice = pick_next_choice(environment.payload.path_choices, current))
                  next_choice
                else
                  # current isn't pointed at either release directory
                  # we are safe to choose the first
                  environment.payload.path_choices.first
                end
              else
                # First deployment - pick first one
                environment.payload.path_choices.first
              end

            normalize_path(path)
          end

          def pick_next_choice(array, current)
            _, next_choice = array.cycle.each_cons(2).take(array.length).find { |element, _next_element|
              normalize_path(element) == normalize_path(current)
            }

            next_choice
          end

          # Removes any trailing slashes from a pathname
          def normalize_path(path)
            path && path.sub(/\/+$/, "")
          end

          def extract_artifact(deploy_path, artifact)
            # We extract the artifact to a temporary deploy path, then `rsync` the
            # changes over to the `deploy_path`. We do this to make sure that we
            # don't touch the modification time on files that didn't change, which
            # would unnecessarily cause Opcache to invalidate them. We don't want to
            # start new deploys with a completely blown cache, lest we cause a cache
            # stampede.
            temp_deploy_path = "#{normalize_path(deploy_path)}.new.#{$$}"
            begin
              FileUtils.rm_rf(temp_deploy_path)
              FileUtils.mkdir_p(temp_deploy_path)

              output = ShellHelper.execute(["tar", "xzf", artifact, "-C", temp_deploy_path])
              success = $?.success?
              if success
                output = ShellHelper.execute(["rsync", "--recursive", "--checksum", "--links", "--perms", "--verbose", "--delete", temp_deploy_path + "/", deploy_path])
                success = $?.success?
                unless success
                  Logger.log(:err, "Unable to sync changes to new deploy path: #{output}")
                end
              else
                Logger.log(:err, "Unable to extract artifact: #{output}")
              end

              success
            ensure
              FileUtils.rm_rf(temp_deploy_path)
            end
          end
        end
      end

      register(:deploy, :atomic, Deploy::Atomic)
    end
  end
end
