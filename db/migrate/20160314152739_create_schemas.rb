class CreateSchemas < ActiveRecord::Migration[5.0]
  def change
    create_table(:schemas, id: :bigserial) do |t|
      t.string :fingerprint, null: false
      t.text :json, null: false
      t.timestamps null: false
    end

    add_index(:schemas, :fingerprint, unique: true)
  end
end
