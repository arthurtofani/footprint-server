class CreateTempDigests < ActiveRecord::Migration[5.2]
  def change
    create_table :temp_digests do |t|
      t.references :medium, foreign_key: true
      t.string :digest
      t.timestamps
    end
  end
end
