module Lbem
	class App
		module EventsHelper

			def ensure_himself!(target_user)
				error 403, 'Forbidden' unless himself?
			end

			def ensure_trusted!(target_user)
				error 403, 'Forbidden' unless himself? or contact?
			end

			def ensure_exists!(target_user)
				User.find_by nickname: target_user
			rescue
				error 404, 'User not found'
			end

			def himself?(target_user)
				current_user.nickname == target_user
			end

			def contact?(target_user)
				current_user.contact_list.users.where(nickname: target_user).exists?
			end

		end

		helpers EventsHelper
	end
end
