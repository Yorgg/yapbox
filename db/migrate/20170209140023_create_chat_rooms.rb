class CreateChatRooms < ActiveRecord::Migration[5.0]
  def change
    create_table :chat_rooms do |t|
      t.text :title
      t.text :secret
      t.datetime :timeout

      t.timestamps
    end
  end
end
