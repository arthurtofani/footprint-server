class TfIdfService
  def initialize(medium)
    @medium = medium
    #binding.pry
    #@affected_digests_ids = @medium.digest_locations.pluck(:hash_digest_id).uniq
  end

  def tf_idf
    sql = "select distinct t1.id, t1.digest, t1.freq,
    log(10, #{digests_in_bucket.to_f}/t1.freq) as idf,
    t2.tf as tf,
    tf*log(10, #{digests_in_bucket.to_f}/t1.freq) as tf_idf
    from hash_digests t1
    inner join digest_locations t2
    on t1.id=t2.hash_digest_id
    and t2.medium_id=#{@medium.id}
    order by tf_idf desc"
    ActiveRecord::Base.connection.execute(sql)
  end

  def digests_in_bucket
    @digests_in_bucket ||= @medium.bucket.hash_digests.count
  end

  def term_frequencies
    sql = "select t1.hash_digest_id, count(id) as tf from digest_locations t1 where medium_id=#{@medium.id} group by t1.hash_digest_id"
    ActiveRecord::Base.connection.execute(sql)
  end

  def update!
    update_digest_locations_frequencies
    #update_digests_frequencies_in_documents
    @medium.reload
  end



  def update_digests_frequencies_in_documents
    bid = @medium.bucket.id
    sql2 = "select t.hash_digest_id, count(t.medium_id) as ct from (select distinct hash_digest_id, medium_id from digest_locations t1) t
    inner join digest_locations dl on dl.hash_digest_id = t.hash_digest_id
    group by t.hash_digest_id"
    sql = "update hash_digests t1 set freq = t2.ct from (#{sql2}) as t2 where t1.id = t2.hash_digest_id and t1.bucket_id = #{bid}"
    data = ActiveRecord::Base.connection.execute(sql)
  end

  private

  def update_digest_locations_frequencies
    sql2 = "select hash_digest_id, count(id) as ct from digest_locations where medium_id=#{@medium.id} group by 1"
    sql = "update digest_locations t1 set tf = t2.ct
    from (#{sql2}) as t2 where t1.hash_digest_id = t2.hash_digest_id and t1.medium_id = #{@medium.id}"


    #data = ActiveRecord::Base.connection.execute(sql)
  end
end


# analise do buket
# DigestLocation.joins(:medium).where('media.bucket_id= 2').pluck(:hash_digest_id).inject({}){|h, s| h[s]||= 0; h[s]+=1; h}.to_a.sort{|a, b| a.last<=>b.last }.reverse.map.with_index{|a, i| [i+1, a.last]}
