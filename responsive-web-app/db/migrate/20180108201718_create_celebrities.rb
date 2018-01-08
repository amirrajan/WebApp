class CreateCelebrities < ActiveRecord::Migration[5.1]
  def change
    create_table :celebrities do |t|
      t.string :name
      t.string :bio
      t.string :twitter
      t.string :website

      t.timestamps
    end
  end
end
