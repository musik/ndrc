
set :application, "ndrc"
set :repository,  "git@github.com:musik/ndrc.git"

set :scm, :git

set :deploy_to, "/dat/www/ndrc"
role :web, "nxr"                          # Your HTTP server, Apache/etc
role :app, "nxr"                          # This may be the same as your `Web` server
role :db,  "nxr", :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"
set :user, "deploy"
set :group, "deploy"
set :sockets_path,File.join(shared_path, "sockets")
set :use_sudo,false
set :using_rvm,false
ssh_options[:forward_agent] = true

set :branch, "master"
set :rake_bin, 'bundle exec rake'
set :deploy_via, :remote_cache
#set :git_shallow_clone, 1

set :default_environment, {
    #'GEM_HOME' => '/home/muzik/.gem',
    #'PATH' => "/home/muzik/.gem/bin:$PATH",
    'RAILS_ENV' => 'production'
}
#recipes
require 'helpers'
require 'recipes/application'
#require './lib/recipes/hooks.rb'
#after "deploy:finalize_update","bundler:install"
#require './lib/recipes/bundler.rb'

#RVM
#set :rvm_ruby_string, ENV['GEM_HOME'].gsub(/.*\//,"")
#set :rvm_install_ruby_params, '--1.9'      # for jruby/rbx default to 1.9 mode
#set :rvm_install_pkgs, %w[libyaml openssl] # package list from https://rvm.io/packages
#set :rvm_install_ruby_params, '--with-opt-dir=/usr/local/rvm/usr' # package support

#before 'deploy:setup', 'rvm:install_rvm'   # install RVM
#before 'deploy:setup', 'rvm:install_pkgs'  # install RVM packages before Ruby
#before 'deploy:setup', 'rvm:install_ruby'  # install Ruby and create gemset, or:
#before 'deploy:setup', 'rvm:create_gemset' # only create gemset
#before 'deploy:setup', 'rvm:import_gemset' # import gemset from file

#require "rvm/capistrano"

#NGinx
set :nginx_remote_config,"/etc/nginx/sites-enabled/ndrc.conf"
set :nginx_local_config, "./lib/templates/nginx.conf.erb"
set :application_uses_ssl, false
set :nginx_host_name,"www.ndrc.ac.cn"
#set :nginx_host_uniq,false
set :nginx_host_uniq,"www.ndrc.ac.cn"
set :nginx_host_alias,"ndrc.ac.cn"

require './lib/recipes/nginx.rb'


set :environment, 'production'

#Database And config files
#before "deploy:assets:precompile","app:"
require './lib/recipes/db.rb'
after "deploy:finalize_update","app:yml"
after "deploy:finalize_update","app:symlink"
after "deploy:finalize_update","deploy:migrate"
require './lib/recipes/custom.rb'

#after 'app:symlink', 'db:migrate'
#set :normal_symlinks, %w(tmp log config/database.yml config/application.yml)
#after "deploy:create_symlink","symlinks:make"
#require 'recipes/symlinks'

#Assets

#Sphinx
#before 'deploy:create_symlink', 'sphinx:pi'
after 'deploy:create_symlink', 'sphinx:symlink'
#after 'deploy:create_symlink', 'sphinx:config'
before 'deploy:start','sphinx:start'
#before 'deploy:restart','sphinx:index'
before 'deploy:restart','sphinx:restart'
require './lib/recipes/sphinx.rb'

#Unicorn
set :unicorn_workers,3
set :unicorn_user,:muzik
require './lib/recipes/unicorn.rb'

after "deploy:create_symlink","unicorn:symlink"
after "deploy:create_symlink","app:whenever"
after 'deploy:start','unicorn:start'
after 'deploy:restart', 'unicorn:restart' # app IS NOT preloaded
#require 'recipes/unicorn'
#require 'capistrano-unicorn'

#God
#require 'san_juan'
#role :botword, "nxr"
#san_juan.role :botword,%w()
#before :deploy,"god:app:botword:stop"
#before "deploy","god:stop"
after "deploy:restart","god:start"

#Resque

#set :resque_service,'resque-sdmec'
#require './lib/recipes/resque.rb'
#after 'deploy:restart', 'resque:pool:restart' 
#before 'deploy:restart','resque:restart'
#role :resque_worker, "rho"
#role :resque_scheduler, "rho"
#set :workers, { "update_keywords,update_items" => 1 }
require 'capistrano-resque'
role :resque_worker, "nxr"
role :resque_scheduler, "nxr"
set :workers, {daemon: 1,topics: 3 , index: 1}
set :resque_environment_task, true
#after "deploy:restart", "resque:restart"
#after "deploy:restart", "resque:scheduler:restart"

#set :whenever_command, "bundle exec whenever"
#require "whenever/capistrano"



require "bundler/capistrano"

after "deploy:restart", "deploy:cleanup"
#set :privates,%w{
  #config/database.yml
#}
#require 'capistrano-helpers/privates'
#set :shared,%w{
  #db/sphinx
#}
#require 'capistrano-helpers/shared'
