class PostsController < ApplicationController
  COMPLEX_RESPONSE ||= JSON.parse(File.read(Rails.root.join("example_responses/complex.json")))

  def update
    request.env["params_spy"] = params

    payload = {
      post_author_name: params[:post][:author_name],
      category_filter_name: (params[:category_filter] || {})[:category_name],
    }

    render json: payload
  end

  def complex
    render json: COMPLEX_RESPONSE
  end
end
