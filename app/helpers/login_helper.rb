module Lbem
	class App
		module LoginHelper

			def set_current_user(user)
				session[:user_id] = user ? user.id : nil
			end

			def login_from_session
				User.find(session[:user_id]) rescue false
			end

			def current_user
				login_from_session
			end

			def signed_in?
				!!current_user
			end

			def ensure_authenticated!
				error_json 401, 'Wrong token' unless signed_in?
			end

			def sign_out
				session[:user_id] = nil
			end


		end

		helpers LoginHelper
	end
end
