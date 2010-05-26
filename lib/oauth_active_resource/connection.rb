module OAuthActiveResource
  class Connection < ActiveResource::Connection
    def initialize(oauth_connection, *args)
      @oauth_connection = oauth_connection
      super(*args)
    end

    # an alternative for the get method, which doesnt tries to decode the response
    def get_without_decoding(path, headers = {})
      request(:get, path, build_request_headers(headers, :get))
    end
    
    # make handle_response public and add error message from body if possible
    def handle_response(response)
      return super(response)
    rescue ActiveResource::ClientError => exc
      begin
        # ugly code to insert the error_message into response
        error_message = "#{format.decode response.body}"
        if not error_message.nil? or error_message == ""
          exc.response.instance_eval do ||
            @message = error_message
          end
        end
      ensure
        raise exc
      end
    end
    
  private
    def request(method, path, *arguments)
      if @oauth_connection == nil
        super(method, path, *arguments)
      else
        response = @oauth_connection.request(method, "#{site.scheme}://#{site.host}:#{site.port}#{path}", *arguments)
        handle_response(response)
      end
    rescue Timeout::Error => e
      raise TimeoutError.new(e.message)
    end
  end
end
