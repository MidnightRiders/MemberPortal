class DiscussionsController < ApplicationController
  load_and_authorize_resource

  # GET /discussions
  # GET /discussions.json
  def index
    @discussions = Discussion.all.load

  end

  # GET /discussions/1
  # GET /discussions/1.json
  def show
    current_user.post_views.find_or_create_by(post: @discussion)
  end

  # GET /discussions/new
  def new
    @discussion = Discussion.new
  end

  # GET /discussions/1/edit
  def edit
  end

  # POST /discussions
  # POST /discussions.json
  def create
    @discussion = Discussion.new(discussion_params.merge(user_id: current_user.id))

    respond_to do |format|
      if @discussion.save
        format.html { redirect_to @discussion, notice: 'Discussion was successfully created.' }
        format.json { render action: 'show', status: :created, location: @discussion }
      else
        format.html { render action: 'new' }
        format.json { render json: @discussion.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /discussions/1
  # PATCH/PUT /discussions/1.json
  def update
    respond_to do |format|
      if @discussion.update(discussion_params)
        format.html { redirect_to @discussion, notice: 'Discussion was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @discussion.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /discussions/1
  # DELETE /discussions/1.json
  def destroy
    @discussion.destroy
    respond_to do |format|
      format.html { redirect_to discussions_url }
      format.json { head :no_content }
    end
  end

  # POST /discussions/1/comments/1/upvote
  # POST /discussions/1/comments/1/upvote.json
  def upvote
    if @discussion.upvote(current_user.id)
      respond_to do |format|
        format.html { redirect_to @discussion }
        format.any(:js, :json) { render json: { html: render_to_string(partial: 'shared/votes', locals: { obj: @discussion }) }, status: :ok }
      end
    else
      raise 'Could not save upvote'
    end
  end

  # POST /discussions/1/comments/1/downvote
  # POST /discussions/1/comments/1/downvote.json
  def downvote
    if @discussion.downvote(current_user.id)
      respond_to do |format|
        format.html { redirect_to @discussion }
        format.any(:js, :json) { render json: { html: render_to_string(partial: 'shared/votes', locals: { obj: @discussion }) }, status: :ok }
      end
    else
      raise 'Could not save upvote'
    end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def discussion_params
      params.require(:discussion).permit(:title, :content, :match_id)
    end
end
