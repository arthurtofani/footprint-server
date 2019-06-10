class AddIndexToTempDigests < ActiveRecord::Migration[5.2]
  def change
    add_column(:temp_digests, :time_offset_ms, :integer)
    #add_index(:temp_digests, :medium_id, using: 'btree')
    add_index(:temp_digests, :digest, using: 'btree')
  end
end
