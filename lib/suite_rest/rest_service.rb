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

    def get(args={})
      uri_args = self.urlify(args)
      uri = self.parsed_uri(uri_args)
      http = self.http(uri)

      get_request = Net::HTTP::Get.new(uri.request_uri)
      get_request.add_field("Authorization", SuiteRest.configuration.auth_string)
      get_request.add_field("Content-Type", "application/json")

      http.request(get_request)
    end

    private

    def camel_case_lower(a_string)
      a_string.split('_').inject([]){ |buffer,e| buffer.push(buffer.empty? ? e : e.capitalize) }.join
    end
  end
end