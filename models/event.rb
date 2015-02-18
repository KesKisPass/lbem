class Event < Localizable

  include Mongoid::Timestamps::Created
  extend Enumerize

  field :title,           type: String
  field :content,         type: String
  field :end,             type: Date

  enumerize :visibility,  in: [ :sponsored, :public ],   default: :public

  belongs_to :user

  validates_length_of     :title,       maximum: 32
  validates_presence_of   :title
  validates_presence_of   :user

  scope :sponsored,       where(visibility: :sponsored)
  scope :public,          where(visibility: :public)

  def as_json
    {
      title: title,
      content: content,
      author: user.nickname,
      created_at: created_at,
      visibility: visibility,
      latitude: latitude,
      longitude: longitude
    }.to_json
  end

  def self.required_parameters
    {
      keys: [ 'title', 'content', 'latitude', 'longitude' ],
      names: [ 'Title', 'Content', 'Latitude', 'Longitude' ]
    }
  end

  ## create a new event
  #
  # @param params [Hash] parameters provided by the user
  # @param user [User] owner for this event
  # @raise [ArgumentError]
  def self.create_from_form(params, user)
    params.keep_if { |k| required_parameters[:keys].include? k.to_s }
    params[:user] = user
    params[:coordinates] = [ params[:latitude].to_f, params[:longitude].to_f ]
    create! params rescue Mongoid::Errors::Validations; raise ArgumentError, 'ArgumentError'
  end

end
