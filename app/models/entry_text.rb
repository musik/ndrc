class EntryText < ActiveRecord::Base
  belongs_to :entry
  attr_accessible :body
end
