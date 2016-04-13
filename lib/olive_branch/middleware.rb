module OliveBranch
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      inflection = env["HTTP_KEY_INFLECTION"]

      if inflection && env["CONTENT_TYPE"] =~ /application\/json/
        env["action_dispatch.request.request_parameters"].deep_transform_keys!(&:underscore)
      end

      status, headers, response = @app.call(env)

      if inflection && headers["Content-Type"] =~ /application\/json/
        new_response = JSON.parse(response.body)

        if inflection == "camel"
          new_response.deep_transform_keys! { |k| k.camelize(:lower) }
        elsif inflection == "dash"
          new_response.deep_transform_keys!(&:dasherize)
        end

        [status, headers, [new_response.to_json]]
      else
        [status, headers, response]
      end
    end
  end
end
