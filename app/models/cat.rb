#encoding: utf-8
class Cat < ActiveRecord::Base
  attr_accessible :name, :priority, :slug,:recommended
  has_many :topics
  def topic_names(level = nil)
    conditions = level.nil? ? nil : "level = #{level}"
    id.present? ? topics.where(conditions).order("priority asc").pluck(:name).join(" ") : nil
  end
  def recommended_topics
    if recommended
      names = recommended.split(" ").compact
      @topics = topics.where(level: 1).all.to_a
      @topics = Hash[@topics.collect{|r| [r.name,r]}]
      Hash[names.collect{|r| [r,@topics[r]]}]
    end
  end
end
