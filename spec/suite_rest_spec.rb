require 'spec_helper'

describe SuiteRest do

  it "should respond to :configure" do
    should respond_to(:configure)
  end

  it "should respond to configuration" do
    should respond_to(:configuration)
  end

  context "when executing a proper configuration block" do
    before do
      SuiteRest.configure do |config|
        config.account = 12345
        config.email = "fake@gmail.com"
        config.role = 1001
        config.signature = "asdfjkl;"
        config.sandbox = true
      end
    end

    it "should remember the base config settings" do
      SuiteRest.configuration.email.should eq("fake@gmail.com")
      SuiteRest.configuration.account.should eq(12345)
      SuiteRest.configuration.role.should eq(1001)
      SuiteRest.configuration.signature.should eq("asdfjkl;")
      SuiteRest.configuration.sandbox.should eq(true)
    end
  end

end