class Medium < ApplicationRecord
  has_many :digest_locations, dependent: :destroy
  belongs_to :bucket
  validates_presence_of :bucket

  def add_digests
    add_hash_digests
    add_digest_locations
    update_term_frequency_in_medium
    bucket.update(amnt_digests: bucket.hash_digests.count)
    delete_temp_digests
  end

  private

  def add_hash_digests
    sql = "
    insert into hash_digests as hd (digest, bucket_id)
      select distinct digest, #{bucket_id} from temp_digests td
        where td.medium_id=#{id} on conflict (digest, bucket_id) do
          update set freq = hd.freq+1
    "
    ActiveRecord::Base.connection.execute(sql)
  end


  def update_term_frequency_in_medium
    sql = "
    CREATE TEMPORARY TABLE t (ct INTEGER, digest_id BIGINT not null primary key) ON COMMIT DROP;
    INSERT INTO t (ct, digest_id)
      (select count(dl2.id) as ct, dl2.hash_digest_id as digest_id
      from digest_locations dl2
      where dl2.medium_id=#{id}
      group by dl2.hash_digest_id);
    UPDATE digest_locations dl set tf = t.ct
    from t where dl.medium_id = #{id} and t.digest_id = dl.hash_digest_id
    "
    ActiveRecord::Base.connection.execute(sql)
  end

  def add_digest_locations
    sql = "insert into digest_locations as dl (created_at, updated_at, medium_id, hash_digest_id, time_offset_ms)
    select NOW(), NOW(), #{id}, hd.id, td.time_offset_ms from temp_digests td
    inner join hash_digests hd on hd.digest = td.digest
    and td.medium_id=#{id}"
    ActiveRecord::Base.connection.execute(sql)
  end

  def delete_temp_digests
    sql = "delete from temp_digests where medium_id=#{id}"
    ActiveRecord::Base.connection.execute(sql)
  end

end

