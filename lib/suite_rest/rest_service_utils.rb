module SuiteRest
  module RestServiceUtils
    extend self

    def service_uri(script_id, deploy_id, is_sandbox)
      if is_sandbox
        "https://rest.sandbox.netsuite.com/app/site/hosting/restlet.nl?script=#{script_id}&deploy=#{deploy_id}"
      else
        "https://rest.netsuite.com/app/site/hosting/restlet.nl?script=#{script_id}&deploy=#{deploy_id}"
      end
    end

    def parsed_uri(script_id, deploy_id, is_sandbox, args="")
        URI.parse(self.service_uri(script_id, deploy_id, is_sandbox) + URI.escape(args))
    end

    def http(parsed_uri)
      http = Net::HTTP.new(parsed_uri.host, parsed_uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http
    end

    def camel_case_lower(a_string)
      a_string.split('_').inject([]){ |buffer,e| buffer.push(buffer.empty? ? e : e.capitalize) }.join
    end

    def add_request_fields(request, auth_string)
      request.add_field("Authorization", auth_string)
      request.add_field("Content-Type", "application/json")
      #request.add_field("Content-Type", "text/plain") should this be an init option?
    end

    def urlify(args, args_def)
      url_string = ""
      args_def.each do |arg_def|
        url_string = "#{url_string}&#{self.camel_case_lower(arg_def.to_s)}=#{args[arg_def]}"
      end
      url_string
    end

    def payloadify(args, args_def)
      payload = {}
      args_def.each do |arg_def|
        payload[self.camel_case_lower(arg_def.to_s)] = args[arg_def]
      end
      payload.to_json
    end
    
    def check_response(http_response)
      if http_response.code == "200"
        return http_response
      else
        raise "Error Code #{http_response.code}: #{http_response.msg}"
      end
    end

    def parse_body(body)
      begin
        JSON.parse(body)
      rescue JSON::ParserError
        string_body = body.gsub(/"/, '')

        if string_body == string_body.to_i.to_s
          return string_body.to_i
        elsif string_body == string_body.to_f.to_s
          return string_body.to_f
        elsif string_body == 'null'
          return nil
        elsif string_body.start_with?("org.mozilla.javascript.Undefined")
          return nil
        elsif string_body == 'false'
          return false
        elsif string_body == 'true'
          return true
        else
          return string_body
        end
      end
    end

  end
end
