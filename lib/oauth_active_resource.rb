require 'rubygems'

gem 'activeresource'
require 'active_resource'

gem 'oauth'
require 'oauth'

require 'digest/md5'

module OAuthActiveResource
  # TODO check if klass has ancestor OAuthActiveResource
  def self.register(add_to_module, model_module, options = {})
    oauth_connection = options[:access_token]
    
    if oauth_connection.nil?
      oauth_connection = FakeOAuthAccessToken.new
    end
    
    site = options[:site]

    mod = Module.new do
      model_module.constants.each do |klass|
        # TODO check if klass.is_a OAuthActiveResource
        sub = Class.new(model_module.const_get(klass)) do
          self.site = site
          @oauth_connection = oauth_connection
        end
        const_set(klass, sub)
      end
      
      def self.method_missing(name,*args)
        self.const_get(name)
      rescue
        super(name,*args)
      end
      
      def self.destroy
        name =  self.model_name.split('::').last
        self.parent.send :remove_const, name
      end
    end
    
    # Obscure (=Hash) token+secret, b/c it should stay one
    if oauth_connection.nil?
      dynamic_module_name = "AnonymousConsumer"
    else
      hash = Digest::MD5.hexdigest("#{oauth_connection.token}#{oauth_connection.secret}")
      dynamic_module_name = "OAuthConsumer#{hash}"
    end
    
    if add_to_module.const_defined? dynamic_module_name
      mod = add_to_module.const_get dynamic_module_name
    else
      add_to_module.const_set(dynamic_module_name, mod)
    end
    
    return mod
  end
end

require File.expand_path('oauth_active_resource/connection',              File.dirname(__FILE__))
require File.expand_path('oauth_active_resource/resource',                File.dirname(__FILE__))
require File.expand_path('oauth_active_resource/unique_resource_array',   File.dirname(__FILE__))
require File.expand_path('oauth_active_resource/fake_oauth_access_token', File.dirname(__FILE__))
