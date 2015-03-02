# Helper methods defined here can be accessed in any controller or view in the application

module Lbem
  class App
    module SpotsHelper

			def ensure_spot_exists!(company, target_spot)
				company.spots.find_by name: target_spot
			rescue
				error 404, 'Spot not found for this company'
			end


    end

    helpers SpotsHelper
  end
end
