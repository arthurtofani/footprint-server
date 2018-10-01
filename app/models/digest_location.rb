class DigestLocation < ApplicationRecord
  belongs_to :hash_digest
  belongs_to :medium
end
