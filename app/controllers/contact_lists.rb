Lbem::App.controllers :contact_lists, parent: :users  do
  
  ## show contact_list
  #
  # @route /users/:user_id/contact_lists
  get :index do
    begin
      ensure_authenticated!
      @nicknames = current_user.contact_list.nicknames
    rescue
      error 400, "Internal server error"
    end
    @nicknames.to_json
  end

  ## add new contact
  #
  # @route /users/:user_id/contact_lists/contact/:nickname
  post :contact, :with => :nickname do
    begin
      ensure_authenticated!
      u = User.where(nickname: params[:nickname]).first
      error 400, "User doesn't exist" if u.nil?
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
    begin
      ensure_authenticated!
      u = User.where(nickname: params[:nickname]).first
      error 400, "User doesn't exist" if u.nil?
      current_user.contact_list.remove_contact(u)
    rescue
      error 400, "Internal server error"
    end
    blank_json
  end  

end
