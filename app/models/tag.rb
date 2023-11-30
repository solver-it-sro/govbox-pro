# == Schema Information
#
# Table name: tags
#
#  id          :bigint           not null, primary key
#  external    :boolean          default(FALSE)
#  name        :string           not null
#  system_name :string
#  visible     :boolean          default(TRUE), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  tenant_id   :bigint           not null
#  user_id     :bigint
#
class Tag < ApplicationRecord
  include AuditableEvents

  belongs_to :tenant
  belongs_to :owner, class_name: 'User', optional: true, foreign_key: :user_id
  has_many :tag_groups, dependent: :destroy
  has_many :groups, through: :tag_groups
  has_many :messages_tags, dependent: :destroy
  has_many :messages, through: :messages_tags
  has_many :message_threads_tags, dependent: :destroy
  has_many :message_threads, through: :message_threads_tags
  has_many :automation_actions, class_name: "Automation::Action", as: :action_object

  validates :name, presence: true
  validates :name, uniqueness: { scope: :tenant_id, case_sensitive: false }

  scope :visible, -> { where(visible: true) }

  after_create_commit ->(tag) { tag.mark_readable_by_groups([tag.tenant.admin_group]) }
  after_update_commit ->(tag) { EventBus.publish(:tag_renamed, tag) if previous_changes.key?("name") }
  before_destroy :validate_tag_usage

  DRAFT_SYSTEM_NAME = 'draft'

  def mark_readable_by_groups(groups)
    self.groups += groups
  end

  def validate_tag_usage
    return true if automation_actions.blank?

    errors.add :base, "Štítok je použitý v automatizačných pravidlách, nie je ho možné vymazať. Upravte najskôr pravidlá"
    throw :abort
  end
end
