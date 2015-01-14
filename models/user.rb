class User

  include Mongoid::Document

  field :email,        type: String
  field :password,  type: String
  field :nickname,  type: String

  validates_presence_of    :email
  validates_uniqueness_of :email,     case_sensitive: false
  validates_format_of        :email,     with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i

  validates_presence_of    :nickname
  validates_uniqueness_of :nickname,  case_sensitive: true
  validates_format_of        :nickname,  with: /[A-Za-z]{1,10}/

  def to_s
    "#{nickname} '#{email}'"
  end

# Authentification

  # @return: user or nil
  def self.authenticate(email, pwd)
    return unless email.present? && pwd.present?
    user = where(:email => /#{Regexp.escape(email)}/i).first
    user && user.correct_password?(pwd) ? user : nil
  end

  # @return: true or false
  def correct_password?(to_check)
    ::BCrypt::Password.new(password) == to_check
  end

  def self.format_of( fmt )
    {
      email: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i ,
      nickname: /[A-Za-z]{1,10}/ ,
    }[ fmt ]
  end

# Creation

  # get the required parameters for User creation
  #
  # @param action [Symbol] the action to perform
  # @note available actions are :create, password_modif
  # @return [Array] names of parameters to provide
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

  def self.encrypt_password(to_save)
    ::BCrypt::Password.create(to_save).to_s
  end

  # create a user from params. Also check uniqueness first
  #
  # @param params [Hash] parameters provided by the user
  # @return [Hash]
  # @note called from controler login
  def self.create_from_form(params)
    [
      { msg: 'Missing parameters',                    rule: lambda { |p| ( required_parameters(:create)[:keys] - p.keys ).empty? } },
      { msg: 'Password confirmation failed',     rule: lambda { |p| p['password'] == p['password_confirmation'] } },
      { msg: 'Email don\'t respect format',        rule: lambda { |p| p['email'] =~ User.format_of(:email) } },
      { msg: 'Nickname don\'t respect format', rule: lambda { |p| p['nickname'] =~ User.format_of(:nickname) } },
      { msg: 'Email already taken',                    rule: lambda { |p| User.where(email: p['email']).empty? } },
      { msg: 'Nickname already taken',             rule: lambda { |p| User.where(nickname: p['nickname']).empty? } }
    ].each { |r| raise ArgumentError, r[:msg] unless r[:rule].call(params) }

    attributes = {}
    params['password'] = encrypt_password(params['password'])
    ( required_parameters(:create)[:keys] - ['password_confirmation'] ).each { |p| attributes[p] = params[p] }
    raise ArgumentError, 'Internal server error' unless User.new(attributes).save
    { success: true, text: "Registration succeed" }
  end

end
