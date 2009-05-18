require 'multipart'
require 'uri'

module OAuthActiveResource
  class Resource < ActiveResource::Base
    @oauth_connection = nil # Defaults to be anonymous

    class << self
      attr_accessor :oauth_connection
    end
    
    def self.connection(refresh = false)
      @connection = Connection.new(oauth_connection, site,format) if @connection.nil? || refresh
      @connection.timeout = timeout if timeout      
      return @connection      
    end
    
    #TODO remove when soundcloud api is fixed
    # if self has no id, try extracting from uri
    def load(*args)
      super(*args)  
      self.id = self.uri.split('/').last if self.id.nil? and defined? self.uri
    end
     
    # has_many allows resources with sub-resources which arent nested to be accessable.
    #
    # Example:
    # User 123 (http://example.com/users/123/) has many friends
    # The list of friends can be accessed by http://example.com/users/123/friends
    # Our class definition:
    # 
    #   class User < Resource
    #     has_many :friends
    #   end
    # 
    #   user = User.find(123)
    #   user.friends.each do |friend|
    #     p friend.name
    #   end
    # 
    #   # adding a friend 
    #   stranger = User.find(987)
    #   user.friends << stranger
    #   user.friends.save
    #  => sends a PUT with collection of friends to http://example.com/users/123/friends
    
    def self.has_many(*args)
      args.each do |k| 
        name = k.to_s
        singular = name.singularize
        define_method(k) do          
          if @has_many_cache.nil?
            @has_many_cache = {}
          end
          if not @has_many_cache[name]
            uri = "/#{self.element_name.pluralize}/#{self.id}/#{name}"
            resource  = find_or_create_resource_for(singular)
            @has_many_cache[name] = OAuthActiveResource::Collection.new(self.connection,resource,uri)
          end
          return @has_many_cache[name]          
        end
      end
    end
    
    
    # allows you to POST/PUT an oauth authenticated multipart request
    def self.send_multipart_request(method,path,file_param_name,file,params={})
      req = Net::HTTP::Post.new(path)
      if method == :put
        params[:_method] = "PUT"
      end
      post_file = Net::HTTP::FileForPost.new(file)
      req.set_multipart_data({file_param_name => post_file},params)     

      oauth_connection.sign!(req)                  
      uri = URI.parse oauth_connection.consumer.site      
      
      res = Net::HTTP.new(uri.host,uri.port).start do |http|
        http.request(req)
      end
      res
    end
  end
end
