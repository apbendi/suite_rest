require 'spec_helper'

describe SuiteRest::RestService do
  context "creating a standard get RestService" do
    let(:account)   { 12345 }
    let(:email)     { "fake@gmail.com" }
    let(:role)      { 1001 }
    let(:signature) { "asdfji2435;'!"}

    let(:type) { :get }
    let(:script_id) { 29 }
    let(:deploy_id) { 1 }
    let(:args) { [:trans_id, :trans_type] }
    let(:uri) { "https://rest.sandbox.netsuite.com/app/site/hosting/restlet.nl?script=#{script_id}&deploy=#{deploy_id}" }

    before(:each) do
      SuiteRest.reset!
      SuiteRest.configure do |config|
            config.account    = account
            config.email      = email
            config.role       = role
            config.signature  = signature
      end

      @get_svc = SuiteRest::RestService.new(
        :type       => type,
        :script_id  => script_id,
        :deploy_id  => deploy_id,
        :args       => args
        )
    end

    it "should retain the service definition arguments" do
      @get_svc.type.should eq(type)
      @get_svc.script_id.should eq(script_id)
      @get_svc.deploy_id.should eq(deploy_id)
      @get_svc.args.should eq(args)
    end

    it "should build a correct URI" do
      @get_svc.service_uri.should eq(uri)
    end

    context "in a prodution environment" do
      let(:uri) {"https://rest.netsuite.com/app/site/hosting/restlet.nl?script=#{script_id}&deploy=#{deploy_id}" }

      before do
        SuiteRest.configuration.sandbox = false
      end

      it "should return a production string" do
        @get_svc.service_uri.should eq(uri)
      end
    end
  end

end