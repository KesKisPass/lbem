class Event < Localizable

  include Mongoid::Timestamps::Created
  extend Enumerize

  field :title,           type: String
  field :content,         type: String
  field :pubid,           type: String
  field :begin,           type: Date #TODO
  field :end,             type: Date #TODO

  enumerize :visibility,  in: [ :sponsored, :common, :restricted ],   default: :common

  belongs_to :user
  belongs_to :spot

  validates_length_of     :title,       maximum: 32
  validates_presence_of   :title
  validates_presence_of   :user

  before_create           :generate_pubid
  before_create           :not_sponsored! # for users

  scope :sponsored,       where(visibility: :sponsored)
  scope :common,          where(visibility: :common)
  scope :restricted,      where(visibility: :restricted)
  scope :restricted_with, ->(user_asking){ restricted.or({:user_id.in => user_asking.contact_list.user_ids}, {user: user_asking}) }

  def as_json(options = {})
    super( {only: [ :pubid, :title, :content, :latitude, :longitude ], methods: [:author, :date]}.merge options )
  end
  def date() { day: created_at.strftime('%Y-%m-%d'), time: created_at.strftime('%H-%M-%S'), now: true }; end

# Accessors

  def author
    user || spot
  end

  def author=(a)
    if a.is_a? User
      user = a
    else
      spot = a
    end
  end

# Creation

  def self.required_parameters_as(author_type)
    {
      user: {
          keys: [ 'title', 'content', 'latitude', 'longitude', 'visibility' ],
          names: [ 'Title', 'Content', 'Latitude', 'Longitude', 'Visibility' ]
      },
      spot: {
          keys: [ 'title', 'content', 'latitude', 'longitude', 'visibility' ],
          names: [ 'Title', 'Content', 'Latitude', 'Longitude', 'Visibility' ]
      }
    }[ author_type ]
  end

  ## create a new event
  #
  # @param params [Hash] parameters provided by the user
  # @param user [User] author for this event
  # @param user [Spot] author for this event
  # @raise [ArgumentError]
  def self.create_from_form(params, user)
    params.keep_if { |k| required_parameters_as(user.class.to_s.downcase.to_sym)[:keys].include? k.to_s }
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

  private

  ## generates a new a small key used as public id
  #
  # @see SecureRandom.hex
  def generate_pubid
    self.pubid = SecureRandom.hex(4)
  end

  ## ensure a user didn't set the visibility of his event to sponsored
  #
  # @raise [ArgumentError]
  def not_sponsored!
    raise ArgumentError, 'This visibility is not available for users' if user.present? and visibility.sponsored?
  end

end
