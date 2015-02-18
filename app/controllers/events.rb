Lbem::App.controllers :events do

	## retrieve events visible by the user in a range
	#
	# @param latitude [Float] latitude of the search
	# @param longitude [Float] longitude of the search
	# @param range [Float] range to query in
	# @return [JSON] a list of events
	get :index do
		ensure_authenticated!
		error 400, 'ArgumentError' if params[:latitude].nil? or params[:longitude].nil? or params[:range].nil?
		@events = Event.at_range(params[:latitude].to_f, params[:longitude].to_f, params[:range].to_i)
		@events.as_json
	end

	## retrieve parameters to create a new event
	#
	# @return [JSON]
	get :form do
		ensure_authenticated!
		@fields = Event.required_parameters
		@fields.to_json
	end

	## create a new event
	#
	post :form do
		ensure_authenticated!
		begin
			Event.create_from_form(params, current_user)
			blank_json
		rescue ArgumentError => e
			error 400, e.message
		end
	end

end
