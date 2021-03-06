Capistrano::Configuration.instance.load do
  namespace :resque do  
    desc "|DarkRecipes| Starts the god"
    task :god, :roles => :app do
      run "cd #{current_path} && bundle exec god -c god/resque.god"
    end
    desc "|DarkRecipes| restart the god"
    task :god_reload, :roles => :app do
      run "kill -QUIT `cat ~/.god/pids/resque-ecn-0.pid`"
      run "kill -QUIT `cat ~/.god/pids/resque-ecn-delta.pid`"
      #run "cd #{current_path} && bundle exec god -c god/resque.god"
    end
    namespace :pool do
      set(:pool_pid) { File.join(pids_path, "pool.pid") } unless exists?(:pool_pid)
      set(:scheduler_pid) { File.join(pids_path, "scheduler.pid") } unless exists?(:scheduler_pid)
      desc "Restart all workers"
      task :restart, :roles => :app do
        run <<-CMD
          if [ -f '#{pool_pid}' ];then
            kill -QUIT `cat #{pool_pid}`;
          fi;
          if [ -f '#{scheduler_pid}' ];then
            kill -QUIT `cat #{scheduler_pid}`;
            rm #{scheduler_pid};
          fi;
        CMD
        sleep 3
        run <<-CMD
          cd #{current_path} && RAILS_ENV=production bundle exec resque-pool -p #{pool_pid} -c config/pool.yml --daemon;
          cd #{current_path} && RAILS_ENV=production bundle exec rake resque:scheduler PIDFILE=#{scheduler_pid} BACKGROUND=yes;
        CMD
        #run "cd #{current_path} && RAILS_ENV=production bundle exec resque-pool -p #{pool_pid} --daemon"
      end  
    end
    namespace :worker do
      desc "|DarkRecipes| List all workers"
      task :list, :roles => :app do
        run "cd #{current_path} && resque list"
      end
    
      desc "|DarkRecipes| Starts the workers"
      task :start, :roles => :app do
        run "cd #{current_path} && god start #{resque_service}"
      end
    
      desc "|DarkRecipes| Stops the workers"
      task :stop, :roles => :app do
        run "cd #{current_path} &&  god stop #{resque_service}"
      end
    
      desc "|DarkRecipes| Restart all workers"
      task :restart, :roles => :app do
        run "cd #{current_path} && bundle exec god restart #{resque_service}"
      end  
    end
  
    namespace :web do
      desc "|DarkRecipes| Starts the resque web interface"
      task :start, :roles => :app do
        run "cd #{current_path}; resque-web -p 9000 -e #{rails_env} "
      end
    
      desc "|DarkRecipes| Stops the resque web interface"
      task :stop, :roles => :app do
        run "cd #{current_path}; resque-web -K"
      end
    
      desc "|DarkRecipes| Restarts the resque web interface "
      task :restart, :roles => :app do
        stop
        start
      end
    
      desc "|DarkRecipes| Shows the status of the resque web interface"
      task :status, :roles => :app do
        run "cd #{current_path}; resque-web -S"
      end 
    end
  end
end
