# == Schema Information
#
# Table name: message_objects
#
#  id                                          :integer          not null, primary key
#  name                                        :string           not null
#  encoding                                    :string           not null
#  mimetype                                    :string           not null
#  signed                                      :boolean
#  object_type                                 :string           not null
#  message_id                                  :datetime         not null
#  created_at                                  :datetime         not null
#  updated_at                                  :datetime         not null

class MessageObject < ApplicationRecord
  belongs_to :message
  has_one :message_object_datum

  def self.create_message_objects(message, objects)
    objects.each do |raw_object|
      message_object = MessageObject.create!(
        message: message,
        name: raw_object.original_filename,
        mimetype: Utils.detect_mime_type(entry_name: raw_object.original_filename),
        is_signed: false, #TODO detect if signed
        object_type: "ATTACHMENT"
      )

      MessageObjectDatum.create!(
        message_object: message_object,
        blob: raw_object.read.force_encoding("UTF-8")
      )
    end
  end
end
