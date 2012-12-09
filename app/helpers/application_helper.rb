#encoding: utf-8
module ApplicationHelper
  def city_link name
    "/#{name}"
  end
  def cat_link c
    "/fenlei-#{c.to_params}"
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
end