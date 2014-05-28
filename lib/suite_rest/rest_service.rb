module SuiteRest
  class RestService
    attr_accessor :type, :script_id, :deploy_id, :args_def

    def initialize(service_def)
      @type = service_def[:type]
      @script_id = service_def[:script_id]
      @deploy_id = service_def[:deploy_id]
      @args_def = service_def[:args_def]
    end

    def self.service_uri(script_id, deploy_id, is_sandbox)
      if is_sandbox
        "https://rest.sandbox.netsuite.com/app/site/hosting/restlet.nl?script=#{script_id}&deploy=#{deploy_id}"
      else
        "https://rest.netsuite.com/app/site/hosting/restlet.nl?script=#{script_id}&deploy=#{deploy_id}"
      end
    end

    def self.parsed_uri(script_id, deploy_id, is_sandbox, args="")
        URI.parse(self.service_uri(script_id, deploy_id, is_sandbox) + URI.escape(args))
    end

    def self.http(parsed_uri)
      http = Net::HTTP.new(parsed_uri.host, parsed_uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http
    end

    def self.camel_case_lower(a_string)
      a_string.split('_').inject([]){ |buffer,e| buffer.push(buffer.empty? ? e : e.capitalize) }.join
    end

    def self.add_request_fields(request, auth_string)
      request.add_field("Authorization", auth_string)
      request.add_field("Content-Type", "application/json")
      #request.add_field("Content-Type", "text/plain") should this be an init option?
    end

    def self.urlify(args, args_def)
      url_string = ""
      args_def.each do |arg_def|
        url_string = "#{url_string}&#{self.camel_case_lower(arg_def.to_s)}=#{args[arg_def]}"
      end
      url_string
    end

    def self.payloadify(args, args_def)
      payload = {}
      args_def.each do |arg_def|
        payload[self.camel_case_lower(arg_def.to_s)] = args[arg_def]
      end
      payload.to_json
    end

    def self.parse_body(body)
      begin
        JSON.parse(body)
      rescue JSON::ParserError
        body.gsub(/"/, '')
        # TODO? detect if this could be cast as an int, bool, or double and return as appropriate
      end
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