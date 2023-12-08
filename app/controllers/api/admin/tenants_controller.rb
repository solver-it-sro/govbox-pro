class Api::Admin::TenantsController < ActionController::Base
  include AuditableApiEvents
  before_action :set_tenant, only: %i[destroy]
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  def create
    begin
      @tenant, @admin, @group_membership = Tenant.create_with_admin(tenant_params)
    rescue ActionController::ParameterMissing => e
      @error = e
    end
    render :error, status: :unprocessable_entity unless @group_membership
    log_api_call(:create_tenant_api_called)
  end

  def destroy
    return if @tenant.destroy

    render json: { message: @tenant.errors.full_messages[0] }, status: :unprocessable_entity
    log_api_call(:create_tenant_api_called)
  end

  private

  def set_tenant
    @tenant = Tenant.find(params[:id])
  end

  def tenant_params
    params.require(:tenant).permit(:name, { admin: [:name, :email] })
  end

  def not_found
    render json: { message: 'not found' }, status: :not_found
  end
end
