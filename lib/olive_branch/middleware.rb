require "multi_json"

module OliveBranch
  class Middleware
    def initialize(app, args = {})
      @app = app
      @camelize_method = args[:camelize_method] || method(:camelize)
      @dasherize_method = args[:dasherize_method] || method(:dasherize)
      @content_type_check_method = args[:content_type_check_method] || method(:content_type_check)
    end

    def call(env)
      inflection = env["HTTP_X_KEY_INFLECTION"]

      if inflection && @content_type_check_method.call(env["CONTENT_TYPE"])
        underscore_params(env)
      end

      @app.call(env).tap do |_status, headers, response|
        next unless inflection && @content_type_check_method.call(headers["Content-Type"])
        response.each do |body|
          begin
            new_response = MultiJson.load(body)
          rescue MultiJson::ParseError
            next
          end

          if new_response.is_a? Array
            new_response.each { |o| o.deep_transform_keys! { |k| transform(k, inflection) } }
          else
            new_response.deep_transform_keys! { |k| transform(k, inflection) }
          end

          body.replace(MultiJson.dump(new_response))
        end
      end
    end

    def transform(key, inflection)
      if inflection == "camel"
        @camelize_method.call(key)
      elsif inflection == "dash"
        @dasherize_method.call(key)
      else
        key
      end
    end

    def content_type_check(content_type)
      content_type =~ /application\/json/
    end

    def camelize(string)
      string.underscore.camelize(:lower)
    end

    def dasherize(string)
      string.dasherize
    end

    def underscore_params(env)
      req = ActionDispatch::Request.new(env)
      req.request_parameters
      req.query_parameters

      env["action_dispatch.request.request_parameters"].deep_transform_keys!(&:underscore)
      env["action_dispatch.request.query_parameters"].deep_transform_keys!(&:underscore)
    end
  end
end
