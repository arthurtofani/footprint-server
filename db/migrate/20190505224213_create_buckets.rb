class CreateBuckets < ActiveRecord::Migration[5.2]
  def change
    create_table :buckets do |t|
      t.string :slug
      t.timestamps
    end
    add_index :buckets, :slug

    add_reference :media, :bucket, index: true, foreign_key: {on_delete: :cascade}
    add_reference :hash_digests, :bucket, index: true, foreign_key: {on_delete: :cascade}
    add_index(:hash_digests, [:digest, :bucket_id], using: 'btree', unique: true)
  end
end
