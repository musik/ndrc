#encoding: utf-8
class Entry < ActiveRecord::Base
  belongs_to :company,:counter_cache=>true
  attr_accessible :location_name, :price, :title, :company_id, :ali_id, :metas_attributes, :text_attributes,
    :ali_url,:kind,:keywords,:photo,:hangye,:pinpai,:district_id,
    :city_id,:province_id,:description

  has_one :text , :dependent => :destroy , :class_name => "EntryText"
  has_many :metas , :dependent => :destroy , :class_name => "EntryMeta"
  accepts_nested_attributes_for :text,:metas
  validates_presence_of :title
  scope :recent,order("id desc")

  belongs_to :city
  belongs_to :province
  before_save :gen_description

  def gen_description
    return if self[:decription].present? 
    self[:description] = ActionController::Base.helpers.strip_tags(text.body)
    self[:description].gsub!(/\n|\t|&nbsp;|\\n|\\t/,'')
    self[:description].gsub!(/\s/,'')
  end
  @queue = "entry"
  include ResqueEx
  define_index do
    indexes :title,:location_name,:keywords
    #indexes text(:body),:as=>:description
    indexes :description
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
    def build_from_tz data,fix_company=nil
      cid = data.delete('bsCompanyID')
      company_ali_url = "sm" + cid
      company = Company.where(ali_url: company_ali_url).first
      return new if company.nil? && !fix_company
      if company.nil?
        company = Company.fetch_from_tz_id(cid,data.delete('subdomain'))
      end
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
          r[k.to_sym] = data.delete(tk)
        end
      end
      r[:text_attributes] = {:body=>data.delete("bsContent")}
      r[:title] = r[:title].gsub(/[【】]/,'')
      r[:title] = r[:title].gsub(/[_|、，]/,',')
      e = company.entries.where(title: r[:title]).first
      return e if e.present?
      r = company.entries.new(r)
      r.province_id = company.province_id if r.province_id.nil?
      r.city_id = company.city_id if r.city_id.nil?
      #pp data
      r.price = nil  if r.price.zero?
      r
    end
  end
  def self.update_all_description
    where(description: nil).includes(:text).find_each do |r|
      r.save
    end
  end
end
