require 'simplecov'
require 'simplecov-rcov'

SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
SimpleCov.start do
  add_filter '/spec/'
end

require 'coveralls'
Coveralls.wear!

require 'json2ruby'