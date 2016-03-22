class CreateSchemaVersions < ActiveRecord::Migration
  def change
    create_table(:schema_versions, id: :bigserial) do |t|
      t.integer :version, default: 1
      t.bigint :subject_id, null: false
      t.bigint :schema_id, null: false
    end

    add_index(:schema_versions, [:subject_id, :version], unique: true)
  end
end
