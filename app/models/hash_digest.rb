class HashDigest < ApplicationRecord
  has_many :digest_locations, dependent: :destroy
  belongs_to :bucket
end
