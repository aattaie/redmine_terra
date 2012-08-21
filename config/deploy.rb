require "bundler/capistrano"

set :application, "redmine"
set :repository,  "git@s16423584.onlinehome-server.info:redmine.git"

set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, "terracloud2"                          # Your HTTP server, Apache/etc
role :app, "terracloud2"                          # This may be the same as your `Web` server
role :db,  "terracloud2", :primary => true # This is where Rails migrations will run

set :deploy_via, :remote_cache
set :use_sudo, false
set :user, "deploy"
set :branch, "terrabase"
set :deploy_to, "/home/www/redmine"
set :rails_env, "production"

ssh_options[:keys] = "/home/tracey/.ssh/id_dsa"

set :rvm_ruby_string, 'ruby-1.9.3-p194@redmine'
require "rvm/capistrano"
set :rvm_type, :system

# If you are using Passenger mod_rails uncomment this:
# if you're still using the script/reapear helper you will need
# these http://github.com/rails/irs_process_scripts

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
  desc "Symlinks the configuration"
  task :symlink_config, :roles => :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/config/configuration.yml #{release_path}/config/configuration.yml"
    run "ln -nfs #{shared_path}/config/initializers/session_store.rb #{release_path}/config/initializers/session_store.rb"
  end
  desc "Symlinks the files"
  task :symlink_files, :roles => :app do
    run "ln -nfs #{shared_path}/files #{release_path}/files"
  end
end
after 'deploy:update_code', 'deploy:symlink_config'
after 'deploy:update_code', 'deploy:symlink_files'

namespace :rvm do
  task :trust_rvmrc do
    run "rvm rvmrc trust #{release_path}"
  end
end
 after "deploy", "rvm:trust_rvmrc"
 before "deploy:setup", "rvm:create_gemset"

