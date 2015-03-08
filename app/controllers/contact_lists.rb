Lbem::App.controllers :contact_lists, parent: :users  do
  
  ## show contact_list
  #
  # @route /users/:user_id/contact_lists
  get :index do
    ensure_authenticated!
    ensure_himself!(params[:user_id])
    @contact_list = current_user.contact_list
    @contact_list.to_json
  end

  ## invite contact
  #
  # @route /users/:user_id/contact_lists/contact/:nickname
  post :contact, :with => :nickname do
    ensure_authenticated!
    ensure_himself!(params[:user_id])
    begin
      u = User.find_by nickname: params[:nickname]
      current_user.contact_list.invite_contact(u)
    rescue AlreadyAContactError => e_a_c_e 
      error 422, eace.message # this is dirty fix
    rescue AlreadyARequesterError => a_a_rer_e
      error 423, eace.message # this is dirty fix
    rescue AlreadyARequesteeError => a_a_ree_e 
      error 424, eace.message # this is dirty fix
    rescue Mongoid::Errors::DocumentNotFound
      error 400, "User doesn't exists"
    rescue
      error 500, "Internal server error"
    end
    blank_json
  end

  ## delete contact
  #
  # @route /users/:user_id/contact_lists/contact/:nickname
  delete :contact, :with => :nickname do
    ensure_authenticated!
    ensure_himself!(params[:user_id])
    begin
      u = User.find_by nickname: params[:nickname]
      current_user.contact_list.remove_contact(u)
    rescue ArgumentError => e
      error 400, e.message
    rescue Mongoid::Errors::DocumentNotFound
      error 400, "User doesn't exists"
    rescue
      error 500, "Internal server error"
    end
    blank_json
  end  

  ## show pending list
  #
  # @route /users/:user_id/contact_lists/pendings/
  get :pendings do
    ensure_authenticated!
    ensure_himself!(params[:user_id])
    @pendings = { requesters: current_user.requesters, requestees: current_user.requestees }
    @pendings.to_json
  end


  ## accept contact
  #
  # @route /users/:user_id/contact_lists/pendings/:nickname
  put :pendings, :with => :nickname do
    ensure_authenticated!
    ensure_himself!(params[:user_id])
    begin
      u = User.find_by nickname: params[:nickname]
      current_user.contact_list.accept_invitation(u)
    rescue ArgumentError => e
      error 400, e.message
    rescue Mongoid::Errors::DocumentNotFound
      error 400, "User doesn't exists"
    rescue
      error 500, "Internal server error"
    end
    blank_json
  end

  ## refuse contact
  #
  # @route /users/:user_id/contact_lists/pendings/:nickname
  delete :pendings, :with => :nickname do
    ensure_authenticated!
    ensure_himself!(params[:user_id])
    begin
      u = User.find_by nickname: params[:nickname]
      current_user.contact_list.cancel_invitation(u)
    rescue ArgumentError => e
      error 400, e.message
    rescue Mongoid::Errors::DocumentNotFound
      error 400, "User doesn't exists"
    rescue
      error 500, "Internal server error"
    end
    blank_json
  end

end

