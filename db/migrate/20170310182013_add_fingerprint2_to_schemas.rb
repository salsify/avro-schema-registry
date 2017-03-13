class AddFingerprint2ToSchemas < ActiveRecord::Migration[5.0]
  def change
    add_column(:schemas, :fingerprint2, :string, null: true)
    add_index(:schemas, :fingerprint2, unique: true)

    remove_index(:schemas, :fingerprint)
    add_index(:schemas, :fingerprint, unique: false)
  end
end
