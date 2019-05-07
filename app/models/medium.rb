class Medium < ApplicationRecord
  has_many :digest_locations, dependent: :destroy
  belongs_to :bucket
  validates_presence_of :bucket

  def add_digests(digest_list)
    digests = digest_list.map{|s| s.split(':')[0]}.uniq
    existing_digests = bucket.hash_digests.where(digest: digests).pluck(:digest)
    digest_create_list = digests - existing_digests
    HashDigest.import([:digest, :bucket_id], digest_create_list.map{|s| [s, bucket.id]}, ignore: true)
    digest_id_dict = HashDigest.where(digest: digests).map{|s| [s.digest, s.id]}.to_h
    locations = digest_list.map{|s| s.split(':')}.map do |digest_str, timestamp_str|
      [self.id, digest_id_dict[digest_str], timestamp_str.to_i]
    end
    DigestLocation.import([:medium_id, :hash_digest_id, :time_offset_ms], locations)
  end


end
