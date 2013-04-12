class Snip < ActiveRecord::Base
  attr_accessible :data, :name
  class << self
    def get name
      find_by_name(name).data rescue ""
    end
  end
end
