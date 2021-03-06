require 'spec_helper'

describe SuiteRest do

  it "should respond to :configure" do
    should respond_to(:configure)
  end

  it "should respond to configuration" do
    should respond_to(:configuration)
  end

  it "should respond to reset!" do
    should respond_to(:reset!)
  end

  context "when testing varios configurations" do
    let(:account)   { 12345 }
    let(:email)     { "fake@gmail.com" }
    let(:role)      { 1001 }
    let(:signature) { "asdfji2435;'!"}
    let(:auth_string) {
          "NLAuth nlauth_account=" + account.to_s + \
          ", nlauth_email=" + email.to_s + \
          ", nlauth_signature=" + signature.to_s + \
          ", nlauth_role=" + role.to_s
        }

    before(:each) { SuiteRest.reset! }

    context "when creating a basic Sandbox config" do
      before do
        SuiteRest.configure do |config|
            config.account    = account
            config.email      = email
            config.role       = role
            config.signature  = signature
        end
      end

      it "should remember the base config settings" do
        SuiteRest.configuration.email.should eq(email)
        SuiteRest.configuration.account.should eq(account)
        SuiteRest.configuration.role.should eq(role)
        SuiteRest.configuration.signature.should eq(signature)
        SuiteRest.configuration.sandbox.should eq(true)
      end

      it "should return a proper auth string" do
        SuiteRest.configuration.auth_string.should eq(auth_string)
      end
    end

    context "when creating a basic production config" do
      before do
        SuiteRest.configure do |config|
            config.account    = account
            config.email      = email
            config.role       = role
            config.signature  = signature
            config.sandbox    = false
        end
      end

      it "should remember the base config settings" do
        SuiteRest.configuration.email.should eq(email)
        SuiteRest.configuration.account.should eq(account)
        SuiteRest.configuration.role.should eq(role)
        SuiteRest.configuration.signature.should eq(signature)
        SuiteRest.configuration.sandbox.should eq(false)
      end

      it "should return a proper auth string" do
        SuiteRest.configuration.auth_string.should eq(auth_string)
      end
    end
  end

end