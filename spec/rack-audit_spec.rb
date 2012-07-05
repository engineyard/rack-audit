require 'spec_helper'

describe Rack::Audit do
  def app
    Rack::Builder.new do
      use Rack::Audit, "test", "http://example.org"
      run lambda{|env| [200, {"Content-Type" => "application/wtf"}, ["check out my body"]]}
    end
  end

  it "should perserve the request" do
    response = get "/"
    response.body.should == "check out my body"
    response.headers.should == {"Content-Type" => "application/wtf", "Content-Length" => "17"}
    response.status.should == 200
  end
end
