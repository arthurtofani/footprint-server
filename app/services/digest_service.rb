class DigestService
  def initialize(digests)
    @digests = digests.map{|s| s.split(':')}.map{|s| [s.first, s.last.to_i]}
  end

  def search
    get_locations
  end

  def get_locations
    locations = {}
    @digests.each do |digest_str, timestamp_str|
      hash_digest = (HashDigest.find_by_digest(digest_str) rescue nil)
      if hash_digest.present?
        hash_digest.digest_locations.each do |location|
          # TODO: best to use is medium.path otherwise it does more queries
          locations[location.medium.path] ||=[]
          locations[location.medium.path] << [
                                              digest_str,
                                              location.time_offset_ms,
                                              timestamp_str.to_i
                                            ]
        end
      end
    end
    locations
  end
end
