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
  desc "province short names"
  task :province_short_names => :environment do
    Province.all.each do |p|
      short = p.name[0,2]
      short = p.name[0,3] if %w(内蒙 黑龙).include?(short)
      p.update_attribute :short_name,short
    end
  end
  desc "abbr for topics"
  task :topics_abbr => :environment do
    Topic.where(:abbr=>nil).find_each do |t|
      abbr = t.slug[0,1]
      abbr = "0" unless abbr.to_i.zero? 
      t.update_attribute :abbr,abbr
    end
  end
end
