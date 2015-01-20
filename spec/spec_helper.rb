require 'puppetlabs_spec_helper/module_spec_helper'

if ENV["TRAVIS"]
  require "coveralls"
  Coveralls.wear! { add_filter "/spec/" }
end
