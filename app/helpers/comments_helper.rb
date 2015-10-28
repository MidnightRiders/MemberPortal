module CommentsHelper
  def comment_context
    if @parent != @discussion
      [ @discussion, @parent, @comment ]
    else
      [ @parent, @comment ]
    end
  end
end
