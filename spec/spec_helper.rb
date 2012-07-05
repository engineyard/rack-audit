Bundler.require(:test)

require File.expand_path('../../lib/rack-audit', __FILE__)

RSpec.configure do |config|
  config.include(Rack::Test::Methods)
end
