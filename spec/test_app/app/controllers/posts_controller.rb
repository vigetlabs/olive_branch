class PostsController < ApplicationController
  def update
    request.env["params_spy"] = params

    payload = {
      post_author_name: params[:post][:author_name],
      category_filter_name: (params[:category_filter] || {})[:category_name],
    }

    render json: payload
  end
end
