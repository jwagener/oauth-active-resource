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
    
    def ==(other)
        return (other.is_a? Resource) && (self.is_a? Resource) && (self.element_name == other.element_name) && (self.id == other.id)
      rescue
        return super(other)
    end
    
    def self.load_collection(*args)
      instantiate_collection(*args)
    end

    #
    #   belongs_to :user
    #  => will look for a user-id tag and load this user
    #
    def self.belongs_to(*args)
      args.each do |k|
        name = k.to_s
        define_method(k) do
          if @belongs_to_cache.nil?
            @belongs_to_cache = {}
          end
          if not @belongs_to_cache[name]
            resource  = find_or_create_resource_for(name)
            @belongs_to_cache[name] = resource.find(self.send("#{name}_id"))
          end
          return @belongs_to_cache[name]
        end
      end
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
    #  => sends a PUT with collection of friends to http://example.com/users/123/friends ## OUTDATED!!?
    
    def self.has_many(*args)
      args.each do |k|
        name = k.to_s
        singular = name.singularize
        define_method(k) do |*options|
          
          options = options.first || {}
          #if @has_many_cache.nil?
          #  @has_many_cache = {}
          #end
          @has_many_cache ||= {}
          cache_name = "#{name}#{options.hash}"
          if not @has_many_cache[cache_name]

            collection_path = "/#{self.element_name.pluralize}/#{self.id}/#{name}"
            resource  = find_or_create_resource_for(singular)
            @has_many_cache[cache_name] = OAuthActiveResource::UniqueResourceArray.new(self.connection,resource,collection_path,options)
          end
          return @has_many_cache[cache_name]
        end
      end
    end
    
    
    # ignore is added because the multipart gem is adding an extra new line
    # to the last parameter which will break parsing of track[sharing]
    def self.multipart_bug_fix(params)
      ordered_params = ActiveSupport::OrderedHash.new
      params.each do |k,v|
        ordered_params[k] = v
      end
      ordered_params[:ignore] = 'multipart bug'
      ordered_params
    end
    
    # allows you to POST/PUT an oauth authenticated multipart request
    def self.send_multipart_request(method, path, files, params={})
      req = Net::HTTP::Post.new(path)
      if method == :put
        params[:_method] = "PUT"
      end
      
      params = multipart_bug_fix(params)
      
      file_hash = {}
      files.each do |k,v|
        file_hash[k] = Net::HTTP::FileForPost.new(v)
      end
      req.set_multipart_data(file_hash, params)
      
      oauth_connection.sign!(req) if not oauth_connection.nil?
      res = Net::HTTP.new(site.host, site.port).start do |http|
        http.request(req)
      end
      res
    end
  end
end
