class Company

  include Mongoid::Document
  include Mongoid::Timestamps::Created

  field :name

  has_and_belongs_to_many :owners, class_name: 'User'
  has_many :spots

  def as_json(options = {})
    _only    = [ :name ] + (options[:only] || [])
    _methods = []        + (options[:methods] || [])
    _include = {}

    _include.merge!({ owners: {only: [ :nickname ]} })           if options[:include].try :include?, :owners
    _include.merge!({ spots:  {only: [ :name, :picture_url ]} }) if options[:include].try :include?, :spots
    super( only: _only, methods: _methods, include: _include )
  end

end
