class PopulateFingerprint2 < ActiveRecord::Migration[5.0]

  class Schema < ApplicationRecord
  end

  def up
    Schema.find_each(batch_size: 100) do |schema|
      schema.update_attribute(
        :fingerprint2,
        Schemas::FingerprintGenerator.generate_v2(schema.json))
    end
  end

  def down
    Schema.update_all(fingerprint2: nil)
  end
end
