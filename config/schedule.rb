# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
every '7 * * * *' do
  command "/usr/local/coreseek/bin/indexer -c /dat/www/ndrc/current/config/production.sphinx.conf company_delta --rotate"
end
every '13,43 * * * *' do
  command "/usr/local/coreseek/bin/indexer -c /dat/www/ndrc/current/config/production.sphinx.conf entry_delta --rotate"
end
  #runner "MyModel.some_method"
  #rake "some:great:rake:task"
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
