class User

  include Mongoid::Document
  include Mongoid::Timestamps::Created

  field :email,     type: String
  field :password,  type: String
  field :nickname,  type: String

  has_many :access_tokens
  has_many :events

  validates_presence_of   :email
  validates_uniqueness_of :email,     case_sensitive: false
  validates_format_of     :email,     with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i

  validates_presence_of   :nickname
  validates_uniqueness_of :nickname,  case_sensitive: true
  validates_format_of     :nickname,  with: /[A-Za-z]{1,10}/

  def to_s
    "#{nickname} '#{email}'"
  end

  def as_json(options = {})
    super( {only: [ :nickname ]}.merge options )
  end

# Authentification

  ## Find a user by his email and password
  #
  # @param email [String]
  # @param pwd [String]
  # @return [User] the one matching. Nil otherwise
  def self.authenticate(email, pwd)
    return unless email.present? && pwd.present?
    user = find_by(:email => /#{Regexp.escape(email)}/i)
    user && user.correct_password?(pwd) ? user : nil
  end

  ## Check if a password matches with user's password
  #
  # @param to_check [String] is `to_check` equals to user's password ? 
  # @return [Boolean] is equal ?
  def correct_password?(to_check)
    ::BCrypt::Password.new(password) == to_check
  end

  ## Validates format of user's entry
  #
  # @param fmt [Symbol] the format to retrieve
  # @return [String] the regex matching the `fmt` parameter. Nil otherwhise
  def self.format_of( fmt )
    {
      email: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i ,
      nickname: /[A-Za-z]{1,10}/ ,
    }[ fmt ]
  end

# Session : token

  ## Create a new token for the user
  #
  # @return [AccessToken] the one created. Raise an Exception otherwise
  def tokenize_session
    tries ||= 2
    access_tokens.create!
  rescue Mongoid::Errors::Validations => e
    retry unless (tries -= 1).zero?
    raise Exception, 'Internal server error'
  end

  ## Find a user by an access token
  #
  # @param token [String] The token we are searching
  # @return [User] the user found. Nil otherwise
  def self.authenticate_with_token(token)
    AccessToken.find_by(token: token).user rescue nil
  end

  ## Delete token on disconnect
  #
  # @param token [String]
  # @return [Boolean] true if found. Nil otherwise
  def disconnect_session!(token)
    AccessToken.find_by(token: token).delete rescue nil
  end

# Creation

  ## get the required parameters for User creation
  #
  # @param action [Symbol] the action to perform
  # @note available actions are :create, password_modif
  # @return [Array] names of parameters to provide
  # @todo move this to ENV or db
  def self.required_parameters(action)
    {
      create: {
        keys: [ 'email', 'nickname', 'password', 'password_confirmation' ],
        names: [ 'Email', 'Nickname', 'Password', 'Password confirmation' ]
      },
      check: {
        keys: [ 'email', 'password' ],
        names: [ 'Email', 'Password' ]
      },
      password_modif: {
        keys: [ 'actual_password', 'new_password', 'new_password_confirmation' ],
        names: [ 'Actual assword', 'New password', 'New password confirmation' ]
      }
    }[ action ]
  end

  ## encrypt a string
  #
  # @param to_save [String] the one to encrypt
  # @return [String] encrypted string
  def self.encrypt_password(to_save)
    ::BCrypt::Password.create(to_save).to_s
  end

  ## create a user from params. Also it checks uniqueness first
  #
  # @param params [Hash] parameters provided by the user
  # @return [Boolean] true if succeed
  # @raise [ArgumentError]
  # @raise [Exception]
  def self.create_from_form(params)
    [
      { msg: 'Missing parameters',             rule: lambda { |p| ( required_parameters(:create)[:keys] - p.keys ).empty? } },
      { msg: 'Password confirmation failed',   rule: lambda { |p| p['password'] == p['password_confirmation'] } },
      { msg: 'Email don\'t respect format',    rule: lambda { |p| p['email'] =~ User.format_of(:email) } },
      { msg: 'Nickname don\'t respect format', rule: lambda { |p| p['nickname'] =~ User.format_of(:nickname) } },
      { msg: 'Email already taken',            rule: lambda { |p| User.where(email: p['email']).empty? } },
      { msg: 'Nickname already taken',         rule: lambda { |p| User.where(nickname: p['nickname']).empty? } }
    ].each { |r| raise ArgumentError, r[:msg] unless r[:rule].call(params) }

    attributes = {}
    params['password'] = encrypt_password(params['password'])
    ( required_parameters(:create)[:keys] - ['password_confirmation'] ).each { |p| attributes[p] = params[p] }
    raise Exception, 'Internal server error' unless User.new(attributes).save
    true
  end

end
