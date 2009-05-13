require 'rubygems'
gem 'multipart'
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
     
    # Associations
    # has_many allows resources with sub-resources which arent nested to be accessable
    # Example:
    # User 123 (http://example.com/users/123/) has many friends
    # The list of friends can be accessed by http://example.com/users/123/friends
    # Our class definition:
    # 
    # class User < Resource
    #   has_many :friends
    # end
    # 
    # user = User.find(123)
    # user.friends.each do |friend|
    #   p friend.name
    # end
    # 
    # # adding a friend 
    # stranger = User.find(987)
    # user.friends << stranger
    # user.friends.save
    # => sends a PUT with collection of friends to http://example.com/users/123/friends
    
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
    
    # has_many_unbulky_changeable and can_be_an_unbulky_changeable is used in combination with has_many
    # it expects to have a resource http://example.com/me which is the logged-in user
    # Example:
    # like in self.has_many you have a resource user with a sub resource friends,
    # but its not allowed to send a PUT /me/friends to update the list of friends
    # instead to add or remove a friend you send a GET/PUT/DELETE to /me/friends/{user_id}
    # class User < Resource
    #   has_many :friends
    #   can_be_an_unbulky_changeable :friend
    #   has_many_unbulky_changeable :friends
    # end
    #
    # me = User.find(:one, :from => '/me')
    # friend = me.friends.first
    # stranger = User.find(235)
    # 
    # friend.is_friend?
    # => true
    # stranger.is_friend?
    # => false
    #
    # strange.add_friend!
    # stranger.is_friend?
    # => true
    #
    # stranger.remove_friend!
    # stranger.is_friend?
    # => false    
    #
    # friend.has_friend?(stranger.id)
    # => checks if stranger and friend are friend, returns true or false
    
    def self.can_be_an_unbulky_changeable(*args)
      args.each do |k| 
        singular = k.to_s
        define_method("is_#{singular}?") do
          begin
            self.connection.get_no_decode "/me/#{singular.pluralize}/#{self.id}"
            return true
          rescue ActiveResource::ResourceNotFound
            return false
          end
        end
        
        define_method("add_#{singular}!") do
        p "add #{singular}"
        p "/me/#{singular.pluralize}/#{self.id}"
          self.connection.put "/me/#{singular.pluralize}/#{self.id}"
        end                    

        define_method("remove_#{singular}!") do
          self.connection.delete "/me/#{singular.pluralize}/#{self.id}"
        end                
      end    
    end
        
    def self.has_many_unbulky_changeable(*args)
      args.each do |k| 
        singular = k.to_s.singularize
        define_method("has_#{singular}?") do |look_for_id|
          begin
            head,body = self.connection.get_no_decode "/#{self.element_name.pluralize}/#{self.id}/#{singular.pluralize}/#{look_for_id}"
            p head
            p body
            return true
          rescue ActiveResource::ResourceNotFound
            return false
          end          
        end
      end    
    end
    
    # self.send_multipart_request allows you to POST/PUT an oauth authenticated multipart request
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
  
  # see self.has_many
  class Collection < Set
    def initialize(connection, resource, collection_uri)        
      super()
      @connection = connection
      @collection_uri = collection_uri
      @resource = resource
      reload
    end
   
    def to_json
      return "[ #{self.map { |obj| obj.to_json }.join(',')} ]"
    end
    
    def to_xml
      raise "NotImplemented"
    end
    
    # TODO extract api.soundcloud.com
    def save
      @connection.put("#{@resource.class.site}#{@collection_uri}",self.to_json,{ 'Accept'=>'application/json', 'Content-Type' => 'application/json' })
    end
    
    def reload
      self.replace(@resource.find(:all, :from => @collection_uri))
    end
  end
end
