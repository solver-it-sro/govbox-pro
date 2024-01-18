# == Schema Information
#
# Table name: boxes
#
#  id                :bigint           not null, primary key
#  color             :enum
#  name              :string           not null
#  settings          :jsonb
#  short_name        :string
#  syncable          :boolean          default(TRUE), not null
#  uri               :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  api_connection_id :bigint
#  tenant_id         :bigint           not null
#
class Box < ApplicationRecord
  include Colorized

  belongs_to :tenant
  belongs_to :api_connection

  has_many :message_threads, extend: MessageThreadsExtensions, dependent: :destroy
  has_many :messages, through: :message_threads
  has_many :message_drafts_imports, dependent: :destroy
  has_many :automation_conditions, as: :condition_object

  after_destroy do |box|
    api_connection.destroy if api_connection.destroy_with_box?
    EventBus.publish(:box_destroyed, box.id)
  end

  before_create { self.color = Box.colors.keys[name.hash % Box.colors.size] if color.blank? }

  validates_presence_of :name, :short_name, :uri
  validates_uniqueness_of :name, :short_name, :uri, scope: :tenant_id
  validate :validate_box_with_api_connection

  store_accessor :settings, :obo, prefix: true # TODO: move to Govbox::Box superclass?

  def self.create_with_api_connection!(params)
    if params[:api_connection]
      # TODO: leak Govbox domeny doriesit
      api_connection = Govbox::ApiConnection.create!(params[:api_connection])
    elsif params[:api_connection_id]
      api_connection = ApiConnection.find(params[:api_connection_id])
    end
    raise ArgumentError, "Api connection must be provided" unless api_connection

    api_connection.boxes.create!(params.except(:api_connection))
  end

  def sync
    Govbox::SyncBoxJob.perform_later(self)
  end

  def self.sync_all
    find_each(&:sync)
  end

  private

  def validate_box_with_api_connection
    errors.add(:api_connection, :invalid) if api_connection.tenant && (api_connection.tenant != tenant)

    api_connection.validate_box(self)
  end
end
