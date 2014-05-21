module SuiteRest
  class RestService

    attr_accessor :type, :script_id, :deploy_id, :args

    def initialize(svc_def)
      @type = svc_def[:type]
      @script_id = svc_def[:script_id]
      @deploy_id = svc_def[:deploy_id]
      @args = svc_def[:args]
    end

    def uri
      if SuiteRest.configuration.sandbox
        "https://rest.sandbox.netsuite.com/app/site/hosting/restlet.nl?script=#{script_id}&deploy=#{deploy_id}"
      else
        "https://rest.netsuite.com/app/site/hosting/restlet.nl?script=#{script_id}&deploy=#{deploy_id}"
      end
    end
    
  end
end