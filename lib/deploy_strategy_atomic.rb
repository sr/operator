require 'deploy_strategy_base'

class DeployStrategyAtomic < DeployStrategyBase
  def deploy(artifact_path, label)
    dpath = deploy_path
    if dpath.nil?
      Console.log("Error: Deploy path not found: #{dpath}", :red)
      response = DEPLOY_FAILED
    else
      response = extract_artifact(dpath, artifact_path)
      change_index_php_symfony_path!(dpath)
      move_symlinks(:forward, dpath)
    end
    response
  end

  def rollback
    move_symlinks(:reverse)
  end

  #def get_tag_and_hash(server_ip)
  #  label_file = "#{environment.payload.remote_current_link}/TAG-build*"
  #  label_file_name = ShellHelper.remote(server_ip, "ls #{label_file}", @environment)
  #  m = label_file_name.match(/TAG-(?<tag>\w+)/)
  #  hash = ShellHelper.remote(server_ip, "cat #{label_file}", @environment)
  #  [m[:tag], hash]
  #end

  private

  def current_remote_pointed_at
    output = ShellHelper.execute_shell("ls -l #{environment.payload.remote_current_link}")
    # http://rubular.com/r/wRL3vKUhQU
    if m = output.match(/\s(?<current_link>\.?\/.*?)\s->\s(?<real_path>.*)$/)
      # Double check current link
      Console.log("Remote dir does not match", :red) if m[:current_link] != environment.payload.remote_current_link
      # second is either a relative or absolute path
      real_path = m[:real_path]
      unless %w[/ .].include?(real_path[0])
        real_path = File.join(File.dirname(environment.payload.remote_current_link), real_path)
      end
      Console.log("LINK: current -> '#{real_path.strip}'", :yellow)
      real_path.strip
    else
      nil # First deployment
    end
  end

  def deploy_path(direction = :forward)
    current = current_remote_pointed_at
    if current.nil?
      # First deployment - pick first one
      environment.payload.remote_path_choices.first
    else
      pick_next_choice(environment.payload.remote_path_choices, current, direction)
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
        "ln -sfn #{new_path} #{environment.payload.remote_current_link}"
      else
        # trying an alternative approach: create "current_new" symlink and then move it to "current"
        "ln -sf #{new_path} #{environment.payload.remote_current_link}_new;" + \
        "mv -T #{environment.payload.remote_current_link}_new #{environment.payload.remote_current_link};"
      end

    Console.log("LINK: [MOVE] current -> '#{new_path}'", :yellow)
    output = ShellHelper.execute_shell(symlink_cmd)
    Console.log(output) unless output.strip.empty?
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

  def change_index_php_symfony_path!(deploy_path)
    # TODO: HACK - REMOVE THIS!!!
    Console.log("HACK: Changing index.php to point to /var/www/pardot/current...", :yellow)
    # this should only grab this line:
    # define('SF_ROOT_DIR',    realpath(dirname(__FILE__).'/../pi/'));
    # and do the replace to get this:
    # define('SF_ROOT_DIR',    realpath(dirname(__FILE__).'/..'));
    sed_cmd = "sed -i tmp 's/\\/pi\\///' #{deploy_path}/web/index.php"
    output = ShellHelper.execute_shell(sed_cmd)
    Console.log(output) unless output.strip.empty?
  end

  def extract_artifact(deploy_path, artifact)
    ShellHelper.execute_shell("mkdir -p #{deploy_path} &&
    tar xzf #{artifact} -C #{deploy_path}")
  end
end