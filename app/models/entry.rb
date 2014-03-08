#encoding: utf-8
class Entry < ActiveRecord::Base
  belongs_to :company,:counter_cache=>true
  attr_accessible :location_name, :price, :title, :company_id, :ali_id, :metas_attributes, :text_attributes,
    :ali_url,:kind,:keywords,:photo,:hangye,:pinpai,:district_id,
    :city_id,:province_id

  has_one :text , :dependent => :destroy , :class_name => "EntryText"
  has_many :metas , :dependent => :destroy , :class_name => "EntryMeta"
  accepts_nested_attributes_for :text,:metas
  validates_presence_of :title

  belongs_to :city
  belongs_to :province
  @queue = "entry"
  include ResqueEx
  define_index do
    indexes :title,:location_name,:keywords
    indexes text(:body),:as=>:description
    indexes company(:name),:as=>:company_name
    has :id
    has :company_id
    #set_property :delta => ThinkingSphinx::Deltas::ResqueDelta
  end
  def company_name
    company.present? ? company.name : nil
  end
  def q
    keywords || title
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
    def build_from_tz data
      company_ali_url = "sm" + data.delete('bsCompanyID')
      company = Company.where(ali_url: company_ali_url).first
      return new if company.nil?
      ali_url = "sm" + data.delete('bsID')
      e = where(ali_url: ali_url).first
      return e if e.present?
      r = {ali_url: ali_url}
      attr_map = {
        kind: "bsType",
        keywords: "bsKey",
        photo: "bsPicUrl",
        pinpai: "Breed" ,
        hangye: "B2BIndustryNamePlace",
        location_name: "B2BAreaNamePlace",
        price: "Price"
      }
      attr_map.each do |k,v|
        r[k] = data.delete(v) if data.has_key?(v)
      end
      attribute_names.each do |k|
        tk = "bs" + k.camelize
        if data.has_key?(tk)
          r[k] = data.delete(tk)
        end
      end
      r[:text_attributes] = {:body=>data.delete("bsContent")}
      r = company.entries.new(r)
      r.province_id = company.province_id if r.province_id.nil?
      r.city_id = company.city_id if r.city_id.nil?
      pp data
      r.price = nil  if r.price.zero?
      r
    end
  end
end
