class CustomIndexDelta
  @queue = "daemon"
  def self.perform
    ThinkingSphinx.suppress_delta_output = true
    ThinkingSphinx::Deltas::DatetimeDelta.index
  end
end
