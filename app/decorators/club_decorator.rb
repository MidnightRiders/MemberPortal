class ClubDecorator < Draper::Decorator
  delegate_all

  def formatted_record(link = true)
    if link
      h.link_to model.record, model, title: 'W-L-D. Click to view club.'
    else
      h.content_tag :span, model.record, title: 'W-L-D'
    end
  end

end
