module ResqueEx
  def self.included base
    base.extend ClassMethods
  end
  def async(method, *args)
    Resque.enqueue(self.class, id,method, *args)
  end
  module ClassMethods
    def perform id,method,*args
      find(id).send(method, *args)
    end
  end
end
