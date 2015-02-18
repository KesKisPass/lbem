class Localizable

  include Mongoid::Document

  field :coordinates,           type: Array,  default: nil
  index({ coordinates: "2d" },  { min: -180, max: 180 })

  validates_presence_of :coordinates

  ## returns localizables matching params
  #
  # @param la [Float] latitude
  # @param lo [Float] longitude
  # @param ra [Float] range in km
  # @return [Mongoid]
  def self.at_range(la, lo, ra)
    geo_near([la, lo]).max_distance(ra.fdiv(111.12))
  end

  def latitude
    coordinates[0]
  end

  def longitude
    coordinates[1]
  end

end
