class Bucket < ApplicationRecord
  has_many :media, dependent: :destroy
  has_many :hash_digests, dependent: :destroy
  has_many :digest_locations, through: :media
  validates_uniqueness_of :slug
end
