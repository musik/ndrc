class Category < ActiveRecord::Base
  attr_accessible :name, :slug, :cid
  acts_as_nested_set
  #acts_as_url :name,:url_attribute => :slug,:only_when_blank=>true,:limit=>16
  before_validation(:ensure_unique_slug, :on => :create)
  def to_params
    (name.bytesize < 9 or slug.length < 13 and !slug.include?('-')) ? slug : id
  end
  define_index do
    indexes :name
  end
  def width
    @width ||= (rgt - lft) / 2
  end
 def source
   "http://search.china.alibaba.com/selloffer/--#{cid}.htm"
 end
 def queue_companies
    Resque.enqueue(::Aliparser::Cat,cid)
 end
 def to_slug
   Pinyin.t(name,'').downcase.gsub(/xingye/,'hangye').gsub(/[^a-zA-Z0-9]/,'-')
 end
  def ensure_unique_slug
    base_url = self.slug
    base_url = self.to_slug unless base_url.present? 
    conditions = ["slug LIKE ?", base_url+'%']
    #unless new_record?
    #  conditions.first << " and id != ?"
    #  conditions << id
    #end    
    url_owners = self.class.where(conditions).pluck(:slug)
    write_attribute :slug, base_url
    if url_owners.include? base_url
      n = 1
      while url_owners.include? "#{base_url}-#{n}"
        n = n.succ
      end
      write_attribute :slug, "#{base_url}-#{n}"
    end

  end
  class << self
    def search_pair str,limit=100
        Hash[Category.search(str,:select=>"id,name,slug",:match_mode=>:any,:per_page=>limit).collect{|r|
          [r.name,r]
        }]
    end
    def redo_slugs
      #update_all :slug=>nil
      find_each do |c|
        next if c.slug == c.to_slug
        c.slug = nil
        c.ensure_unique_slug
        c.save
      end
      []
    end
    def init_db
      #delete_all
      Ali::Robot.new.init_cats
    end
    def fetch_companies_all 
      Category.select([:id,:cid]).find_each do |c|
        c.queue_companies
      end
    end


    def import_breads arr
      parent = nil
      arr.each do |tmp|
        parent = parent.nil? ? 
            where(:cid=>tmp[1]).first_or_create(:name=>tmp[0]) :
            parent.children.where(:cid=>tmp[1]).first_or_create(:name=>tmp[0])
      end
    end
    def exists_by_cid? cid
      where(:cid=>cid).pluck(:id).present?
    end
    def find_smart key
      key.to_i.zero? ? find_by_slug(key) : find(key)
    end
    def import_by_url  url,more=false
      #cid = url.scan(/\d+/)[0]
      #return if exsits_by_cid? cid
      Ali::Robot.new.parse_cats url,more
    end
  end
end
