Lbem::Admin.controllers :users do

	get :index do
		@title = 'Users'
		@users = User.all
		render 'users/index'
	end

	get :new do
		@title = pat(:new_title, :model => 'user')
		@user = User.new
		render 'users/new'
	end


end
