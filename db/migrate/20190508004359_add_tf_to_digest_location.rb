class AddTfToDigestLocation < ActiveRecord::Migration[5.2]
  def change
    add_column :digest_locations, :tf, :integer
  end
end
