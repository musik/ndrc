module ResqueEx
  def self.included base
    base.extend ClassMethods
  end
  def async(method, *args)
    Resque.enqueue(self.class, method, *args)
  end
  module ClassMethods
    def perform method,*args
      new.send(method, *args)
    end
  end
end
