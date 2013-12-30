#encoding: utf-8
namespace :init do
  desc "generate province ids for companies"
  task :companies_provinces => :environment do
    Company.detect_all_locations
  end
  desc "current topics import companies"
  task :import_companies => :environment do
    Topic.where(imported_at: nil).find_each do |r|
      r.import_companies
    end
  end
  task :publish_companies => :environment do
    Topic.where(published: nil).find_each do |r|
      r.update_attribute :published,true
    end
  end
  desc "delete topics bytesize > 30"
  task :limit_topic_namesize => :environment do
    Topic.where("LENGTH(name) > 30").delete_all
  end
end
