class EmailDecorator < Draper::Decorator
  delegate_all

  def format(content)
    content
      .gsub(/[‘’“”–—…éëèç]/, {
        :'‘' => '&lsquo;',
        :'’' => '&rsquo;',
        :'“' => '&ldquo;',
        :'”' => '&rdquo;',
        :'–' => '&ndash;',
        :'—' => '&mdash;',
        :'…' => '&hellip;',
        :'é' => '&eacute;',
        :'ë' => '&euml;',
        :'è' => '&egrave;',
        :'ç' => '&ccedil;'
      })
      .gsub(/\-\-\-/,'&mdash;')
      .gsub(/\-\-/,'&ndash;')
      .gsub(/(<a href=['"][^'"]+?['"])>/,
        "$1 style=\"color: #881144; text-decoration: none; border-bottom: 1px dashed #881144; margin-bottom: -1px;\">"
      )
  end

  def styled_link(text, link, options={})
    options.merge!({ style: 'color: #881144; text-decoration: none; border-bottom: 1px dashed #881144; margin-bottom: -1px;' })
    h.link_to text, link, options
  end

end
