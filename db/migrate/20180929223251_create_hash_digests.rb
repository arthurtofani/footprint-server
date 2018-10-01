class CreateHashDigests < ActiveRecord::Migration[5.2]
  def change
    create_table :hash_digests do |t|
      t.string :digest, :options => 'PRIMARY KEY', null: false
    end
    add_index(:hash_digests, :digest, using: 'btree')
  end
end
