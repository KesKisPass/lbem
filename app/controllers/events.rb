Lbem::App.controllers :events do

  ## retrieve events visible by the user in a range
  #
  # @param latitude [Float] latitude of the search
  # @param longitude [Float] longitude of the search
  # @param range [Float] range to query in
  # @return [JSON] a list of events
  #
  # @route /events
  get :index do
    ensure_authenticated!
    loc_params = [ params[:latitude], params[:longitude], params[:range] ].map { |p| p.try(&:to_f) }
    error 400, 'ArgumentError' if loc_params.any?(&:nil?)
    @events = {
      :common => Event.common.at_range(*loc_params),
      :sponsored => Event.sponsored.at_range(*loc_params),
      :restricted => Event.restricted_with(current_user).at_range(*loc_params)
    }
    @events.to_json
  end

# user's

  ## retrieve events of a user
  #
  # @param user_id [String] user's nickname
  # @return [JSON] array of visible events
  #
  # @route /users/:user_id/events
  get :index, parent: :users do
    ensure_authenticated!
    contact = ensure_exists!(params[:user_id])
    @events = contact.visible_events_for current_user
    @events.to_json
  end

  ## give the user a form to create an event
  #
  # @param user_id [String] in route; nickname of the user
  # @return [JSON] form to fill
  #
  # @route users/:user_id/events/form
  get :form, parent: :users do
    ensure_authenticated!
    ensure_himself!(params[:user_id])
    @fields = Event.required_parameters_as(:user)
    @fields.to_json
  end

  ## make the user create a new event
  #
  # @param user_id [String] in route; nickname of the user
  # @param fields* [String] the required ones
  #
  # @route /users/:user_id/events/form
  post :form, parent: :users do
    ensure_authenticated!
    ensure_himself!(params[:user_id])
    begin
      Event.create_from_form(params, current_user)
      blank_json
    rescue ArgumentError => e
      error 400, e.message
    end
  end

  ## delete an event of the user
  #
  # @param user_id [String] in route; nickname of the user
  # @param event_id [String] in route; public id of the event to delete
  #
  # @route /users/:user_id/events/:event_id
  delete :index, parent: :users, with: :event_id do
    ensure_authenticated!
    ensure_himself!(params[:user_id])
    begin
      Event.delete_from_query(params[:event_id], current_user)
      blank_json
    rescue ArgumentError => e
      error 400, e.message
    end
  end

# Companies & Spots

  ## get events of a spot
  #
  # @param company_id [String] in route. Name of the company
  # @param spot_id [String] in route. Name of the spot
  #
  # @route /companies/:company_id/spots/:spot_id/events
  get :index, parent: [:companies, :spots] do
    ensure_authenticated!
    company = ensure_company_exists! params[:company_id]
    spot = ensure_spot_exists! company, params[:spot_id]
    @events = { events: spot.events }
    @events.to_json
  end

  ## get form to plan event
  #
  # @param company_id [String] in route. Name of the company
  # @param spot_id [String] in route. Name of the spot
  # @return [JSON] form to fill
  #
  # @route /companies/:company_id/spots/:spot_id/events/form
  get :form, parent: [:companies, :spots] do
    ensure_authenticated!
    company = ensure_company_exists! params[:company_id]
    spot = ensure_spot_exists! company, params[:spot_id]
    @fields = Event.required_parameters_as(:spot)
    @fields.to_json
  end

  ## plan a new event
  #
  # @param company_id [String] in route. Name of the company
  # @param spot_id [String] in route. Name of the spot
  # @param fields* [String] the required ones
  #
  # @route /companies/:company_id/spots/:spot_id/events/form
  post :form, parent: [:companies, :spots] do
    ensure_authenticated!
    company = ensure_company_exists! params[:company_id]
    spot = ensure_spot_exists! company, params[:spot_id]
    begin
      spot.plan_event params
      blank_json
    rescue SecurityError => e
      error 400, 'Not part of this spot'
    rescue
      error 500, 'Internal server error'
    end
  end

end
