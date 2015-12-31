class CommentsController < ApplicationController
  before_action :get_discussion, only: [ :new, :edit, :create, :update, :upvote, :downvote ]
  before_action :get_parent, only: [ :new, :edit, :create, :update, :upvote, :downvote ]
  load_and_authorize_resource

  # GET /discussions/1/comments/new
  def new
    @comment = @parent.comments.new
  end

  # GET /discussions/1/comments/1/edit
  def edit
  end

  # POST /discussions/1/comments/
  # POST /discussions/1/comments/.json
  def create
    @comment = @discussion.comments.new(comment_params.merge(user_id: current_user.id, comment_id: @parent.id))

    respond_to do |format|
      if @comment.save
        format.html { redirect_to @discussion, notice: 'Comment was successfully created.' }
        format.json { render action: 'show', status: :created, location: @comment }
      else
        format.html { render action: 'new' }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /discussions/1/comments/1
  # PATCH/PUT /discussions/1/comments/1.json
  def update
    respond_to do |format|
      if @comment.update(comment_params)
        format.html { redirect_to @comment, notice: 'Comment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /discussions/1/comments/1
  # DELETE /discussions/1/comments/1.json
  def destroy
    @comment.destroy
    respond_to do |format|
      format.html { redirect_to comments_url }
      format.json { head :no_content }
    end
  end

  # POST /discussions/1/comments/1/upvote
  # POST /discussions/1/comments/1/upvote.json
  def upvote
    if @comment.upvote(current_user.id)
      respond_to do |format|
        format.html { redirect_to @discussion }
        format.any(:js, :json) { render json: { html: render_to_string(partial: 'shared/votes', locals: { obj: @comment }) }, status: :ok }
      end
    else
      raise 'Could not save upvote'
    end
  end

  # POST /discussions/1/comments/1/downvote
  # POST /discussions/1/comments/1/downvote.json
  def downvote
    if @comment.downvote(current_user.id)
      respond_to do |format|
        format.html { redirect_to @discussion }
        format.any(:js, :json) { render json: { html: render_to_string(partial: 'shared/votes', locals: { obj: @comment }) }, status: :ok }
      end
    else
      raise 'Could not save upvote'
    end
  end

  private

    def get_discussion
      @discussion = Discussion.find(params[:discussion_id])
    end

    def get_parent
      if params[:comment_id].present?
        @parent = Comment.find(params[:comment_id])
      else params[:discussion_id].present?
        @parent = @discussion
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def comment_params
      params.require(:comment).permit(:content)
    end
end
