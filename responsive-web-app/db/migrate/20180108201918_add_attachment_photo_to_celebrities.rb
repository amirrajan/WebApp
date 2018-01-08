class AddAttachmentPhotoToCelebrities < ActiveRecord::Migration[5.1]
  def self.up
    change_table :celebrities do |t|
      t.attachment :photo
    end
  end

  def self.down
    remove_attachment :celebrities, :photo
  end
end
