$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'oauth'
require 'oauth_active_resource'

RSpec.configure do |config|
  
end

# Test Modul
module TestClient
  def self.register(options = {})
    OAuthActiveResource.register(self.ancestors.first, self.ancestors.first.const_get('Models'), options)      
  end
  module Models
    class XZ < OAuthActiveResource::Resource
    end
  end
end
