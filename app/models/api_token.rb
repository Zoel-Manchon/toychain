class ApiToken < ApplicationRecord
  belongs_to :user

  validates :name, presence: true
  validates :token_digest, presence: true, uniqueness: true

  # El token en claro solo existe en memoria al crearse; guardamos su SHA-256.
  attr_reader :raw_token

  before_validation :generate_token, on: :create

  def self.authenticate(raw)
    return nil if raw.blank?

    find_by(token_digest: Digest::SHA256.hexdigest(raw))
  end

  private

  def generate_token
    @raw_token = "tc_#{SecureRandom.hex(20)}"
    self.token_digest = Digest::SHA256.hexdigest(@raw_token)
  end
end
