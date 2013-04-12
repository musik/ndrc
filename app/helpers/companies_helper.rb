#encoding: utf-8
module CompaniesHelper
  def company_locations c
    c.sub(/\[已认证\]/,'').split(/[ \/]/).compact.collect{|str|
      slug = Pinyin.t(str,'')
      logger.debug slug
      (is_city? slug or is_state? slug) ? link_to(str,"/#{slug}") : nil
    }.compact.join(" - ").html_safe
  end
  def company_clean_col val
    val.nil? ? nil : val.gsub(/\[已认证\]/,'') 
  end
end
