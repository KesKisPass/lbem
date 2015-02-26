Lbem::App.controllers :login do
	
	# default page
	#
	get :index do
		@title = 'Connexion page'
		#render 'index'
		"Use the API mother f*cker"
	end

	## Account creation

	# get form for account creation
	# for more generics, gives the fields the user must fill
	#
	# @return [String] a json string representing a hash
	# @note the hash provide for key 'fields' a hash containing an array of fields' names the user must provide and their key
	get :create do
		@fields = User.required_parameters(:create)
		{ fields: @fields }.to_json
	end

	# creates a user
	#
	# @param email [String]
	# @param password [String]
	# @param password_confirmation [String]
	# @return [String] a json string reprensenting a map with keys 'success' (boolean) and 'text' (string)
	post :create do
		begin
			User.create_from_form(params)
			blank_json
		rescue ArgumentError => e
			error 400, e.message
		rescue Exception => e
			error 500, e.message
		end
	end

	## Authentification

	## get form for authentification
	# for more generics, gives the fields the user must fill
	#
	# @return [String]
	# @note it returns a json string representing a map.
	# @note the map provide for key 'fields' an array of fields' names the user must provide
	get :check do
		@fields = User.required_parameters(:check)
		{ fields: @fields }.to_json
	end

	## log a user if authentification succeed
	#
	# @param email [String]
	# @param password [String]
	# @return [String] a json string reprensenting a map with keys 'success' (boolean)
	post :check do
		@check = {}
		unless current_user
		  user = User.authenticate *( User.required_parameters(:check)[:keys].map { |k| params[k] } )
			error 400, "Authentification Failure" unless user
			set_current_user(user)
			@check[:token] = user.tokenize_session.to_s
		end
		@check[:nickname] = current_user.nickname
		@check.to_json
	end

	## Log out

	## log out from session
	#
	# @todo remove access_token from user's
	delete :index do
		ensure_authenticated!
		current_user.disconnect_session! params[:token]
		sign_out
		blank_json
	end

end
