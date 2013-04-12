namespace :resque do
  task :setup => :environment do

  end
  task "pool:setup" do
    # close any sockets or files in pool manager
    ActiveRecord::Base.connection.disconnect!
    # and re-open them in the resque worker parent
    Resque::Pool.after_prefork do |job|
      ActiveRecord::Base.establish_connection
    end    
  end
  task "pool:delta"=> %w[resque:setup resque:pool:setup] do
    require 'resque/pool'
    ENV['INTERVAL']='180'
    Resque::Pool.new("config/pool-delta.yml").start.join
  end
end
