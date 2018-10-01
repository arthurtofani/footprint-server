require 'rails_helper'

RSpec.describe "Media", type: :request do
  let(:metadata) do
    {author: "author", album: "albumname"}
  end
  let(:metadata2) do
    {author: "author2", album: "albumname2"}
  end

  let(:digests) do
    [
      "aaa:1000",
      "bbb:1300",
      "ccc:1800"
    ]
  end

  let(:digests2) do
    [
      "ddd:1200",
      "bbb:1600",
      "eee:1900"
    ]
  end

  let(:digests3) do
    [
      "bbb:2300",
      "ccc:2800"
    ]
  end

  describe "POST /query" do
    before do
      post media_path, params: {path: "/files/test.wav", metadata: metadata, digests: digests}
      post media_path, params: {path: "/files/test2.wav", metadata: metadata2, digests: digests2}
      post query_media_path, params: {digests: digests3}
    end

    it "returns the results" do
      binding.pry
    end
  end

  describe "POST /media" do
    before do
      post media_path, params: {path: "/files/test.wav", metadata: metadata, digests: digests}
    end

    let(:medium){ Medium.find(JSON.parse(response.body)["id"]) }

    it "adds media info" do
      expect(response).to have_http_status(200)
    end

    it "creates a medium with metadata" do
      expect(medium.metadata['author']).to eq('author')
    end

    it "creates a medium with path" do
      expect(medium.path).to eq('/files/test.wav')
    end

    it "creates a medium with digests" do
      expect(medium.digest_locations.count).to eq(3)
    end
  end
end
