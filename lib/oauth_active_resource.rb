require 'activeresource'
require 'digest/md5'

module OAuthActiveResource

  # TODO check if klass has ancestor OAuthActiveResource
  def self.register(add_to_module, model_module, options = {})
    
    oauth_connection = options[:access_token]
    site = options[:site]
#    if options[:access_token].nil?
#      access_token = nil
#      if options[:site].nil?
#        raise 'Need an oauth :access_token or a :site'
#      else
#        site = options[:site]
#      end
#    else
#      if options[:site].nil?
#        site = access_token.consumer.site
#      else
#       site = options[:site]
#      end      
#    end
    
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
      
    end
    
    # Obscure (=Hash) token+secret, b/c it should stay one
    if oauth_connection.nil?
      dynamic_module_name = "AnonymousConsumer"
    else
      hash = Digest::MD5.hexdigest("#{oauth_connection.token}#{oauth_connection.secret}")      
      dynamic_module_name = "OAuthConsumer#{hash}"
    end
    
    add_to_module.const_set(dynamic_module_name, mod)
    return mod
  end
  
end


require 'oauth_active_resource/connection'
require 'oauth_active_resource/resource'
require 'oauth_active_resource/collection'

