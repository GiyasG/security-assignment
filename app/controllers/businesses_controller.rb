class BusinessesController < ApplicationController


  before_action :set_business, only: [:show, :update, :destroy]
  wrap_parameters :business, include: ["offer", "description"]
  before_action :authenticate_user!, only: [:index, :show, :create, :update, :destroy]
  after_action :verify_authorized
  after_action :verify_policy_scoped, only: [:index]

  def index
    authorize Business
    @businesses = policy_scope(Business.all)
    @businesses = BusinessPolicy.merge(@businesses)

  end

  def show
    authorize @business
    businesses = BusinessPolicy::Scope.new(current_user,
                                    Business.where(:id=>@business.id))
                                    .user_roles(false)
    @business = BusinessPolicy.merge(businesses).first
    # pp @business.user_roles
    # byebug

  end

  def create
    authorize Business
    @business = Business.new(business_params)
    @business.creator_id=current_user.id

    User.transaction do
      if @business.save
        # pp @business
        role=current_user.add_role(Role::ORGANIZER, @business)
        @business.user_roles << role.role_name
        role.save!
        # pp role
        # byebug
        render :show, status: :created, location: @business
      else
        render json: @business.errors.messages, status: :unprocessable_entity
      end
    end
  end

  def update
    authorize @business

    if @business.update(business_params)
      head :no_content
    else
      render json: @business.errors.messages, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @business
    @business.destroy

    head :no_content
  end

  private

    def set_business
      @business = Business.find(params[:id])
    end

    def business_params
      params.require(:business).permit(:offer, :description)
    end
end
