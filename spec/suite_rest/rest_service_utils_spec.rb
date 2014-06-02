require 'spec_helper'

describe SuiteRest::RestServiceUtils do

  context "when testing service_uri" do
    context "when given valid arguments and sandbox" do
      let(:script_id){ Random.rand(1..1000) }
      let(:deploy_id){ Random.rand(1..1000) }
      let(:is_sandbox){ true }

      it "should return correct URI" do
        uri = SuiteRest::RestServiceUtils.service_uri(script_id, deploy_id, is_sandbox)
        uri.should eq("https://rest.sandbox.netsuite.com/app/site/hosting/restlet.nl?script=#{script_id}&deploy=#{deploy_id}")
      end
    end

    context "when given valid arguments and production" do
      let(:script_id){ Random.rand(1..1000) }
      let(:deploy_id){ Random.rand(1..1000) }
      let(:is_sandbox){ false }

      it "should return correct URI" do
        uri = SuiteRest::RestServiceUtils.service_uri(script_id, deploy_id, is_sandbox)
        uri.should eq("https://rest.netsuite.com/app/site/hosting/restlet.nl?script=#{script_id}&deploy=#{deploy_id}")
      end
    end
  end

  context "when testing parsed_uri" do
    context "when given valid input and arguments" do
      let(:script_id){ Random.rand(1..1000) }
      let(:deploy_id){ Random.rand(1..1000) }
      let(:is_sandbox){ false }
      let(:args) { "&transId=45334&transType=invoice"}

      it "should properly parse the URI" do
        SuiteRest::RestServiceUtils.should_receive(:service_uri).and_return("uri")
        URI.should_receive(:escape).with(args).and_return("escape")
        URI.should_receive(:parse).with("uriescape")

        SuiteRest::RestServiceUtils.parsed_uri(script_id, deploy_id, is_sandbox, args)
      end
    end

    context "when given valid input and no arguments" do
      let(:script_id){ Random.rand(1..1000) }
      let(:deploy_id){ Random.rand(1..1000) }
      let(:is_sandbox){ false }

      it "should properly parse the URI" do
        SuiteRest::RestServiceUtils.should_receive(:service_uri).and_return("uri")
        URI.should_receive(:escape).with("").and_return("")
        URI.should_receive(:parse).with("uri")

        SuiteRest::RestServiceUtils.parsed_uri(script_id, deploy_id, is_sandbox)
      end
    end

    context "when testing http" do
      before(:each) do
        @parsed_uri = double(URI, :host => "host", :port => "port")
        @http = double(Net::HTTP)
      end

      context "when calling http with a parsed uri" do
        it "should process and return an http instance" do
          Net::HTTP.should_receive(:new).with("host", "port").and_return(@http)
          @http.should_receive(:use_ssl=).with(true)
          @http.should_receive(:verify_mode=).with(OpenSSL::SSL::VERIFY_NONE)

          SuiteRest::RestServiceUtils.http(@parsed_uri).should eq(@http)
        end
      end
    end

    context "when testing camel_case_lower" do
        it { SuiteRest::RestServiceUtils.camel_case_lower("trans_id").should eq("transId") }
        it { SuiteRest::RestServiceUtils.camel_case_lower("deploy_id").should eq("deployId") }
        it { SuiteRest::RestServiceUtils.camel_case_lower("is_new_customer").should eq("isNewCustomer") }
        it { SuiteRest::RestServiceUtils.camel_case_lower("a_b_c").should eq("aBC") }
        it { SuiteRest::RestServiceUtils.camel_case_lower("number_1_fan").should eq("number1Fan") }
    end

    context "when testing add_request_fields" do
      before(:each) do
        @request = double()
      end

      context "when its called with a request and auth string" do

        it "should add fields to the request correctly" do
          @request.should_receive(:add_field).with("Authorization", "auth_string")
          @request.should_receive(:add_field).with("Content-Type", "application/json")

          SuiteRest::RestServiceUtils.add_request_fields(@request, "auth_string")
        end
      end
    end

    context "when testing urlify" do
      let(:args_def) { [:trans_id, :trans_type] }
      let(:args) do
        {
          :trans_id => 45334,
          :trans_type => 'invoice'
        }
      end

      it "should return a correct url arg string" do
        SuiteRest::RestServiceUtils.urlify(args, args_def).should eq("&transId=45334&transType=invoice")
      end
    end

    context "when testing payloadify" do
      let(:args_def) { [:trans_id, :trans_type] }
      let(:args) do
        {
          :trans_id => 45334,
          :trans_type => 'invoice'
        }
      end

      it "should return a correct JSON payload" do
        SuiteRest::RestServiceUtils.payloadify(args, args_def).should eq("{\"transId\":45334,\"transType\":\"invoice\"}")
      end
    end

    context "when testing check_response" do
      before(:each) do
        @response = double()
      end

      it "should return the response if the message is HTTP_OK" do
        @response.should_receive(:code).and_return("200")

        response_return = SuiteRest::RestServiceUtils.check_response(@response)
        response_return.should eq(@response)
      end

      it "should raise an error if the message is not HTTPOK" do
        @response.should_receive(:code).twice.and_return("404")
        @response.should_receive(:msg).and_return("Not Found")

        expect{ SuiteRest::RestServiceUtils.check_response(@response) }.to raise_error(RuntimeError)
      end
    end

    context "when testing parse_body" do
      it { SuiteRest::RestServiceUtils.parse_body("\"false\"").should eq(false) }
      it { SuiteRest::RestServiceUtils.parse_body("\"true\"").should eq(true) }
      it { SuiteRest::RestServiceUtils.parse_body("\"116\"").should eq(116) }
      it { SuiteRest::RestServiceUtils.parse_body("\"116.14\"").should eq(116.14) }
      it { SuiteRest::RestServiceUtils.parse_body("\"null\"").should eq(nil) }
      it { SuiteRest::RestServiceUtils.parse_body("\"One string return\"").should eq("One string return") }
      it { SuiteRest::RestServiceUtils.parse_body("\"1 string\"").should eq("1 string") }
      it { SuiteRest::RestServiceUtils.parse_body("\"true string\"").should eq("true string") }
      it { SuiteRest::RestServiceUtils.parse_body("\"null string\"").should eq("null string") }
      it { SuiteRest::RestServiceUtils.parse_body("\"False\"").should eq("False") }
      it { SuiteRest::RestServiceUtils.parse_body("\"1.10\"").should eq("1.10") }

      it "should parse a JSON return correctly" do
        rest_return = "{\"a\":5,\"b_key\":\"A string\",\"array_key\":[1,2,3,4,5]}"
        correct_parse = {"a"=>5, "b_key"=>"A string", "array_key"=>[1, 2, 3, 4, 5]}
        SuiteRest::RestServiceUtils.parse_body(rest_return).should eq(correct_parse)
      end
    end
  end


end