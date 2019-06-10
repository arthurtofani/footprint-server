class LoadMediaDigestsJob < ApplicationJob
  queue_as :default

  def perform(*medium_id)
    @medium = Medium.find(medium_id.first)
    @medium.add_digests
    TfIdfService.new(@medium).update!
  end
end
