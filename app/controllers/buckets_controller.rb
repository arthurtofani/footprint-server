class BucketsController < ApplicationController
  before_action :get_bucket, except: [:index]

  def index
    @buckets = Bucket.all
    render json: @buckets
  end

  def show
    render json: @bucket
  end

  def query
    result = DigestService.new(@bucket, params[:digests], params[:stopwords_threshold]).search
    render json: result
  end

  def integrity
    bef = @bucket.hash_digests.where(freq: 0).count
    TfIdfService.new(@bucket.media.first).update_digests_frequencies_in_documents if @bucket.media.count > 0
    @bucket.update(amnt_digests: @bucket.hash_digests.count)
    render json: {digests_with_zero_freq: @bucket.hash_digests.where(freq: 0).count, before: bef}
  end

  def clear

    sql = "delete from digest_locations
    where id in (select t1.id from digest_locations t1
    inner join media t2 on t1.medium_id = t2.id
    where t2.bucket_id=#{@bucket.id})
    "
    data = ActiveRecord::Base.connection.execute(sql)
    TempDigest.delete_all  # fix it
    @bucket.media.delete_all
    @bucket.hash_digests.delete_all
    head(200)
  end


  def stats
    sql = "SELECT t1.id, count(t2.id) as ct FROM hash_digests t1
              INNER JOIN digest_locations t2 on
                t2.hash_digest_id = t1.id
              INNER JOIN buckets t3 on
                t1.bucket_id = t3.id
              WHERE t3.id = #{@bucket.id}
              group by t1.id
              order by ct asc
          "
    #data = ActiveRecord::Base.connection.execute(sql).map{|s| s["ct"]}
    render  json: {
              media: @bucket.media.count,
              digests: @bucket.hash_digests.count,
              locations: @bucket.digest_locations.count,
              digest_histogram: [] #data
            }
  end

  def create
    @bucket = Bucket.new(slug: params[:slug])
    if @bucket.save
      render json: @bucket, status: :ok, location: @bucket
    else
      render json: @bucket.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @bucket.destroy
  end

  private

  def get_bucket
    @bucket = Bucket.find_by(slug: params[:id])
  end

end
