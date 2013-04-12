#encoding: utf-8
namespace :dev do
  desc "引入分类"
  task :categories => :environment do
    Category.delete_all
    HyRobot::Core.new.run_cats
  end
  desc "fetch companies by cats"
  task :fetch_companies_by_cats => :environment do
    Category.select([:id,:cid]).find_each do |c|
      c.queue_companies
    end
  end
end
