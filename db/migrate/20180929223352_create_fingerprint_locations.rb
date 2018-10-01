class CreateFingerprintLocations < ActiveRecord::Migration[5.2]
  def change
    create_table :digest_locations do |t|
      t.integer :time_offset_ms
      t.references :hash_digest, foreign_key: true
      t.references :medium, foreign_key: true

      t.timestamps
    end
  end
end
