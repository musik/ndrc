module EntriesHelper
  def clean_body text
    text = text.gsub(/\n|\t|\r/,'').gsub(/&nbsp;/,'')
    text = text.gsub(/\\n|\\t/,'')
    sanitize(text,tags: %w(p table tr td))
  end
  def clean_excerpt text
    text = text.gsub(/\\n|\\t/,'').gsub(/&nbsp;/,'')
    sanitize(text,tags: %w())
  end
end
