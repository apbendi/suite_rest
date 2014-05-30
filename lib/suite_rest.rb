require 'uri'
require 'net/http'
require 'json'

require "suite_rest/version"
require "suite_rest/rest_service_utils"
require "suite_rest/rest_service"

module SuiteRest
  class << self
    attr_accessor :configuration
  end
  
  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  def self.reset!
    self.configuration = Configuration.new
  end

  class Configuration
    attr_accessor :account, :sandbox, :email, :role, :signature

    def initialize
      @sandbox = true # safe default
    end

    def auth_string
      "NLAuth nlauth_account=" + @account.to_s + \
          ", nlauth_email=" + @email.to_s + \
          ", nlauth_signature=" + @signature.to_s + \
          ", nlauth_role=" + @role.to_s
    end
  end
end
