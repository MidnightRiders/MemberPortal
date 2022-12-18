# Application-wide helper module.
module ApplicationHelper

  # Returns *ActiveRecord Object* for the Revolution.
  def revs
    Club.includes(:home_matches, :away_matches).find_by(abbrv: 'NE')
  end

  # Outputs a +<small/>+ with errors if errors are present on the object
  def errors_for(object, method)
    if object.errors[method].any?
      content_tag :small, "#{object.class.human_attribute_name(method)} #{object.errors[method].to_sentence}", class: 'error'
    end
  end

  # Receives JavaScript for output
  def enqueue_javascript(*files)
    @javascript_files = ((@javascript_files || []) + [files]).flatten.uniq
  end

  # Outputs JavaScript
  def render_javascript
    javascript_include_tag *@javascript_files if @javascript_files
  end

  def icon(set, name)
    content_tag :i, '', class: "#{set} fa-#{name}", 'aria-hidden': true
  end
end
