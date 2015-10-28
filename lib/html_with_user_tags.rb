class HTMLWithUserTags < Redcarpet::Render::HTML
  def preprocess(text)
    wrap_user_tags(text)
  end

  def wrap_user_tags(text)
    text.gsub /(?<=^|\s)@([\w\-]{5,})/, '<a href="/users/\1">@\1</a>'
  end
end
