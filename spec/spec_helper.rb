begin
  if ENV["TRAVIS"] && RUBY_VERSION.to_f >= 1.9
    require "coveralls"
    Coveralls.wear! { add_filter "/spec/" }
  else
    require "simplecov"
    SimpleCov.start { add_filter "/spec/" }
  end
rescue
  #Running without coverage reports.
end

require 'puppetlabs_spec_helper/module_spec_helper'
