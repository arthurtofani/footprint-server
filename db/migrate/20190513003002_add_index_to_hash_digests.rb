class AddIndexToHashDigests < ActiveRecord::Migration[5.2]
  def change
    add_index(:hash_digests, :digest, using: 'btree')
  end
end
