# == Schema Information
#
# Table name: tags
#
#  id          :bigint           not null, primary key
#  external    :boolean          default(FALSE)
#  name        :string           not null
#  system_name :string
#  type        :string           not null
#  visible     :boolean          default(TRUE), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  owner_id    :bigint
#  tenant_id   :bigint           not null
#
class DeliveryNotificationTag < Tag
  def name
    I18n.t("tag.names.delivery_notification")
  end
end
