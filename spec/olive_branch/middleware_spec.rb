require "spec_helper"

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
        "HTTP_X_KEY_INFLECTION" => "camel"
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
        "HTTP_X_KEY_INFLECTION" => "camel",
        "QUERY_STRING" => "categoryFilter[categoryName]=economics",
      )

      described_class.new(app).call(env)

      expect(incoming_params["category_filter"]["category_name"]).to eq "economics"
    end

    it "does not modify incoming params if content-type not JSON" do
      incoming_params = nil

      app = -> (env) do
        incoming_params = env["action_dispatch.request.request_parameters"]
        [200, {}, ["{}"]]
      end

      env = params.merge(
        "CONTENT_TYPE"        => "text/html",
        "HTTP_X_KEY_INFLECTION" => "camel"
      )

      described_class.new(app).call(env)

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

      response = request.get("/", "HTTP_X_KEY_INFLECTION" => "camel")

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

      response = request.get('/', 'HTTP_X_KEY_INFLECTION' => 'camel')

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

      response = request.get("/", "HTTP_X_KEY_INFLECTION" => "dash")

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

      response = request.get('/', 'HTTP_X_KEY_INFLECTION' => 'dash')

      expect(JSON.parse(response.body)[0]['author-name']).not_to be_nil
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

      response = request.get("/", "HTTP_X_KEY_INFLECTION" => "camel")

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

      response = request.get("/", "HTTP_X_KEY_INFLECTION" => "camel")

      expect(response.body =~ /author_name/).not_to be_nil
    end
  end
end
