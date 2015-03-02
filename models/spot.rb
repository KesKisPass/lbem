class Spot < Localizable

  include Mongoid::Timestamps::Created

  field :name,            type: String, default: nil
  field :picture_url,     type: String, default: nil
  field :address,         type: Array,  default: nil # Array of String: lineN, state, zip, city, country, whatever

  index :name => 1
  index :company => 1

  belongs_to :company
  has_and_belongs_to_many :employees,   class_name: 'User'
  has_many   :events

  validates_presence_of   :name
  validates_presence_of   :address
  validates_presence_of   :company

  def as_json(options = {})
    _only    = [ :name, :picture_url ]   + (options[:only] || [])
    _methods = [ :latitude, :longitude ] + (options[:methods] || [])
    _include = { company: { only: :name } }

    _include.merge!({ employees: {only: [ :nickname ]} }) if options[:include].try :include?, :employees
    super( only: _only, methods: _methods, include: _include )
  end

# Events

  ## plan a new event at this spot
  #
  # @TODO
  # @param params [Hash] options
  # @param user_asking [User]
  #
  # @raise [SecurityError] if user_asking not an employee
  def plan_event(params, user_asking)
    raise SecurityError, "User is not part of this spot" unless announcer?(user_asking)
  end

# Employees

  ## hire a user
  #
  # @param user_to_hire [User]
  # @return [TrueClass] if hired, nil otherwise
  def hire(user_to_hire)
    return if employees.include? user_to_hire
    user_to_hire.jobs << self
    true
  end

  ## fire a user
  #
  # @param user_to_fire [User]
  # @return [TrueClass] if fired, nil otherwise
  def fire(user_to_fire)
    return unless employees.include? user_to_fire
    user_to_fire.jobs.delete self
    true
  end

# Private

  private

  ## check if a user is an announcer
  #
  # @param user_asking [User]
  # @return [Boolean] is an employee or an owner
  def announcer?(user_asking)
    employee? user_asking or owner? user_asking
  end

  ## check if a user is an employee
  #
  # @param user_asking [User]
  # @return [Boolean] is an employee
  def employee?(user_asking)
    user_asking.in? employees
  end

  ## check if a user is an owner
  #
  # @param user_asking [User]
  # @return [Boolean] is an owner
  def owner?(user_asking)
    user_asking.in? company.owners
  end

end
