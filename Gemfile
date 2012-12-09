require 'rbconfig'
HOST_OS = RbConfig::CONFIG['host_os']
source 'http://ruby.taobao.org'
gem 'rails', '3.2.8'
gem 'mysql2'
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
end
gem 'jquery-rails'
gem "haml", ">= 3.1.6"
gem "haml-rails", ">= 0.3.4", :group => :development
gem "rspec-rails", ">= 2.11.0", :group => [:development, :test]
gem "database_cleaner", ">= 0.8.0", :group => :test
#gem "mongoid-rspec", "1.4.6", :group => :test
gem "factory_girl_rails", ">= 3.5.0", :group => [:development, :test]
gem "email_spec", ">= 1.2.1", :group => :test
gem "guard", ">= 0.6.2", :group => :development  
case HOST_OS
  when /darwin/i
    gem 'rb-fsevent', :group => :development
    gem 'growl', :group => :development
  when /linux/i
    gem 'libnotify', :group => :development
    gem 'rb-inotify', :group => :development
  when /mswin|windows/i
    gem 'rb-fchange', :group => :development
    gem 'win32console', :group => :development
    gem 'rb-notifu', :group => :development
end
gem "guard-bundler", ">= 0.1.3", :group => :development
gem "guard-rails", ">= 0.0.3", :group => :development
gem "guard-livereload", ">= 0.3.0", :group => :development
gem "guard-rspec", ">= 0.4.3", :group => :development
gem "devise", ">= 2.1.2"
gem "cancan", ">= 1.6.8"
gem "rolify", ">= 3.1.0"
gem "bootstrap-sass", ">= 2.0.4.0"
gem "simple_form"
gem "therubyracer", :group => :assets, :platform => :ruby
gem 'rails_admin'
gem 'china_region_fu'

#gem 'stringex'
gem 'awesome_nested_set'

gem 'typhoeus'
gem 'nokogiri'
gem 'anemone'

gem 'delayed_job_active_record'

#gem "kyotocabinet-ruby", "~> 1.27.1"
gem 'redis'
gem 'redis-rails'

gem 'breadcrumbs'
gem 'kaminari'

gem 'resque'
gem 'resque-scheduler', :require => 'resque_scheduler'
#gem 'resque-retry'
gem 'resque-cleaner'

gem 'thinking-sphinx', '2.0.13'
#gem 'thinking-sphinx', '2.0.13'
gem "ts-resque-delta", "~> 1.2.2"
#gem 'ts-datetime-delta', '1.0.3',:require => 'thinking_sphinx/deltas/datetime_delta'
#gem 'ts-delayed-delta', '1.1.3',:require => 'thinking_sphinx/deltas/delayed_delta'

gem 'chinese_pinyin'
gem "RedCloth", "~> 4.2.9"

gem 'thin'
gem 'unicorn'