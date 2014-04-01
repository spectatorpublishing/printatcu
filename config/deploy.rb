require "mina/bundler"
require "mina/rails"
require "mina/git"
require "mina/rvm"

set :user, "deploy"
set :domain, "162.243.219.89"
set :deploy_to, "/var/www/printatcu-alt"
set :repository, "https://github.com/spectatorpublishing/printatcu.git"
set :branch, "alt"

set :shared_paths, ["config/database.yml", "log", "public/uploads", "tmp/pids", "tmp/sockets"]

set :rvm_path, "/usr/local/rvm/scripts/rvm"

task :environment do
  invoke :'rvm:use[ruby-2.0.0]'
end

task :setup => :environment do
  queue! %[mkdir -p "#{deploy_to}/shared/log"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/log"]

  queue! %[mkdir -p "#{deploy_to}/shared/public/uploads"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/public/uploads"]

  queue! %[mkdir -p "#{deploy_to}/shared/config"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/config"]

  queue! %[mkdir -p "#{deploy_to}/shared/tmp/pids"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/tmp/pids"]

  queue! %[mkdir -p "#{deploy_to}/shared/tmp/sockets"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/tmp/sockets"]

  queue! %[touch "#{deploy_to}/shared/config/database.yml"]
end

desc "Deploys the current version to the server."
task :deploy => :environment do
  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'

    to :launch do
      if ENV["cold"]
        invoke :start
      else
        invoke :restart
      end
    end
  end
end

task :start do
  invoke :'unicorn:start'
end

task :restart do
  invoke :'unicorn:restart'
end

task :stop do
  invoke :'unicorn:stop'
end

namespace :unicorn do
  task :start => :environment do
    queue "cd #{deploy_to}/#{current_path}"
    queue "UNICORN_PWD=#{deploy_to}/#{current_path} bin/unicorn -c config/unicorn.rb -E #{rails_env} -D"
  end

  task :restart do
    queue "kill -s HUP `cat #{deploy_to}/shared/tmp/pids/unicorn.pid`"
  end

  task :stop do
    queue "kill -s QUIT `cat #{deploy_to}/shared/tmp/pids/unicorn.pid`"
  end
end