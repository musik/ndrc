class CustomIndexDelta
  def self.perform
    ThinkingSphinx::Deltas::DatetimeDelta.index
  end
end
