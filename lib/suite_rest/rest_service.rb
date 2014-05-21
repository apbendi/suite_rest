module SuiteRest
  class RestService

    attr_accessor :type, :script_id, :deploy_id, :args

    def initialize(service_def)
      @type = service_def[:type]
      @script_id = service_def[:script_id]
      @deploy_id = service_def[:deploy_id]
      @args = service_def[:args]
    end

    def service_uri
      if SuiteRest.configuration.sandbox
        "https://rest.sandbox.netsuite.com/app/site/hosting/restlet.nl?script=#{script_id}&deploy=#{deploy_id}"
      else
        "https://rest.netsuite.com/app/site/hosting/restlet.nl?script=#{script_id}&deploy=#{deploy_id}"
      end
    end

  end
end