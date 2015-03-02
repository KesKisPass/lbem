# Helper methods defined here can be accessed in any controller or view in the application

module Lbem
  class App
    module CompaniesHelper

			def ensure_company_exists!(target_company)
				Company.find_by name: target_company
			rescue
				error 404, 'Company not found'
			end

    end

    helpers CompaniesHelper
  end
end
