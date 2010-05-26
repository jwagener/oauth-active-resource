require 'set'

module OAuthActiveResource
  class UniqueArray < Array
    def initialize(*args)
      if args.size == 1 and args[0].is_a? Array then
        super(args[0].uniq)
      else
        super(*args)
      end
    end

    def insert(i, v)
      super(i, v) unless include?(v)
    end

    def <<(v)
      super(v) unless include?(v)
    end

    def []=(*args)
      # note: could just call super(*args) then uniq!, but this is faster

      # there are three different versions of this call:
      # 1. start, length, value
      # 2. index, value
      # 3. range, value
      # We just need to get the value
      v = case args.size
        when 3 then args[2]
        when 2 then args[1]
        else nil
      end

      super(*args) if v.nil? or not include?(v)
    end
  end
  
  # see has_many in Resource
  class UniqueResourceArray < UniqueArray
    def initialize(connection, resource,  collection_path,options = {})
      super()
      
      @connection = connection
      @collection_path = collection_path
      @resource = resource
      @options = options
      reload
    end
   
    def to_json
      return "[ #{self.map { |obj| obj.to_json }.join(',')} ]"
    end
    
    def to_xml
      # or use __method__ here?
      pt = @resource.element_name.pluralize
      return "<#{pt}> #{self.map { |obj| obj.to_xml({:skip_instruct => true})}.join(' ')} </#{pt}>"
    end
    
    # DEPRECATED...
    # def find(look_for)
    #   if not (look_for.is_a? String or look_for.is_a? Integer)
    #     look_for_id = look_for
    #   else
    #     look_for_id = look_for.id
    #   end
    #
    #   self.each do |obj|
    #       obj.id == look_for_id and return obj
    #   end
    #   return nil
    # end
    
    def save
      response = @connection.handle_response( @connection.put("#{@collection_path}",self.to_xml) )
      self.replace( @resource.load_collection( @connection.format.decode(response.body) ) )
    end
    
    def reload
      self.replace(@resource.find(:all, :from => @collection_path, :params => @options))
      return self
    end
  end
end
