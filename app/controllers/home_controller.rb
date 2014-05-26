#encoding: utf-8
class HomeController < ApplicationController
  caches_action :index,:expires_in => 5.minutes
  caches_action :city,:expires_in => 5.minutes
  layout "five",only: :five
  layout false,only: :six
  def index
    @hide_cities = true
  end
  def welcome
  end
  def five
    @shuiguo = _parse_arr(%w(苹果 香蕉 西瓜 甜瓜 梨 甘蔗 蜜桃 油桃 蜜桔 沙糖桔 椪柑 脐橙 山楂 葡萄 菠萝 草莓 龙眼 杏子 李子 核桃 板栗 葵花 哈密瓜 柿子 荔枝 柚子 枣 芒果 樱桃 枇杷 火龙果 石榴 猕猴桃 圣女果 杨梅))
    @shucai = _parse_arr(%w(白菜 辣椒 大蒜 蒜薹 四季豆 土豆 小白菜 油麦菜 生菜 芦笋 蒜苗 茼蒿 西红柿 萝卜 大葱 冬瓜 韭菜 黄瓜 茄子 菜花 豆角 南瓜 芹菜 生姜 洋葱 甘蓝 香菜 西葫芦 菠菜 莴苣 莲藕 山药 芥菜 红薯 芋头 苦瓜 丝瓜 西兰花 木耳 香菇))
    @liangyou = _parse_arr(%w(大米 小麦 玉米 棉花 杂粮 大豆 花生 芝麻 菜籽 棉籽 菜油 花生油 芝麻油 棉油 豆油 棕榈油 玉米油 豆粕 菜粕 棉粕 花生粕 杂粕 ))
  end
  def six
    @shuiguo = _parse_arr(%w(苹果 香蕉 西瓜 甜瓜 梨 甘蔗 蜜桃 油桃 蜜桔 沙糖桔 椪柑 脐橙 山楂 葡萄 菠萝 草莓 龙眼 杏子 李子 核桃 板栗 葵花 哈密瓜 柿子 荔枝 柚子 枣 芒果 樱桃 枇杷 火龙果 石榴 猕猴桃 圣女果 杨梅)).to_a
    @shucai = _parse_arr(%w(白菜 辣椒 大蒜 蒜薹 四季豆 土豆 小白菜 油麦菜 生菜 芦笋 蒜苗 茼蒿 西红柿 萝卜 大葱 冬瓜 韭菜 黄瓜 茄子 菜花 豆角 南瓜 芹菜 生姜 洋葱 甘蓝 香菜 西葫芦 菠菜 莴苣 莲藕 山药 芥菜 红薯 芋头 苦瓜 丝瓜 西兰花 木耳 香菇)).to_a
    @liangyou = _parse_arr(%w(大米 小麦 玉米 棉花 杂粮 大豆 花生 芝麻 菜籽 棉籽 菜油 花生油 芝麻油 棉油 豆油 棕榈油 玉米油 豆粕 菜粕 棉粕 花生粕 杂粕 )).to_a
    @xumu = _parse_arr(%w(猪 牛 羊 马 驴 骡子 鸡 鸭 鹅 兔 蜂 骆驼 梅花鹿 孔雀 鹿 貂 蛇 水獭)).to_a
    @cats = {
      shuiguo: ['水果',@shuiguo],
      shucai: ['蔬菜',@shucai],
      xumu: ["畜牧 &middot; 特养",@xumu],
      liangyou: ['粮油 &middot; 饲料',@liangyou]
    }
  end
  def _parse_arr arr
    Hash[arr.collect{|r| [Pinyin.t(r,''),r]}]
  end
  def search
    @q = params[:q]
    if @q.blank? && params[:l].blank?
      redirect_to root_url
      return
    end
    @title = @q
    conditions = {}
    if params[:l].present?
      conditions[:location] = params[:l]
      @title = params[:l] + @q
    end
    @companies =  Company.search(
        @q.gsub(/、/,' '),
        :conditions=>conditions,
        :page=>params[:page] || 1,
        :include=>[:text],
        :sort_mode => :extended,
        :order => "@relevance DESC",
        :per_page => 25
        )
    @relates = Topic.search(@q,
                    match_mode: :any,per_page: 9)
    @province_counts = Company.facets(@q,facets: :province_id)[:province_id]
    @provinces = Province.where(id: @province_counts.keys)
    @provinces.each do |r|
      r[:companies_count] = @province_counts[r.id]
    end
    #@groups = Company.search(@q,:group_by=>:location,:order_group_by=>"count(*) desc")
    breadcrumbs.add @title,nil
  end
  def status
    @data = {
      :companies => Company.count,
      :entries => Entry.count,
      :topics => Topic.count
    }
    render :xml=>@data
  end
  def test
    render :text=>Company.fuwus
  end
  def city
    @title = "#{@city_title}黄页"
    @companies =  Company.search(
        :conditions=>{:location=>@city_title},
        :page=>params[:page] || 1,
        :include=>[:text],
        :sort_mode => :extended,
        :order => "@relevance DESC,id desc",
        :per_page => 10
        )

  end
  def cities
    if params[:dump]
      @results = {}
      CityHelper::CITIES[:china].keys.each do |state|
        @results[state.to_s] = {areaname: CGI.escape(I18n.t("states.#{state}")), slug: state.to_s,children: []}
        #@results[state.to_s] = {name: CGI.escape(I18n.t("states.#{state}")), slug: state.to_s}
      end
      CityHelper::CITIES[:china].each do |state,vals|
        vals.each do |v|
          @results[state.to_s][:children] << {areaname: CGI.escape(I18n.t("cities.#{v}")),slug: v.to_s}
          #@results[v.to_s] = {name: CGI.escape(I18n.t("cities.#{v}")),slug: v.to_s, parent: state.to_s}
        end
      end
      respond_to do |format|
        format.json { render json: CGI.unescape(@results.to_json) }
      end
    else
      @results = {}
      CityHelper::CITIES[:china].keys.each do |state|
        @results[CGI.escape(I18n.t("states.#{state}"))] = state.to_s
      end
      CityHelper::CITIES[:china].values.flatten.each do |state|
        @results[CGI.escape(I18n.t("cities.#{state}"))] = state.to_s
      end
      respond_to do |format|
        format.text {render :layout=>false}
        #format.text { render text: CGI.unescape(_join_cities(@results)) }
        format.json { render json: CGI.unescape(@results.to_json) }
      end
    end
  end
  def topic
    @name = params[:id]
    @title = @name
    @companies =  Company.search(
        @name.gsub(/、/,' '),
        :page=>params[:page] || 1,
        :include=>[:text],
        :sort_mode => :extended,
        :order => "@relevance DESC",
        :per_page => 25
        )
  end
  def _join_cities hash,a=':',b=','
    arr = []
    hash.each do |k,v|
      arr << "#{k}#{a}#{v}"
    end
    arr.join('|')
  end
end
