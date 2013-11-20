class CustomIndexDelta
  def perform
    ThinkingSphinx::Deltas::DatetimeDelta.index
  end
end
