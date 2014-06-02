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

      @http = double(Net::HTTP, :use_ssl= => nil, :verify_mode= => nil, :request => double(Net::HTTPOK, :code => "200", :body => "body"))
      @http_get = double(Net::HTTP::Get, :add_field => nil)
      @http_post = double(Net::HTTP::Post, :add_field => nil)
      @http_put = double(Net::HTTP::Put, :add_field => nil)
      @http_delete = double(Net::HTTP::Delete, :add_field => nil)
    end

    it "should retain each service definition arguments" do
      @get_svc.type.should eq(:get)
      @get_svc.script_id.should eq(script_id)
      @get_svc.deploy_id.should eq(deploy_id)
      @get_svc.args_def.should eq(args_def)

      @put_svc.type.should eq(:put)
      @put_svc.script_id.should eq(script_id)
      @put_svc.deploy_id.should eq(deploy_id)
      @put_svc.args_def.should eq(args_def)

      @delete_svc.type.should eq(:delete)
      @delete_svc.script_id.should eq(script_id)
      @delete_svc.deploy_id.should eq(deploy_id)
      @delete_svc.args_def.should eq(args_def)

      @post_svc.type.should eq(:post)
      @post_svc.script_id.should eq(script_id)
      @post_svc.deploy_id.should eq(deploy_id)
      @post_svc.args_def.should eq(args_def)
    end

    context "when args_def is not defined" do
      let(:args_def) { nil }

      it "should default to empty array args_def" do
        @get_svc.args_def.should eq([])
        @put_svc.args_def.should eq([])
        @delete_svc.args_def.should eq([])
        @post_svc.args_def.should eq([])
      end
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
      SuiteRest::RestService.should_receive(:http).and_return(@http)
      Net::HTTP::Get.should_receive(:new).and_return(@http_get)
      @http.should_receive(:request).with(@http_get)
      SuiteRest::RestService.should_receive(:parse_body).with("body")

      @get_svc.get(call_args)
    end

    it "should build and execute a put request" do
      SuiteRest::RestService.should_receive(:http).and_return(@http)
      Net::HTTP::Put.should_receive(:new).and_return(@http_put)
      @http_put.should_receive(:body=).with(payload_args)
      @http.should_receive(:request).with(@http_put)
      SuiteRest::RestService.should_receive(:parse_body).with("body")

       @put_svc.put(call_args)
    end

    it "should build and execute a delete request" do
      SuiteRest::RestService.should_receive(:http).and_return(@http)
      Net::HTTP::Delete.should_receive(:new).and_return(@http_delete)
      @http.should_receive(:request).with(@http_delete)

      @delete_svc.delete(call_args).should eq(true)
    end

    it "should build and execute a post request" do
      SuiteRest::RestService.should_receive(:http).and_return(@http)
      Net::HTTP::Post.should_receive(:new).and_return(@http_post)
      @http_post.should_receive(:body=).with(payload_args)
      @http.should_receive(:request).with(@http_post)
      SuiteRest::RestService.should_receive(:parse_body).with("body")

      @post_svc.post(call_args)
    end

    it "should throw an error for a bad type" do
      @get_svc.type = :bad_type
      expect{ @get_svc.call }.to raise_error(RuntimeError)
    end
  end
end