module SuiteRest
  class RestService
    attr_accessor :type, :script_id, :deploy_id, :args_def

    def initialize(service_def)
      @type = service_def[:type]
      @script_id = service_def[:script_id]
      @deploy_id = service_def[:deploy_id]
      @args_def = service_def[:args_def]
    end

    def service_uri
      if SuiteRest.configuration.sandbox
        "https://rest.sandbox.netsuite.com/app/site/hosting/restlet.nl?script=#{script_id}&deploy=#{deploy_id}"
      else
        "https://rest.netsuite.com/app/site/hosting/restlet.nl?script=#{script_id}&deploy=#{deploy_id}"
      end
    end

    def parsed_uri(args="")
        URI.parse(self.service_uri + URI.escape(args))
    end

    def http(parsed_uri)
      http = Net::HTTP.new(parsed_uri.host, parsed_uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http
    end

    def urlify(args)
      url_string = ""
      args_def.each do |arg_def|
        url_string = "#{url_string}&#{camel_case_lower(arg_def.to_s)}=#{args[arg_def]}"
      end
      url_string
    end

    def payloadify(args)
      payload = {}
      args_def.each do |arg_def|
        payload[camel_case_lower(arg_def.to_s)] = args[arg_def]
      end
      payload.to_json
    end

    def get(args={})
      uri = self.parsed_uri(self.urlify(args))
      http = self.http(uri)

      get_request = Net::HTTP::Get.new(uri.request_uri)
      add_request_fields(get_request)

      http.request(get_request)
    end

    def post(args={})
      uri = self.parsed_uri
      http = self.http(uri)

      post_request = Net::HTTP::Post.new(uri.request_uri)
      add_request_fields(post_request)
      post_request.body = payloadify(args)

      http.request(post_request)
    end

    def call(args={})
      case @type
      when :get
        self.get(args)
      when :post
        self.post(args)
      else
        throw "Invalid Service Type: #{@type}"
      end
    end

    private

    def camel_case_lower(a_string)
      a_string.split('_').inject([]){ |buffer,e| buffer.push(buffer.empty? ? e : e.capitalize) }.join
    end

    def add_request_fields(request)
      request.add_field("Authorization", SuiteRest.configuration.auth_string)
      request.add_field("Content-Type", "application/json")
    end
  end
end