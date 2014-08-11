#encoding: utf-8
module ApplicationHelper
  def city_link name
    "/#{name}"
  end
  def cat_link c
    "/fenlei-#{c.to_params}"
  end
  def tcat_link c
    "/tc-#{c.to_params}"
  end
  def citycat_link city_name,c
    "#{city_link(city_name)}-#{c.to_params}"
  end
  def citypage_link city_name,str
    "#{city_link(city_name)}-#{str}"
  end
  def citycoms_link city_name
    "#{city_link(city_name)}-qiye"
  end
  def company_link c
    "/qiye-#{c.to_params}"
  end
  def xpaginate scope, options = {}, &block
    paginator = Xpaginator.new self, options.reverse_merge(:current_page => scope.current_page, :total_pages => scope.total_pages, :per_page => scope.limit_value, :param_name => Kaminari.config.param_name, :remote => false, :theme=>"etao",:window=>100)
    paginator.to_s
  end
  def highlight(text, phrases, *args)
    options = args.extract_options!
    options.reverse_merge!(:highlighter => '<span class="highlight">\1</span>')

    text = sanitize(text) unless options[:sanitize] == false
    if text.blank? || phrases.blank?
      text
    else
      match = Array(phrases).map { |p| Regexp.escape(p) }.join('|')
      text.sub(/(#{match})(?![^<]*?>)/i, options[:highlighter])
    end.html_safe
  end  
  def city_link_ynshangji name,is_state
    txt = File.read("#{Rails.root}/db/cities/ynshangji")
    cities = JSON.parse txt
    return  [] unless cities.has_key? name
    url = cities[name]
    arr = [["#{name}企业名录","http://www.ynshangji.com/#{url}/"]]
    url.sub!(/-huangye/,'')
    arr << ["#{name}企业库","http://www.zhaoshang100.com/#{url}/"] if is_state
    arr << ["#{name}产品网","http://www.cp293.com/#{is_state ? 'p' : 'c'}_#{url}/"]
    arr
  end
  def city_link_sdmec name,is_state
    txt = File.read("#{Rails.root}/db/cities/sdmec.json")
    cities = JSON.parse txt
    return [] unless cities.has_key? name
    url = cities[name]
    [["#{name}淘宝导购网","http://#{url}.sdmec.com"]]
  end
  def city_links name,is_state
    city_link_ynshangji(name,is_state) + city_link_sdmec(name,is_state)
  end
  def adsense slot,name,args={}
    defaults={
      :width => 336,
      :height => 280,
      :slot => slot,
      :name => name
    }
    render :partial=>'layouts/adsense',:locals=>defaults.merge(args)
  end
  def ubaidu id,name,cls,t=''
    return
    #return if Rails.env.development?
    <<-AD.html_safe
<div class="#{cls}">
<script type="text/javascript">
/*#{name}*/
var cpro_id = "u#{id}";
</script>
<script src="http://cpro.baidustatic.com/cpro/ui/c#{t}.js" type="text/javascript"></script>
</div>
AD
  end
end
