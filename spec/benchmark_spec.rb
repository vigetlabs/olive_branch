require 'rails_helper'

BENCHMARK_REPETITIONS ||= Integer(ENV["BENCHMARK_REPETITIONS"] || 0)

if BENCHMARK_REPETITIONS > 0
  RSpec.describe 'Benchmark thingerer', :type => :request do
    let(:url) { '/posts/complex' }
    let(:headers) do
      { "CONTENT_TYPE" => "application/json", 'X-Key-Inflection' => 'camel' }
    end

    context "when the X-Key-Inflection HTTP header is set to 'camel'" do
      it "benchmarks 1000 repetitions" do
        Benchmark.bm do |x|
          x.report("time taken ") { BENCHMARK_REPETITIONS.times { get_request } }
        end
      end
    end

    def get_request
      if Rails::VERSION::MAJOR >= 5
        get url, headers: headers
      else
        get url, headers
      end
    end
  end
end
