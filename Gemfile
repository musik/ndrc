require 'rbconfig'
HOST_OS = RbConfig::CONFIG['host_os']
source 'http://ruby.taobao.org'
ruby '1.9.3'
gem 'rb-readline'
gem 'rails', '3.2.14'
gem 'mysql2'
gem 'sqlite3',:group=> :test
gem 'execjs'
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
gem "devise", ">= 2.1.2"
gem "cancan", ">= 1.6.8"
gem "rolify", ">= 3.1.0"
gem "bootstrap-sass", ">= 2.0.4.0"
gem "simple_form"
#gem "therubyracer", :group => :assets, :platform => :ruby
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

gem 'resque'#,'~> 1.25'
#gem "rufus-scheduler"#, "~> 2.0"
#gem 'resque-scheduler', :require => 'resque_scheduler'
#gem 'resque-retry'
gem 'resque-cleaner'
#gem 'resque-pool'
#gem "resque-lock-timeout"
gem 'resque-async-method'
gem 'god'


gem 'thinking-sphinx', '2.0.13'
#gem 'thinking-sphinx', '2.0.13'
#gem "ts-resque-delta", "~> 1.2.2"
gem 'ts-datetime-delta', '1.0.3',:require => 'thinking_sphinx/deltas/datetime_delta'
#gem 'ts-delayed-delta', '1.1.3',:require => 'thinking_sphinx/deltas/delayed_delta'
gem 'whenever'

gem 'chinese_pinyin', "0.4.1"
gem "RedCloth", "~> 4.2.9"

gem 'unicorn'
group :development do
  gem 'libnotify', :group => :development
  gem 'rb-inotify', :require => false
  gem 'guard'
  gem 'guard-livereload'
  gem 'guard-rspec'
  gem 'guard-rails'
  gem 'guard-bundler'
  gem 'capistrano'
  #gem 'capistrano-ext'
  gem 'capistrano-recipes'
  gem 'capistrano-helpers'
  #gem 'rvm-capistrano'
  gem 'capistrano-unicorn',:git=>'git://github.com/sosedoff/capistrano-unicorn.git'
  gem 'capistrano-resque'
  gem 'thin'
end
gem 'wash_out'
gem 'savon', '~> 2.1.0'
gem 'settingslogic'
gem 'high_voltage'
gem "stringex"
gem 'roo'

#gem 'jnewland-san_juan'
