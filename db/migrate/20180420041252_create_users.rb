class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.text :name
      t.text :email
      t.text :image
      t.string :password_digest
      t.text :location
      t.boolean :admin, default: false

      t.timestamps
    end
  end
end
