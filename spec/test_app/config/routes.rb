Rails.application.routes.draw do
  # NOTE: The camelized path parameter is used to test that we do *not* apply
  # any transformations on path parameters.
  put 'posts/:postId', format: :json, to: 'posts#update'
  get 'posts/complex', format: :json, to: 'posts#complex'
end
