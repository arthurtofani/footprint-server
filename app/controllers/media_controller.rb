require 'histogram/array'

class MediaController < ApplicationController
  before_action :set_medium, only: [:show, :update, :destroy]
  before_action :get_digests, only: [:create]

  # GET /media
  def index
    @media = Medium.all
    render json: @media
  end

  # GET /media/1
  def show
    render json: @medium
  end

  def query
    result = DigestService.new(params[:digests]).search
    render json: result
  end

  def clear
    DigestLocation.delete_all
    HashDigest.delete_all
    Medium.delete_all
    head(200)
  end


  def stats
    sql = "SELECT t1.id, count(t2.id) as ct FROM hash_digests t1
              INNER JOIN digest_locations t2 on
              t2.hash_digest_id = t1.id group by t1.id
              order by ct asc
          "
    data = ActiveRecord::Base.connection.execute(sql).map{|s| s["ct"]}
    render  json: {
              digest_histogram: data,
              locations: DigestLocation.all.count,
              digests: HashDigest.all.count,
              media: Medium.all.count
            }
  end

  # POST /media
  def create
    @medium = Medium.new(medium_params)
    if @medium.save
      @medium.add_digests(@digests) unless @digests.nil?

      render json: @medium, status: :ok, location: @medium
    else
      render json: @medium.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /media/1
  def update
    if @medium.update(medium_params)
      render json: @medium
    else
      render json: @medium.errors, status: :unprocessable_entity
    end
  end

  # DELETE /media/1
  def destroy
    @medium.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_medium
      @medium = Medium.find(params[:id])
    end

    def get_digests
      @digests = params[:digests]
    end

    # Only allow a trusted parameter "white list" through.
    def medium_params
      {path: params[:path], metadata: params[:metadata]}
    end
end
