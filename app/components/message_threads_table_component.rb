class MessageThreadsTableComponent < ViewComponent::Base
  renders_many :message_threads
  renders_one :next_page_area

  def initialize(filter:, filter_subscription:)
    @filter = filter
    @filter_subscription = filter_subscription
  end
end
