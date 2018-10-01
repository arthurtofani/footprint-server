class Medium < ApplicationRecord
  has_many :digest_locations

  def add_digests(digest_list)
    digest_list.map{|s| s.split(':')}.each do |digest_str, timestamp_str|
      hash_digest = HashDigest.find_or_create_by(digest: digest_str)
      digest_locations.create(hash_digest: hash_digest, time_offset_ms: timestamp_str.to_i)
    end
  end


end
