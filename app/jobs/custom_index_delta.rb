class CustomIndexDelta
  @queue = "daemon"
  def self.perform
    ThinkingSphinx::Deltas::DatetimeDelta.index
  end
end
