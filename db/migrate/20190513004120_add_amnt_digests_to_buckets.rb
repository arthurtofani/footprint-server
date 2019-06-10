class AddAmntDigestsToBuckets < ActiveRecord::Migration[5.2]
  def change
    add_column :buckets, :amnt_digests, :integer, default: 0
    add_index :hash_digests, :freq
  end

end
