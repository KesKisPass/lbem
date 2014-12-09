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
	get :form, map: 'login/create/form' do
		{ fields: User.required_parameters(:create) }.to_json
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
		rescue => e
			{ success: false, text: e }
		end.to_json
	end

	## Authentification

	# get form for authentification
	# for more generics, gives the fields the user must fill
	#
	# @return [String]
	# @note it returns a json string representing a map.
	# @note the map provide for key 'fields' an array of fields' names the user must provide
	get :form, map: 'login/check/form' do
		{ fields: User.required_parameters(:check) }.to_json
	end

	# log a user if authentification succeed
	#
	# @param email [String]
	# @param password [String]
	# @return [String] a json string reprensenting a map with keys 'success' (boolean)
	post :check do
		user = User.authenticate(params[:email], params[:password])
		set_current_user(user)
		{ success: !!user }.to_json
	end

	## Log out

	# log out from session
	#
	delete :index do
		sign_out
	end

end
