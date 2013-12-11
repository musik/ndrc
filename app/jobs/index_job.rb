class IndexJob
  @queue = "daemon"
  def self.perform
    Bot1688::Index.new.fetch_all
  end
end
