class MessageThreads::TagsController < ApplicationController
  before_action :set_message_thread

  def edit
    authorize MessageThreadsTag

    @tags_changes = TagsChanges.build_with_new_assignments(
      message_thread: @message_thread,
      tag_scope: tag_scope,
    )
    @tags_filter = TagsFilter.new(tag_scope: tag_scope)
  end

  def prepare
    authorize MessageThreadsTag

    @tags_changes = TagsChanges.build_from_assignments(
      message_thread: @message_thread,
      tag_scope: tag_scope,
      tags_assignments: tags_assignments
    )
    @tags_filter = TagsFilter.new(tag_scope: tag_scope, filter_query: params[:name_search_query].strip)
    @rerender_list = params[:assignments_update].blank?
  end

  def create_tag
    new_tag = Tag.new(tag_creation_params.merge(name: params[:new_tag].strip))
    authorize(new_tag, "create?")

    @tags_changes = TagsChanges.new(
      message_thread: @message_thread,
      tag_scope: tag_scope,
      tags_assignments: tags_assignments
    )

    @tags_changes.add_new_tag(new_tag) if new_tag.save
    @tags_changes.build_diff

    @tags_filter = TagsFilter.new(tag_scope: tag_scope, filter_query: "")
    @rerender_list = true
    @reset_search = true

    render :prepare
  end

  def update
    authorize MessageThreadsTag

    tag_changes = TagsChanges.new(
      message_thread: @message_thread,
      tag_scope: tag_scope,
      tags_assignments: tags_assignments
    )

    tag_changes.save

    # status: 303 is needed otherwise PATCH is kept in the following redirect https://apidock.com/rails/ActionController/Redirecting/redirect_to
    redirect_to message_thread_path(@message_thread), notice: "Priradenie štítkov bolo upravené", status: 303
  end

  private

  def set_message_thread
    @message_thread = message_thread_policy_scope.find(params[:message_thread_id])
  end

  def tag_scope
    Current.tenant.tags.visible.order(:name)
  end

  def message_thread_policy_scope
    policy_scope(MessageThread)
  end

  def tags_assignments
    params.require(:tags_assignments).permit(init: {}, new: {})
  end

  def tag_creation_params
    {
      owner: Current.user,
      tenant: Current.tenant,
      groups: [Current.user.user_group]
    }
  end
end
