class TagsController < ApplicationController
  before_action :set_tag, only: %i[show]
  before_action :set_visible_tags

  def show
    authorize [:admin, @tag]
  end

  def create
    @tag = Current.tenant.tags.new(tag_params)
    @tag.user_id = Current.user.id
    @tag.groups << Current.user.user_group
    authorize @tag

    if @tag.save
      redirect_back fallback_location: message_threads_path, notice: 'Tag was successfully created'
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def tag_params
    params.require(:tag).permit(:name, message_threads_tags_attributes: [:message_thread_id])
  end

  def set_visible_tags
    @visible_tags = policy_scope(Tag).where(visible: true)
  end

  def set_tag
    @tag = policy_scope(Tag).find(params[:id])
  end
end
