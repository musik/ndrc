class ImportTopics
  @queue = "daemon"
  def self.perform
    Topic.import_from_csv
  end
  def self.run
    Resque.enqueue ImportTopics
  end
end
