class AddIdfToHashDigest < ActiveRecord::Migration[5.2]
  def change
    add_column :hash_digests, :freq, :integer, default: 0
  end
end
