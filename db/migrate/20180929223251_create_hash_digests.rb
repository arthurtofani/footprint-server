class CreateHashDigests < ActiveRecord::Migration[5.2]
  def change
    create_table :hash_digests do |t|
      t.string :digest, null: false
    end
    #add_index(:hash_digests, [:digest, :bucket_id], using: 'btree', unique: true)
  end
end
