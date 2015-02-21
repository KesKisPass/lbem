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
    error 400, "User doesn't exist" if u.nil?
    begin
      current_user.contact_list.add_contact(u)
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
    error 400, "User doesn't exist" if u.nil?
    begin
      current_user.contact_list.remove_contact(u)
    rescue
      error 400, "Internal server error"
    end
    blank_json
  end  

end
