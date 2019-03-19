class DigestService
  def initialize(digests)
    @digests = digests.map{|s| s.split(':')}.map{|s| [s.first, s.last.to_i]}
  end

  def search
    get_locations
  end

  def get_locations
    locations = {}

    hash_digests = HashDigest.includes(:digest_locations).where(digest: @digests.map{|s| s[0]})
    digests_dict = hash_digests.map{|s| [s.digest, s]}.to_h

    @digests.each do |digest_str, timestamp_str|
      hash_digest = digests_dict[digest_str]
      unless hash_digest.nil?
        hash_digest.digest_locations.each do |location|
          locations[location.medium_id] ||=[]
          locations[location.medium_id] << [
                                              hash_digest.digest,
                                              location.time_offset_ms,
                                              timestamp_str.to_i
                                            ]
      end
      end
    end
    media_dict = Medium.where(id: locations.keys).pluck(:id, :path).to_h

    new_locations = locations.to_a
                      .map{|s| [media_dict[s[0]], s[1]]}.to_h

    new_locations
  end
end
