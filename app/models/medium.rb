class Medium < ApplicationRecord
  has_many :digest_locations, dependent: :destroy
  belongs_to :bucket
  validates_presence_of :bucket

  def add_digests(digest_list)
    digests = digest_list.map{|s| s.split(':')[0]}.uniq
    HashDigest.import([:digest, :bucket_id], digests.map{|s| [s, bucket.id]}, ignore: true)

    digest_id_dict = bucket.hash_digests.where(digest: digests).map{|s| [s.digest, s.id]}.to_h
    locations = digest_list.map{|s| s.split(':')}.map do |digest_str, timestamp_str|
      [self.id, digest_id_dict[digest_str], timestamp_str.to_i]
    end
    DigestLocation.import([:medium_id, :hash_digest_id, :time_offset_ms], locations)
    TfIdfService.new(self).update!
    nil
  end


end
