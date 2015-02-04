module Lbem
	class App
		module ApplicationHelper
			
			def rabl(view)
				content_type (params[:format] || :json)
				render :rabl, view.to_sym, format: params[:format]
			end

			def error_json(code, msg)
				status code
				@error = msg
				halt rabl('errors/' << code.to_s)
			end

			def success_json(status)
				@success = status
				rabl 'status/success'
			end

			def blank_json
				'{}'
			end

		end # module Application

		helpers ApplicationHelper
	end
end
