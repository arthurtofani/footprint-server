class AddIdfToHashDigest < ActiveRecord::Migration[5.2]
  def change
    add_column :hash_digests, :freq, :integer, default: 1
  end
end
