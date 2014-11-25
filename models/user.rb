class User

	include Mongoid::Document

	field :email,		type: String
	field :password,	type: String
	field :nickname,	type: String

	validates_presence_of		:email
	validates_uniqueness_of	:email,    	case_sensitive: false
	validates_format_of			:email,    	with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i

	validates_presence_of		:nickname
	validates_uniqueness_of	:nickname,	case_sensitive: true
	validates_format_of			:nickname,	with: /[A-Za-z]{1,10}/

	has_and_belongs_to_many	:users

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

# Creation

	# get the required parameters for User creation
	#
	# @param action [Symbol] the action to perform
	# @note available actions are :create, password_modif
	# @return [Array] names of parameters to provide
	def self.required_parameters(action)
		{
			create: [ 'email', 'nickname', 'password', 'password_confirmation' ],
			check: [ 'email', 'password' ],
			password_modif: [ 'actual_password', 'new_password', 'new_password_confirmation' ]
		}[ action ]
	end

	# create a user from params. Also check uniqueness first
	#
	# @param params [Hash] parameters provided by the user
	# @return [Hash]
	# @note called from controler login
	def self.create_from_form(params)
		# missing ?
		missing = required_parameters(:create) - params.keys
		return { success: false, text: "Missing parameters : #{missing.map { |o| o.gsub('_', ' ') }.join(', ')}" } if missing.present?

		# works ?
		attributes = {}
		required_parameters(:create).each { |p| attributes[p] = params[p] }
		u = User.new(attributes)
		return { success: true, text: "Registration succeed" } if u.save

		# defining errors
		errors = []
		errors << 'email already taken' unless User.find_by(email: params['email']).nil?
		errors << 'nickname already taken' unless User.find_by(nickname: params['nickname']).nil?
		errors << 'internal error' if errors.empty?
		{ success: false, text: "Registration failed : #{errors.join(', ')}" }
	end

end
