Lbem::App.controllers :contact_lists, parent: :users  do
  
  ## show contact_list
  #
  # @route /users/:user_id/contact_lists
  get :index do
    ensure_authenticated!
    ensure_himself!(params[:user_id])
    @nicknames = current_user.contact_list.nicknames
    @nicknames.to_json
  end

  ## add new contact
  #
  # @route /users/:user_id/contact_lists/contact/:nickname
  post :contact, :with => :nickname do
    ensure_authenticated!
    ensure_himself!(params[:user_id])
    u = User.where(nickname: params[:nickname]).first
    error 400, "User doesn't exists" if u.nil?
    begin
      current_user.contact_list.invite_contact(u)
    rescue
      error 400, "Internal server error"
    end
    blank_json
  end

  ## delete contact
  #
  # @route /users/:user_id/contact_lists/contact/:nickname
  delete :contact, :with => :nickname do
    ensure_authenticated!
    ensure_himself!(params[:user_id])
    u = User.where(nickname: params[:nickname]).first
    error 400, "User doesn't exists" if u.nil?
    begin
      current_user.contact_list.remove_contact(u)
    rescue
      error 400, "Internal server error"
    end
    blank_json
  end  

  ## show pending list
  #
  # @route /users/:user_id/contact_lists/pending/
  get :pending do
    ensure_authenticated!
    ensure_himself!(params[:user_id])
    requesters = current_user.requesters
    requestees = current_user.requestees
    @PendingList = {requesters: requesters, requestees: requestees}
    @PendingList.to_json
  end


  ## accept contact
  #
  # @route /users/:user_id/contact_lists/pending/:nickname
  get :pending, :with => :nickname do
    ensure_authenticated!
    ensure_himself!(params[:user_id])
    u = User.where(nickname: params[:nickname]).first
    error 400, "User doesn't exists" if u.nil?
    begin
      current_user.contact_list.accept_invitation(u)
    rescue
      error 400, "Internal server error"
    end
    blank_json
  end

  ## refuse contact
  #
  # @route /users/:user_id/contact_lists/pending/:nickname
  delete :pending, :with => :nickname do
    ensure_authenticated!
    ensure_himself!(params[:user_id])
    u = User.where(nickname: params[:nickname]).first
    error 400, "User doesn't exists" if u.nil?
    begin
      current_user.contact_list.cancel_invitation(u)
    rescue
      error 400, "Internal server error"
    end
    blank_json
  end

end

