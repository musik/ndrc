#encoding: utf-8
namespace :jobs do
  desc "引入分类"
  task :topics_init => :environment do
    CustomJob.set 'Topic.db_init'
    #CustomJob.set 'Topic.import_all'
  end
  desc "wordbot"
  task :wordbot => :environment do
    #Word::Ali.new.fetch_words
    sleep 120
  end
end
