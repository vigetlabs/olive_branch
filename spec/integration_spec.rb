require 'rails_helper'

RSpec.describe 'Integration Test', :type => :request do
  let(:url) { '/posts/1234?categoryFilter[categoryName][]=food' }
  let(:headers) do
    { "CONTENT_TYPE" => "application/json", 'X-Key-Inflection' => 'camel' }
  end
  let(:params) do
    { 'post' => { 'authorName' => 'John Smith' } }
  end

  context "when the X-Key-Inflection HTTP header is set to 'camel'" do
    it "should transform response keys to camel case" do
      put_request

      payload = JSON.parse(response.body)

      expect(payload['postAuthorName']).to eq 'John Smith'
      expect(payload['categoryFilterName']).to eq ['food']
    end

    it "should set the controller's params to be underscored for the request/query parameters" do
      put_request

      req_params = JSON.parse(request.env['params_spy'].to_json).with_indifferent_access

      expect(req_params).to include(post: { author_name: 'John Smith' }, category_filter: { category_name: ['food'] })
    end

    it "should NOT transform the path params in the controller's params" do
      put_request

      req_params = JSON.parse(request.env['params_spy'].to_json).with_indifferent_access

      expect(req_params).to include(postId: "1234")
    end
  end

  context "when the X-Key-Inflection HTTP header is not set" do
    let(:headers) { { "CONTENT_TYPE" => "application/json" } }

    it "should NOT transform response keys" do
      put_request

      payload = JSON.parse(response.body)

      expect(payload['postAuthorName']).to be_nil
      expect(payload['categoryFilterName']).to be_nil
      expect(payload).to include('post_author_name', 'category_filter_name')
    end

    it "should NOT transform the controller's params' keys" do
      put_request

      req_params = JSON.parse(request.env['params_spy'].to_json).with_indifferent_access

      expect(req_params).to include(params)
    end

    it "should NOT transform the path params in the controller's params" do
      put_request

      req_params = JSON.parse(request.env['params_spy'].to_json).with_indifferent_access

      expect(req_params).to include(postId: "1234")
    end
  end

  def put_request
    if Rails::VERSION::MAJOR >= 5
      put url, params: params.to_json, headers: headers
    else
      put url, params.to_json, headers
    end
  end
end
