class AccessToken

  include Mongoid::Document
  require 'securerandom'

  field :token,       type: String
  # field :phone_name,  type: String

  belongs_to :user
  validates_associated :user

  attr_readonly :token
  before_validation :generate_token
  validates_presence_of :token
  validates_uniqueness_of :token

  def to_s
    token
  end

private

  ## generates a new uniq access token string and assign it
  #
  # @see SecureRandom.hex
  def generate_token
    self.token = SecureRandom.hex if new_record?
  end

end