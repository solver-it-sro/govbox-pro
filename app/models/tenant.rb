# == Schema Information
#
# Table name: tenants
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Tenant < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :groups, dependent: :destroy

  has_one :all_group
  has_one :signer_group
  has_one :admin_group
  has_many :custom_groups

  has_one :delivery_notification_tag
  has_one :draft_tag

  has_many :boxes, dependent: :destroy
  has_many :automation_rules, class_name: "Automation::Rule", dependent: :destroy
  has_many :tags, dependent: :destroy
  has_many :filters
  after_create :create_default_objects

  validates_presence_of :name

  private

  def create_default_objects
    create_all_group!(name: "all")
    create_admin_group!(name: "admins")
    create_signer_group!(name: "signers")
    create_draft_tag!(name: "drafts", visible: true)
    create_delivery_notification_tag!(name: "delivery notification", visible: true)
  end
end
