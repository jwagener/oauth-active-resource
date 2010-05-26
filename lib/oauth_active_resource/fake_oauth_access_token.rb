module OAuthActiveResource
  # just simulates the request and sign! methods of a oauth access token
  class FakeOAuthAccessToken < ::OAuth::Consumer
    attr_accessor :token, :secret
    def initialize()
      @key    = nil
      token   = 'Anonymous'
      secret  = 'Anonymous'
      
      # ensure that keys are symbols
      @options = @@default_options
    end
    
    def request(http_method, path, token = nil, request_options = {}, *arguments)
      if path !~ /^\//
        @http = create_http(path)
        _uri = URI.parse(path)
        path = "#{_uri.path}#{_uri.query ? "?#{_uri.query}" : ""}"
      end

      http.request(create_http_request(http_method, path, token, request_options, *arguments))
    end
    
    def get(path, headers = {})
      request(:get, path, headers)
    end
 
    def head(path, headers = {})
      request(:head, path, headers)
    end
 
    def post(path, body = '', headers = {})
      request(:post, path, body, headers)
    end

    def put(path, body = '', headers = {})
      request(:put, path, body, headers)
    end

    def delete(path, headers = {})
      request(:delete, path, headers)
    end
    
    def sign!(*args)
      # do nothing
    end
  end
end
