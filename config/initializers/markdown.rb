require 'html_with_user_tags'

MD_RENDERER = Redcarpet::Markdown.new(
  HTMLWithUserTags.new({
    no_styles: true,
    safe_links_only: true,
    prettify: true,
    with_toc_data: true
  }), {
  tables: true,
  autolink: true,
  strikethrough: true,
  superscript: true
})
