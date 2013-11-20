#encoding: utf-8
namespace :init do
  desc "generate province ids for companies"
  task :companies_provinces => :environment do
    Company.detect_all_locations
  end
end
