class CompanyMeta < ActiveRecord::Base
  belongs_to :company
  attr_accessible :mkey, :mval
end
