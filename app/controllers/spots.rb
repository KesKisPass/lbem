Lbem::App.controllers :spots do

  ## Get spots of a dedicated company
  #
  # @param company_id [String] in route. Name of the company
  # @route /companies/:company_id/spots
  get :index, parent: 'companies' do
    ensure_authenticated!
    company = ensure_company_exists! params[:company_id]
    @spots = { spots: company.spots }
    @spots.to_json
  end
  
  ## Get spots of a dedicated company
  #
  # @param company_id [String] in route. Name of the company
  # @param name [String] in route. Name of the spot
  # @route /companies/:company_id/spots/:spot_id
  get :index, parent: 'companies', with: :spot_id do
    ensure_authenticated!
    company = ensure_company_exists! params[:company_id]
    spot = ensure_spot_exists! company, params[:spot_id]
    @spot = { spot: spot }
    @spot.to_json
  end  

end
