require 'bundler/capistrano'

default_run_options[:pty] = true  # Must be set for the password prompt from git to work
ssh_options[:forward_agent] = true

set :application, "canoe"
set :repository,  "git@github.com:Pardot/#{application}.git"
set :deploy_to,   "/var/#{application}"

# set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, "127.0.0.1"
role :app, "127.0.0.1"
role :db,  "127.0.0.1", :primary => true

# fun rbenv setup
set :default_environment, {
  'RBENV_ROOT' => '/usr/local/rbenv',
  'PATH' => '/usr/local/rbenv/shims:/usr/local/rbenv/bin:$PATH'
}
set :bundle_flags, '--deployment --quiet --binstubs --shebang ruby-local-exec'

after 'deploy:restart', 'deploy:cleanup'
after 'deploy:create_symlink', 'canoe:link_envvars'

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# passenger setup
namespace :deploy do
  task :start do ; end
  task :stop  do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

namespace :canoe do
  task :link_envvars do
    run "ln -nfs ~/.envvars_production_#{application} #{current_path}/.envvars_production"
  end
end