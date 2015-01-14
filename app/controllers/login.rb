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
		@create_form = { fields: User.required_parameters(:create) }
		@create_form.to_json
	end

	# creates a user
	#
	# @param email [String]
	# @param password [String]
	# @param password_confirmation [String]
	# @return [String] a json string reprensenting a map with keys 'success' (boolean) and 'text' (string)
	post :create do
		@create_from_form = begin
			User.create_from_form(params)
		rescue ArgumentError => e
			{ success: false, text: e.message }
		end
		@create_from_form.to_json
	end

	## Authentification

	# get form for authentification
	# for more generics, gives the fields the user must fill
	#
	# @return [String]
	# @note it returns a json string representing a map.
	# @note the map provide for key 'fields' an array of fields' names the user must provide
	get :form, map: 'login/check/form' do
		@check_form = { fields: User.required_parameters(:check) }
		@check_form.to_json
	end

	# log a user if authentification succeed
	#
	# @param email [String]
	# @param password [String]
	# @return [String] a json string reprensenting a map with keys 'success' (boolean)
	post :check do
		user = User.authenticate(params[:email], params[:password])
		set_current_user(user)
		@check = { success: !!user }
		@check.to_json
	end

	## Log out

	# log out from session
	#
	delete :index do
		sign_out
	end

end
