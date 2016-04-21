class CreateConfigs < ActiveRecord::Migration
  def change
    create_table :configs do |t|
      t.string :name, null: false
      t.text :value, null: false
      t.timestamps null: false
    end

    add_index(:configs, :name, unique: true)
  end
end
