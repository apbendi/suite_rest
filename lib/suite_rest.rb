require "suite_rest/version"

module SuiteRest
  class << self
    attr_accessor :configuration
  end
  
  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration
    attr_accessor :account, :sandbox, :email, :role, :signature

    def initialize
      @sandbox = true # safe default
    end
  end
end
