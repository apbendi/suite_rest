module SuiteRest
  class RestService

    extend SuiteRest::RestServiceUtils
    attr_accessor :type, :script_id, :deploy_id, :args_def

    def initialize(service_def)
      @type = service_def[:type]
      @script_id = service_def[:script_id]
      @deploy_id = service_def[:deploy_id]
      @args_def = service_def[:args_def]
    end

    def get_or_delete(args={})
      uri = self.class.parsed_uri(@script_id, @deploy_id, 
        SuiteRest.configuration.sandbox, self.class.urlify(args, @args_def))
      http = self.class.http(uri)

      case @type
      when :get
        request = Net::HTTP::Get.new(uri.request_uri)
      when :delete
        request = Net::HTTP::Delete.new(uri.request_uri)
      end

      self.class.add_request_fields(request, SuiteRest.configuration.auth_string)
      response = http.request(request)
      
      # TODO? Error checking

      if @type == :delete
        # By NS definition, delete restlets should not return anything, so we'll
        # return true/false based on server response
        response.instance_of?(Net::HTTPOK)
      else
        self.class.parse_body(response.body)
      end
    end

    def post_or_put(args={})
      uri = self.class.parsed_uri(@script_id, @deploy_id, SuiteRest.configuration.sandbox)
      http = self.class.http(uri)

      case @type
      when :put
        request = Net::HTTP::Put.new(uri.request_uri)
      when :post
        request = Net::HTTP::Post.new(uri.request_uri)
      end

      self.class.add_request_fields(request, SuiteRest.configuration.auth_string)
      request.body = self.class.payloadify(args, @args_def)

      response = http.request(request)

      # TODO? Error checking

      self.class.parse_body(response.body)
    end

    alias_method :put, :post_or_put
    alias_method :post, :post_or_put
    alias_method :get, :get_or_delete
    alias_method :delete, :get_or_delete

    def call(args={})
      case @type
      when :put
        self.put(args)
      when :post
        self.post(args)
      when :get
        self.get(args)
      when :delete
        self.delete(args)
      else
        raise "Invalid Service Type :#{@type}, use :get, :put, :post, or :delete"
      end
    end
  end
end