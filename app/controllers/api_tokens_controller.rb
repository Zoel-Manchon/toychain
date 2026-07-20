class ApiTokensController < ApplicationController
  def index
    @tokens = Current.user.api_tokens.order(created_at: :desc)
    @token = ApiToken.new
  end

  def create
    @token = Current.user.api_tokens.new(token_params)

    if @token.save
      flash[:raw_token] = @token.raw_token
      redirect_to api_tokens_path, notice: "Token created — copy it now, it won't be shown again."
    else
      @tokens = Current.user.api_tokens.order(created_at: :desc)
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    Current.user.api_tokens.find(params[:id]).destroy!
    redirect_to api_tokens_path, notice: "Token revoked."
  end

  private

  def token_params
    params.expect(api_token: [ :name ])
  end
end
