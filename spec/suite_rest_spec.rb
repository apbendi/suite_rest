require 'spec_helper'

describe SuiteRest do

  it "should responde to :configure" do
    should respond_to(:configure)
  end

end