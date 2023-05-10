class SessionsController < ApplicationController
  skip_before_action :authenticate
  before_action :load_current_user, only: :login

  def login
  end

  def create
    create_session
  end

  def destroy
    clean_session

    redirect_to root_path
  end

  def failure
    render html: "Authorization failed (#{request.params['message']})", status: :forbidden
  end
end
