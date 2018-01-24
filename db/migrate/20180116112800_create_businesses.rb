class CreateBusinesses < ActiveRecord::Migration
  def change
    create_table :businesses do |t|
      t.string :offer, {null: false}
      t.string :description
      t.integer :creator_id, {null: false}

      t.timestamps null: false
    end
    add_index :businesses, :creator_id
  end
end
