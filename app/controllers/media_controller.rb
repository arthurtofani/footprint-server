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
    DigestLocation.destroy_all
    HashDigest.destroy_all
    Medium.destroy_all
    head(200)
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
