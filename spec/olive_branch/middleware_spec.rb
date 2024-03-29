require "rails_helper"

RSpec.describe OliveBranch::Middleware do
  describe "modifying request" do
    let(:params) do
      {
        "action_dispatch.request.request_parameters" => {
          "post" => {
            "authorName" => "Adam Smith"
          }
        }
      }
    end

    it "snake cases incoming params if content-type JSON and inflection header present" do
      incoming_params = nil

      app = -> (env) do
        incoming_params = env["action_dispatch.request.request_parameters"]
        [200, {}, ["{}"]]
      end

      env = params.merge(
        "CONTENT_TYPE"        => "application/json",
        "HTTP_KEY_INFLECTION" => "camel"
      )

      described_class.new(app).call(env)

      expect(incoming_params["post"]["author_name"]).not_to be_nil
    end

    it "snake cases incoming query params if content-type JSON and inflection header present" do
      incoming_params = nil

      app = -> (env) do
        incoming_params = env["action_dispatch.request.query_parameters"]
        [200, {}, ["{}"]]
      end

      env = params.merge(
        "CONTENT_TYPE"        => "application/json",
        "HTTP_KEY_INFLECTION" => "camel",
        "QUERY_STRING" => "categoryFilter[categoryName]=economics",
      )

      described_class.new(app).call(env)

      expect(incoming_params["category_filter"]["category_name"]).to eq "economics"
    end

    it 'snake cases incoming query with JSON and pascal inflection' do
      incoming_params = nil

      app = lambda do |env|
        incoming_params = env['action_dispatch.request.query_parameters']
        [200, {}, ['{}']]
      end

      env = params.merge(
        'CONTENT_TYPE' => 'application/json',
        'HTTP_KEY_INFLECTION' => 'pascal',
        'QUERY_STRING' => 'CategoryFilter[CategoryName]=economics'
      )

      described_class.new(app).call(env)

      expect(
        incoming_params['category_filter']['category_name']
      ).to eq 'economics'
    end

    it "does not modify incoming params if content-type not JSON" do
      incoming_params = nil

      app = -> (env) do
        incoming_params = env["action_dispatch.request.request_parameters"]
        [200, {}, ["{}"]]
      end

      env = params.merge(
        "CONTENT_TYPE"        => "text/html",
        "HTTP_KEY_INFLECTION" => "camel"
      )

      described_class.new(app).call(env)

      expect(incoming_params["post"]["authorName"]).not_to be_nil
    end

    it "does not modify incoming params if exclude returns true" do
      incoming_params = nil

      app = -> (env) do
        incoming_params = env["action_dispatch.request.request_parameters"]
        [200, {}, ["{}"]]
      end

      env = params.merge(
        "CONTENT_TYPE"        => "application/json",
        "HTTP_KEY_INFLECTION" => "camel",
        "PATH_INFO"             => "/do_not_transform"
      )

      exclude_params = proc do |env|
        path = env["PATH_INFO"]
        !!path.match(/^\/do_not_transform/)
      end

      described_class.new(app, exclude_params: exclude_params).call(env)

      expect(incoming_params["post"]["authorName"]).not_to be_nil
    end

    it "does not modify incoming params if inflection header missing" do
      incoming_params = nil

      app = -> (env) do
        incoming_params = env["action_dispatch.request.request_parameters"]
        [200, {}, ["{}"]]
      end

      env = params.merge("CONTENT_TYPE" => "application/json")

      described_class.new(app).call(env)

      expect(incoming_params["post"]["authorName"]).not_to be_nil
    end

    context "with a custom content type check" do
      let(:content_type_check) do
        ->(content_type) { content_type == "foo/type" }
      end

      it "snake cases incoming params if content-type matches the custom check" do
        incoming_params = nil

        app = -> (env) do
          incoming_params = env["action_dispatch.request.request_parameters"]
          [200, {}, ["{}"]]
        end

        env = params.merge(
          "CONTENT_TYPE"        => "foo/type",
          "HTTP_KEY_INFLECTION" => "camel"
        )

        described_class.new(app, content_type_check: content_type_check).call(env)

        expect(incoming_params["post"]["author_name"]).not_to be_nil
      end

      it "does not modify incoming params if content-type not matching custom check" do
        incoming_params = nil

        app = -> (env) do
          incoming_params = env["action_dispatch.request.request_parameters"]
          [200, {}, ["{}"]]
        end

        env = params.merge(
          "CONTENT_TYPE"        => "application/json",
          "HTTP_KEY_INFLECTION" => "camel"
        )

        described_class.new(app, content_type_check: content_type_check).call(env)

        expect(incoming_params["post"]["authorName"]).not_to be_nil
      end
    end
  end

  describe "modifying response" do
    it "camel-cases response if JSON and inflection header present" do
      app = -> (env) do
        [
          200,
          { "Content-Type" => "application/json" },
          ['{"post":{"author_name":"Adam Smith","author-hobby":"Economics"}}']
        ]
      end

      request = Rack::MockRequest.new(described_class.new(app))

      response = request.get("/", "HTTP_KEY_INFLECTION" => "camel")

      expect(JSON.parse(response.body)["post"]["authorName"]).not_to be_nil
      expect(JSON.parse(response.body)["post"]["authorHobby"]).not_to be_nil
    end

    it 'camel-cases array response if JSON and inflection header present' do
      app = lambda do |_env|
        [
          200,
          { 'Content-Type' => 'application/json' },
          ['[{"author_name":"Adam Smith","author-hobby":"Economics"}]']
        ]
      end

      request = Rack::MockRequest.new(described_class.new(app))

      response = request.get('/', 'HTTP_KEY_INFLECTION' => 'camel')

      expect(JSON.parse(response.body)[0]['authorName']).not_to be_nil
      expect(JSON.parse(response.body)[0]['authorHobby']).not_to be_nil
    end

    it "dash-cases response if JSON and inflection header present" do
      app = -> (env) do
        [
          200,
          { "Content-Type" => "application/json" },
          ['{"post":{"author_name":"Adam Smith"}}']
        ]
      end

      request = Rack::MockRequest.new(described_class.new(app))

      response = request.get("/", "HTTP_KEY_INFLECTION" => "dash")

      expect(JSON.parse(response.body)["post"]["author-name"]).not_to be_nil
    end

    it 'dash-cases array response if JSON and inflection header present' do
      app = lambda do |_env|
        [
          200,
          { 'Content-Type' => 'application/json' },
          ['[{"author_name":"Adam Smith"}]']
        ]
      end

      request = Rack::MockRequest.new(described_class.new(app))

      response = request.get('/', 'HTTP_KEY_INFLECTION' => 'dash')

      expect(JSON.parse(response.body)[0]['author-name']).not_to be_nil
    end

    it 'pascal-cases response if JSON and inflection header are present' do
      app = lambda do |_env|
        [
          200,
          { 'Content-Type' => 'application/json' },
          ['{"post":{"author_name":"Adam Smith"}}']
        ]
      end

      request = Rack::MockRequest.new(described_class.new(app))

      response = request.get('/', 'HTTP_KEY_INFLECTION' => 'pascal')
      expect(JSON.parse(response.body)['Post']['AuthorName']).not_to be_nil
    end

    it 'pascal-cases array response if JSON and inflection header present' do
      app = lambda do |_env|
        [
          200,
          { 'Content-Type' => 'application/json' },
          ['[{"author_name":"Adam Smith","author-hobby":"Economics"}]']
        ]
      end

      request = Rack::MockRequest.new(described_class.new(app))

      response = request.get('/', 'HTTP_KEY_INFLECTION' => 'pascal')

      expect(JSON.parse(response.body)[0]['AuthorName']).not_to be_nil
      expect(JSON.parse(response.body)[0]['AuthorHobby']).not_to be_nil
    end

    it "does not modify response if exclude returns true" do
      app = -> (env) do
        [
          200,
          { "Content-Type" => "application/json" },
          ['{"post":{"author_name":"Adam Smith"}}']
        ]
      end

      exclude_response = proc do |env|
        path = env["PATH_INFO"]
        !!path.match(/^\/do_not_transform/)
      end

      request = Rack::MockRequest.new(described_class.new(app, exclude_response: exclude_response))

      response = request.get("/do_not_transform", "HTTP_KEY_INFLECTION" => "camel")

      expect(JSON.parse(response.body)["post"]["author_name"]).not_to be_nil
    end

    it 'excludes rails routes by default' do
      app = lambda do |_env|
        [
          200,
          { 'Content-Type' => 'application/json' },
          ['{"direct_upload_token": "value1", "attachment_name": "value2"}']
        ]
      end

      request = Rack::MockRequest.new(described_class.new(app))

      response = request.get('/rails', 'HTTP_KEY_INFLECTION' => 'camel')

      expect(JSON.parse(response.body)['direct_upload_token']).to eq 'value1'
      expect(JSON.parse(response.body)['attachment_name']).to eq 'value2'
    end

    it "does not modify response if not JSON " do
      app = -> (env) do
        [
          200,
          { "Content-Type" => "text/html" },
          ['{"post":{"author_name":"Adam Smith"}}']
        ]
      end

      request = Rack::MockRequest.new(described_class.new(app))

      response = request.get("/", "HTTP_KEY_INFLECTION" => "camel")

      expect(JSON.parse(response.body)["post"]["author_name"]).not_to be_nil
    end

    it "does not modify response if inflection header missing" do
      app = -> (env) do
        [
          200,
          { "Content-Type" => "application/json" },
          ['{"post":{"author_name":"Adam Smith"}}']
        ]
      end

      request = Rack::MockRequest.new(described_class.new(app))

      response = request.get("/")

      expect(JSON.parse(response.body)["post"]["author_name"]).not_to be_nil
    end

    it "does not modify response if invalid JSON" do
      app = -> (env) do
        [
          200,
          { "Content-Type" => "application/json" },
          ['{"post":{"author_name":"Adam Smith"}']
        ]
      end

      request = Rack::MockRequest.new(described_class.new(app))

      response = request.get("/", "HTTP_KEY_INFLECTION" => "camel")

      expect(response.body =~ /author_name/).not_to be_nil
    end

    context "with custom camelize method" do
      let(:camelize) do
        ->(string) { "camel#{string}" }
      end

      it "uses the custom camelize method" do
        app = -> (env) do
          [
            200,
            { "Content-Type" => "application/json" },
            ['{"post":{"author_name":"Adam Smith","author-hobby":"Economics"}}']
          ]
        end

        request = Rack::MockRequest.new(described_class.new(app, camelize: camelize))

        response = request.get("/", "HTTP_KEY_INFLECTION" => "camel")

        expect(JSON.parse(response.body)["camelpost"]["camelauthor_name"]).not_to be_nil
        expect(JSON.parse(response.body)["camelpost"]["camelauthor-hobby"]).not_to be_nil
      end
    end

    context "with custom dasherize method" do
      let(:dasherize) do
        ->(string) { "dash#{string}" }
      end

      it "uses the custom dasherize method" do
        app = -> (env) do
          [
            200,
            { "Content-Type" => "application/json" },
            ['{"post":{"author_name":"Adam Smith","author-hobby":"Economics"}}']
          ]
        end

        request = Rack::MockRequest.new(described_class.new(app, dasherize: dasherize))

        response = request.get("/", "HTTP_KEY_INFLECTION" => "dash")

        expect(JSON.parse(response.body)["dashpost"]["dashauthor_name"]).not_to be_nil
        expect(JSON.parse(response.body)["dashpost"]["dashauthor-hobby"]).not_to be_nil
      end
    end

    context "with a default inflection" do
      it "uses the default inflection" do
        app = -> (env) do
          [
            200,
            { "Content-Type" => "application/json" },
            ['{"post":{"author_name":"Adam Smith"}}']
          ]
        end

        request = Rack::MockRequest.new(described_class.new(app, inflection: 'camel'))

        response = request.get("/")

        expect(JSON.parse(response.body)["post"]["authorName"]).not_to be_nil
      end
    end

    context "with frozen strings" do
      it "dups the string before replacing" do
        app = -> (env) do
          [
            200,
            { "Content-Type" => "application/json" },
            ['{"post":{"author_name":"Adam Smith"}}'.freeze]
          ]
        end

        request = Rack::MockRequest.new(described_class.new(app, inflection: 'camel'))

        response = request.get("/")

        expect(JSON.parse(response.body)["post"]["authorName"]).not_to be_nil
      end
    end
  end
end
