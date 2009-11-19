require 'rubygems'

gem 'oauth', '>= 0.3.6'
require 'oauth'

require 'spec_helper'

describe "OauthActiveResource" do
  
  it "should register a new Module fork" do
    cl = TestClient.register
  end
  
  it "should destroy it self" do
    consumer_token = OAuth::ConsumerToken.new('test123','test123')
    access_token = OAuth::AccessToken.new(consumer_token, 'access_token', 'access_secret')
    
    old_count = TestClient.constants.count      
    sc = TestClient.register({:access_token => access_token })
    TestClient.constants.count.should be (old_count+1)
    sc.destroy
    TestClient.constants.count.should be old_count   
  end
end
