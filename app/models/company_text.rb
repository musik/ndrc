class CompanyText < ActiveRecord::Base
  belongs_to :company
  attr_accessible :body
end
