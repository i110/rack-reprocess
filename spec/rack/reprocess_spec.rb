require "spec_helper"
require 'rack'
require 'rack/test'

RSpec.describe Rack::Reprocess do
  include Rack::Test::Methods

  let(:app) {
    reporter = lambda{|env|
      [200, { 'X-Script-Name' => env['SCRIPT_NAME'], 'X-Path-Info' => env['PATH_INFO']}, []]
    }

    Rack::Builder.new {
      map '/' do
        use Rack::Reprocessable
        map '/foo' do
          run Rack::Reprocess.new {|env| "/bar#{env['PATH_INFO']}" }
        end

        map '/bar' do
          run reporter
        end

        map '/nested-trap' do
          use Rack::Reprocessable
          map '/hoge' do
            run Rack::Reprocess.new '/nested-trap/fuga'
          end
          map '/fuga' do
            run reporter
          end
        end

        map '/nested-bubble' do
          map '/hoge' do
            run Rack::Reprocess.new '/bar'
          end
        end

      end

      map '/unprocessable' do
        run Rack::Reprocess.new {|env| '/' }
      end
    }.to_app
  }

  it "has a version number" do
    expect(Rack::Reprocess::VERSION).not_to be nil
  end


  it "reprocesses request" do
    get '/foo/baz'
    expect(last_response.status).to eq 200
    expect(last_response.header['X-Script-Name']).to eq '/bar'
    expect(last_response.header['X-Path-Info']).to eq '/baz'
  end

  it "traps nested reprocess" do
    get '/nested-trap/hoge/xxx'
    expect(last_response.status).to eq 200
    expect(last_response.header['X-Script-Name']).to eq '/nested-trap/fuga'
    expect(last_response.header['X-Path-Info']).to eq ''
  end

  it "bubbles nested reprocess" do
    get '/nested-bubble/hoge/xxx'
    expect(last_response.status).to eq 200
    expect(last_response.header['X-Script-Name']).to eq '/bar'
    expect(last_response.header['X-Path-Info']).to eq ''
  end

  it "fails when reprocess in unprosessable path" do
    expect { get '/unprocessable' }.to raise_error(RuntimeError)
  end

end
