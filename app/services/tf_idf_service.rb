class TfIdfService
  def initialize(media)
    @media = media
    @affected_digests_ids = @media.digest_locations.pluck(:hash_digest_id).uniq
  end

  def tf_idf
    sql = "select distinct t1.id, t1.digest, t1.freq,
    log(10, #{digests_in_bucket.to_f}/t1.freq) as idf,
    t2.tf as tf,
    tf*log(10, #{digests_in_bucket.to_f}/t1.freq) as tf_idf
    from hash_digests t1
    inner join digest_locations t2
    on t1.id=t2.hash_digest_id
    and t2.medium_id=#{@media.id}
    order by tf_idf desc"
    ActiveRecord::Base.connection.execute(sql)
  end

  def digests_in_bucket
    @digests_in_bucket ||= @media.bucket.hash_digests.count
  end

  def term_frequencies
    sql = "select t1.hash_digest_id, count(id) as tf from digest_locations t1 where medium_id=#{@media.id} group by t1.hash_digest_id"
    ActiveRecord::Base.connection.execute(sql)
  end

  def update!
    update_digest_locations_frequencies
    update_digests_frequencies_in_documents
    @media.reload
  end


  private

  def update_digests_frequencies_in_documents
    bid = @media.bucket.id
    sql2 = "select x1.hash_digest_id, count(x1.id) as ct from digest_locations x1 inner join media x2 on x1.medium_id = x2.id where bucket_id=#{bid} and hash_digest_id in (#{@affected_digests_ids.join(',')}) group by hash_digest_id, medium_id"
    sql = "update hash_digests t1 set freq = t2.ct from (#{sql2}) as t2 where t1.id = t2.hash_digest_id and t1.bucket_id = #{bid}"
    data = ActiveRecord::Base.connection.execute(sql)
  end

  def update_digest_locations_frequencies
    sql2 = "select hash_digest_id, count(id) as ct from digest_locations where medium_id=#{@media.id} group by 1"
    sql = "update digest_locations t1 set tf = t2.ct
    from (#{sql2}) as t2 where t1.hash_digest_id = t2.hash_digest_id and t1.medium_id = #{@media.id}"
    data = ActiveRecord::Base.connection.execute(sql)
  end
end
