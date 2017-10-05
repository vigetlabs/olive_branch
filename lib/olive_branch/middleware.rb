require "multi_json"

module OliveBranch
  class Checks
    def self.content_type_check(content_type)
      content_type =~ /application\/json/
    end
  end

  class Transformations
    class << self
      def transform(value, transform_method)
        case value
        when Array then value.map { |item| transform(item, transform_method) }
        when Hash then value.deep_transform_keys! { |key| transform(key, transform_method) }
        when String then transform_method.call(value)
        else value
        end
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

  class Middleware
    def initialize(app, args = {})
      @app = app
      @camelize = args[:camelize] || Transformations.method(:camelize)
      @dasherize = args[:dasherize] || Transformations.method(:dasherize)
      @content_type_check = args[:content_type_check] || Checks.method(:content_type_check)
      @default_inflection = args[:inflection]
    end

    def call(env)
      inflection = env["HTTP_X_KEY_INFLECTION"] || @default_inflection

      if inflection && @content_type_check.call(env["CONTENT_TYPE"])
        Transformations.underscore_params(env)
      end

      @app.call(env).tap do |_status, headers, response|
        next unless inflection && @content_type_check.call(headers["Content-Type"])
        response.each do |body|
          begin
            new_response = MultiJson.load(body)
          rescue MultiJson::ParseError
            next
          end

          Transformations.transform(new_response, inflection_method(inflection))

          body.replace(MultiJson.dump(new_response))
        end
      end
    end

    private

    def inflection_method(inflection)
      if inflection == "camel"
        @camelize
      elsif inflection == "dash"
        @dasherize
      else
        # probably misconfigured, do nothing
        -> (string) { string }
      end
    end
  end
end
