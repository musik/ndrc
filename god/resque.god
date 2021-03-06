rails_env   = ENV['RAILS_ENV']  || "production"
rails_root  = ENV['RAILS_ROOT'] || "/home/muzik/hy"
num_workers = rails_env == 'production' ? 1 : 1

God.watch do |w|
  w.log      = "#{rails_root}/log/god.log"
  w.dir      = "#{rails_root}"
  w.name     = "hy-scheduler"
  w.group    = 'hy'
  w.interval = 60.seconds
  w.start    = "cd #{rails_root} && RAILS_ENV=#{rails_env} bundle exec rake resque:scheduler"
  w.keepalive
end
num_workers.times do |num|
  God.watch do |w|
    w.log      = "#{rails_root}/log/god.log"
    w.dir      = "#{rails_root}"
    w.name     = "hy-#{num}"
    w.group    = 'hy'
    w.interval = 30.seconds
    w.start    = "cd #{rails_root} && RAILS_ENV=#{rails_env} bundle exec rake resque:work QUEUE=schedule,company,com_list,com_by_cat"

#    w.uid = 'muzik'
#    w.gid = 'muzik'

    # restart if memory gets too high
    w.transition(:up, :restart) do |on|
      on.condition(:memory_usage) do |c|
        c.above = 350.megabytes
        c.times = 2
      end
    end

    # determine the state on startup
    w.transition(:init, { true => :up, false => :start }) do |on|
      on.condition(:process_running) do |c|
        c.running = true
      end
    end

    # determine when process has finished starting
    w.transition([:start, :restart], :up) do |on|
      on.condition(:process_running) do |c|
        c.running = true
        c.interval = 5.seconds
      end

      # failsafe
      on.condition(:tries) do |c|
        c.times = 5
        c.transition = :start
        c.interval = 5.seconds
      end
    end

    # start if process is not running
    w.transition(:up, :start) do |on|
      on.condition(:process_running) do |c|
        c.running = false
      end
    end
  end
end
