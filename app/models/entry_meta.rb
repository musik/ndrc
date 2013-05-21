class EntryMeta < ActiveRecord::Base
  belongs_to :entry
  attr_accessible :mkey, :mval
end
