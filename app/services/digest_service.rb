class DigestService
  def initialize(bucket, digests, threshold=9.5)
    @bucket = bucket
    @digests = digests.map{|s| s.split(':')}.map{|s| [s.first, s.last.to_i]}
    @stopwords_threshold = threshold
  end

  def search
    return search_tf_idf

#    locations = {}
#
#    hash_digests = @bucket.hash_digests.includes(:digest_locations).where(digest: @digests.map{|s| s[0]})
#    digests_dict = hash_digests.map{|s| [s.digest, s]}.to_h
#
#    @digests.each do |digest_str, timestamp_str|
#      hash_digest = digests_dict[digest_str]
#      unless hash_digest.nil?
#        hash_digest.digest_locations.each do |location|
#          locations[location.medium_id] ||=[]
#          locations[location.medium_id] << [
#                                              hash_digest.digest,
#                                              location.time_offset_ms,
#                                              timestamp_str.to_i
#                                            ]
#        end
#      end
#    end
#    media_dict = @bucket.media.where(id: locations.keys).pluck(:id, :path).to_h
#    new_locations = locations.to_a.map{|s| [media_dict[s[0]], s[1]]}.to_h
#    new_locations
  end

  def db_size
    #sql = "SELECT pg_size_pretty(pg_database_size('footprint_development'))"
    #b = ActiveRecord::Base.connection.execute(sql).to_a
  end

  def search_tf_idf
    digests  = @digests.map{|s| "('#{s[0]}')"}.uniq.join(',')
    return {} if digests.blank?

    create_table_sql = "
    CREATE TEMPORARY TABLE T (digest VARCHAR (10) not null primary key) ON COMMIT DROP;
    INSERT INTO T(digest)
    VALUES #{digests};\n
    "

    sql = "
        #{create_table_sql}
        select distinct m.id, m.path, d.digest, d.freq,
        dl.tf as tf, dl.time_offset_ms,
        log(10, #{digests_in_bucket.to_f}/d.freq) as idf,
        dl.tf*log(10, #{digests_in_bucket.to_f}/d.freq) as tf_idf
        from media m
        inner join digest_locations dl on dl.medium_id = m.id
        inner join hash_digests d on dl.hash_digest_id = d.id
        join T on T.digest = d.digest AND d.freq > 0
        where m.bucket_id = #{@bucket.id}
        and dl.tf*log(10, #{digests_in_bucket.to_f}/d.freq) > #{@stopwords_threshold}
        order by tf_idf desc
    "
    # note: it's better to remove this `and d.freq > 0`
    b = ActiveRecord::Base.connection.execute(sql).to_a
    b.inject({}){|h, s| h[s['path']]||=[]; h[s['path']] << s.except('path'); h}
  end

  def digests_in_bucket
    @digests_in_bucket ||= @bucket.amnt_digests
  end

end
