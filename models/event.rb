class Event < Localizable

  include Mongoid::Timestamps::Created
  extend Enumerize

  field :title,           type: String
  field :content,         type: String
  field :end,             type: Date
  field :pubid,           type: String

  enumerize :visibility,  in: [ :sponsored, :public ],   default: :public

  belongs_to :user

  validates_length_of     :title,       maximum: 32
  validates_presence_of   :title
  validates_presence_of   :user

  before_create           :generate_pubid

  scope :sponsored,       where(visibility: :sponsored)
  scope :common,          where(visibility: :public)

  def as_json(options = {})
    super( {only: [ :pubid, :title, :content, :latitude, :longitude ], methods: [:author, :date]}.merge options )
  end
  def author() user; end
  def date() { day: created_at.strftime('%Y-%m-%d'), time: created_at.strftime('%H-%M-%S'), now: true }; end

# Creation

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
    create! params
  rescue Mongoid::Errors::Validations => e
    raise ArgumentError, 'ArgumentError'
  end

  def self.delete_from_query(event_id, user)
    user.events.find_by(pubid: event_id).delete
  rescue Mongoid::Errors::DocumentNotFound => e
    raise ArgumentError, 'ArgumentError, event not found'
  end

# Private

  ## generates a new a small key used as public id
  #
  # @see SecureRandom.hex
  def generate_pubid
    self.pubid = SecureRandom.hex(4)
  end

end
