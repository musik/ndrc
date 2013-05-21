class Entry < ActiveRecord::Base
  belongs_to :company,:counter_cache=>true
  attr_accessible :location_name, :price, :title, :company_id, :ali_id, :metas_attributes, :text_attributes
  has_one :text , :dependent => :destroy , :class_name => "EntryText"
  has_many :metas , :dependent => :destroy , :class_name => "EntryMeta"
  accepts_nested_attributes_for :text,:metas
  @queue = "entry"
  include ResqueEx
  define_index do
    indexes :title,:location_name
    indexes text(:body),:as=>:description
    has :id
    has :company_id
    #set_property :delta => ThinkingSphinx::Deltas::ResqueDelta
  end
  class << self
    def import data
      return if exists? :ali_id=>data[:ali_id]
      data[:metas_attributes] = data.delete(:meta).collect{|k,v|
        {:mkey=>k,:mval=>v}
      }
      data[:text_attributes] = {:body=>data.delete(:desc)}
      #logm data
      create data
    end
  end
end
