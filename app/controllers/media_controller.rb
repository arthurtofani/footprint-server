require 'histogram/array'

class MediaController < ApplicationController
  before_action :set_medium, only: [:show, :update, :destroy]
  before_action :get_digests, only: [:create]
  before_action :get_bucket, only: [:create, :stats, :query, :clear, :index]

  def index
    @media = Medium.where(bucket: @bucket)
    render json: @media
  end

  def show
    render json: @medium
  end

  def create
    @medium = Medium.new(medium_params.merge(bucket: @bucket))
    if @medium.save
      TempDigest.import([:medium_id, :digest, :time_offset_ms], @digests.map{|a| a.split(":")}.map{|s, d|  [@medium.id, s, d.to_i]}, ignore: true, batch_size: 5000)
      @medium.add_digests
      #LoadMediaDigestsJob.perform_now(@medium.id) unless @digests.nil?

      render json: @medium, status: :ok, location: @medium
    else
      render json: @medium.errors, status: :unprocessable_entity
    end
  end

  def update
    if @medium.update(medium_params)
      render json: @medium
    else
      render json: @medium.errors, status: :unprocessable_entity
    end
  end

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

    def get_bucket
      @bucket = Bucket.find_by(slug: params[:bucket_id])
    end

    # Only allow a trusted parameter "white list" through.
    def medium_params
      { path: params[:path], metadata: params[:metadata] }
    end
end
