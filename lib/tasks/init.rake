#encoding: utf-8
namespace :init do
  desc "generate province ids for companies"
  task :companies_provinces => :environment do
    Company.detect_all_locations
  end
  desc "current topics import companies"
  task :import_companies => :environment do
    Topic.find_each do |r|
      r.import_companies
    end
  end
end
