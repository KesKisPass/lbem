Lbem::App.controllers :companies do

  ## get companies
  #
  # @route /companies
  get :index do
    ensure_authenticated!
    @companies = { companies: Company.all.to_a }
    @companies.to_json
  end

  ## get company
  #
  # @param company_id [String] in route; name of the company
  # @route /companies/:company_id
  get :index, with: :company_id do
    ensure_authenticated!
    company = ensure_company_exists! params[:company_id]
    @company = { company: company }
    @company.to_json
  end

end
