RAILS_ROOT = File.dirname(File.dirname(__FILE__))
God.watch do |w|

  #w.name = "botword"
  #w.dir = RAILS_ROOT
  #w.start = "rails runner 'Word::Ali.new.fetch_words'"
  #w.stop = "kill -s QUIT $(cat #{pid_file})"
  #w.restart = "kill -s HUP $(cat #{pid_file})"
  #w.start_grace = 20.seconds
  #w.restart_grace = 20.seconds
  #w.pid_file = pid_file
  w.env = { 'RAILS_ENV' => "production" }
  w.name = "botword"
  w.dir = RAILS_ROOT
  w.start = "rake jobs:wordbot"
  #w.pid_file = File.join(RAILS_ROOT, "/tmp/pids/botword.pid")
  w.stop = "kill -9 $(cat #{w.pid_file})"
  w.restart = "kill -s HUP $(cat #{w.pid_file})"
  w.start_grace = 20.seconds
  w.restart_grace = 20.seconds
  w.keepalive(:memory_max => 150.megabytes,
              :cpu_max => 50.percent)


  w.behavior(:clean_pid_file)
end
