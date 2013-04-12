#require 'city_helper'
def logm arr
  pp arr if Rails.env.test?
  Rails.logger.debug arr

end
require 'ali'
ENV['WORDS_FILE'] = "#{Rails.root}/config/words.dat"
#require 'yaml'
#YAML::ENGINE.yamler= 'psych'
