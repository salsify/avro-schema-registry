class CreateConfigs < ActiveRecord::Migration[5.0]
  def change
    create_table(:configs, id: :bigserial) do |t|
      t.string :compatibility
      t.timestamps null: false
      t.bigint :subject_id
    end

    add_index(:configs, :subject_id, unique: true)
  end
end
