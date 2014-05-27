require 'spec_helper'

describe SuiteRest::RestService do
  context "creating a standard RestService" do
    let(:account)   { 12345 }
    let(:email)     { "fake@gmail.com" }
    let(:role)      { 1001 }
    let(:signature) { "asdfji2435;'!"}

    let(:script_id) { 29 }
    let(:deploy_id) { 1 }
    let(:args_def) { [:trans_id, :trans_type] }
    let(:uri) { "https://rest.sandbox.netsuite.com/app/site/hosting/restlet.nl?script=#{script_id}&deploy=#{deploy_id}" }
    let(:uri_args) { "&transId=45334&transType=invoice" }
    let(:payload_args) do
      {
        'transId'   => 45334,
        'transType' => 'invoice'
      }.to_json
    end
    let(:call_args) do
      {
        :trans_id   => 45334,
        :trans_type => 'invoice'
      }
    end

    before(:each) do
      SuiteRest.reset!
      SuiteRest.configure do |config|
            config.account    = account
            config.email      = email
            config.role       = role
            config.signature  = signature
      end

      @get_svc = SuiteRest::RestService.new(
        :type           => :get,
        :script_id      => script_id,
        :deploy_id      => deploy_id,
        :args_def       => args_def
        )

      @put_svc = SuiteRest::RestService.new(
        :type           => :put,
        :script_id      => script_id,
        :deploy_id      => deploy_id,
        :args_def       => args_def
        )

      @delete_svc = SuiteRest::RestService.new(
        :type           => :delete,
        :script_id      => script_id,
        :deploy_id      => deploy_id,
        :args_def       => args_def
        )

      @post_svc = SuiteRest::RestService.new(
        :type           => :post,
        :script_id      => script_id,
        :deploy_id      => deploy_id,
        :args_def       => args_def
        )

      @parsed_uri = double(URI, 
        :host => "uri_host", :port => "uri_port", :request_uri => "uri_request_uri")
      @http = double(Net::HTTP, :use_ssl= => nil, :verify_mode= => nil, :request => double(:body => "\"Hello World\""))
      @http_get = double(Net::HTTP::Get)
      @http_post = double(Net::HTTP::Post)
      @http_put = double(Net::HTTP::Put)
    end

    it "should retain the service definition arguments" do
      @get_svc.type.should eq(:get)
      @get_svc.script_id.should eq(script_id)
      @get_svc.deploy_id.should eq(deploy_id)
      @get_svc.args_def.should eq(args_def)

      @put_svc.type.should eq(:put)
      @put_svc.script_id.should eq(script_id)
      @put_svc.deploy_id.should eq(deploy_id)
      @put_svc.args_def.should eq(args_def)

      @post_svc.type.should eq(:post)
      @post_svc.script_id.should eq(script_id)
      @post_svc.deploy_id.should eq(deploy_id)
      @post_svc.args_def.should eq(args_def)
    end

    it "should build a correct URI" do
      @get_svc.service_uri.should eq(uri)
    end

    it "should parse the URI string correctly" do
      URI.should_receive(:parse).with(uri).and_return(@parsed_uri)
      @get_svc.parsed_uri.should eq(@parsed_uri)
    end

    it "should parse the URI string with args correctly" do
      URI.should_receive(:parse).with(uri + URI.escape(uri_args)).and_return(@parsed_uri)
      @get_svc.parsed_uri(uri_args).should eq(@parsed_uri)
    end

    it "should create a Net::HTTP object" do
      Net::HTTP.should_receive(:new).with(@parsed_uri.host, @parsed_uri.port).and_return(@http)
      @http.should_receive(:use_ssl=).with(true)
      @http.should_receive(:verify_mode=).with(OpenSSL::SSL::VERIFY_NONE)

      @get_svc.http(@parsed_uri)
    end

    it "should create an arg string for the url" do
      @get_svc.urlify(call_args).should eq(uri_args)
    end

    it "should create a json payload" do
      @post_svc.payloadify(call_args).should eq(payload_args)
    end

    it "should call get for a get service" do
      @get_svc.should_receive(:get).with(call_args)
      @get_svc.call(call_args)
    end

    it "should call put for a put service" do
      @put_svc.should_receive(:put).with(call_args)
      @put_svc.call(call_args)
    end

    it "should call delete for a delete service" do
      @delete_svc.should_receive(:delete).with(call_args)
      @delete_svc.call(call_args)
    end

    it "should call post for a post service" do
      @post_svc.should_receive(:post).with(call_args)
      @post_svc.call(call_args)
    end

    it "should build and execute a get request" do
      URI.should_receive(:parse).with(uri + URI.escape(uri_args)).and_return(@parsed_uri)
      Net::HTTP.should_receive(:new).with(@parsed_uri.host, @parsed_uri.port).and_return(@http)
      Net::HTTP::Get.should_receive(:new).with(@parsed_uri.request_uri).and_return(@http_get)
      @http_get.should_receive(:add_field).with("Authorization", SuiteRest.configuration.auth_string)
      @http_get.should_receive(:add_field).with("Content-Type", "application/json")
      @http.should_receive(:request).with(@http_get)

      @get_svc.get(call_args)
    end

    it "should build and execute a put request" do
      URI.should(receive(:parse).with(uri).and_return(@parsed_uri))
      Net::HTTP.should_receive(:new).with(@parsed_uri.host, @parsed_uri.port).and_return(@http)
      Net::HTTP::Put.should_receive(:new).with(@parsed_uri.request_uri).and_return(@http_put)
      @http_put.should_receive(:add_field).with("Authorization", SuiteRest.configuration.auth_string)
      @http_put.should_receive(:add_field).with("Content-Type", "application/json")
      @http_put.should_receive(:body=).with(payload_args)
      @http.should_receive(:request).with(@http_put)

      @put_svc.post(call_args)
    end

    it "should build and execute a post request" do
      URI.should(receive(:parse).with(uri).and_return(@parsed_uri))
      Net::HTTP.should_receive(:new).with(@parsed_uri.host, @parsed_uri.port).and_return(@http)
      Net::HTTP::Post.should_receive(:new).with(@parsed_uri.request_uri).and_return(@http_post)
      @http_post.should_receive(:add_field).with("Authorization", SuiteRest.configuration.auth_string)
      @http_post.should_receive(:add_field).with("Content-Type", "application/json")
      @http_post.should_receive(:body=).with(payload_args)
      @http.should_receive(:request).with(@http_post)

      @post_svc.post(call_args)
    end

    it "should throw an error for a bad type" do
      @get_svc.type = :bad_type
      expect{ @get_svc.call }.to raise_error(RuntimeError, "Invalid Service Type bad_type, use :get, :put, :post, or :delete")
    end

    context "in a prodution environment" do
      let(:uri) {"https://rest.netsuite.com/app/site/hosting/restlet.nl?script=#{script_id}&deploy=#{deploy_id}" }

      before do
        SuiteRest.configuration.sandbox = false
      end

      it "should return a production uri string" do
        @get_svc.service_uri.should eq(uri)
      end

      # TODO: production section should have same tests as sandbox,
      # but withotu duping every test. shared examples?
    end

  end
end