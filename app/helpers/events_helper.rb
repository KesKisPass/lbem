module Lbem
	class App
		module EventsHelper

			def ensure_himself!(target_user)
				error 403, 'Forbidden' unless current_user.nickname == target_user
			end

		end

		helpers EventsHelper
	end
end
