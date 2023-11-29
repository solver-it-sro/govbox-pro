class Admin::UsersController < ApplicationController
  before_action :set_user, only: %i[edit update destroy]

  def index
    authorize([:admin, User])
    @users = policy_scope([:admin, User]).where(tenant_id: Current.tenant.id).order(:name)
  end

  def new
    @user = Current.tenant.users.new
    authorize([:admin, @user])
  end

  def edit
    authorize([:admin, @user])
  end

  def create
    @user = Current.tenant.users.new(user_params)
    authorize([:admin, @user])

    if @user.save
      redirect_to admin_tenant_users_url(Current.tenant), notice: 'User was successfully created'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize([:admin, @user])
    if @user.update(user_params)
      redirect_to admin_tenant_users_url(Current.tenant), notice: 'User was successfully updated'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize([:admin, @user])
    @user.destroy
    redirect_to admin_tenant_users_url(Current.tenant), notice: 'User was successfully destroyed'
  end

  private

  def set_user
    @user = policy_scope([:admin, User]).find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :user_type)
  end
end
