module OAuthActiveResource
  # see has_many in Resource
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
    
    def save
      @connection.put("#{@resource.class.site}#{@collection_uri}",self.to_json,{ 'Accept'=>'application/json', 'Content-Type' => 'application/json' })
    end
    
    def reload
      self.replace(@resource.find(:all, :from => @collection_uri))
    end
  end
end
