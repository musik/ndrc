class CompanyMeta < ActiveRecord::Base
  belongs_to :company
  attr_accessible :mkey, :mval
  class << self
    def remove_excludes
      #where(mkey: Bot1688::Company::EXCLUDES).delete_all
      Bot1688::Company::EXCLUDES.each do |k|
        puts k
        puts where(mkey: k).count
        where(mkey: k).delete_all
      end
      #while r = where(mkey: Bot1688::Company::EXCLUDES).first and r.present?
        #r.destroy
      #end
    end
  end
end
