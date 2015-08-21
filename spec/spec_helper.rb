# Supress Warnings
warn_level = $VERBOSE
$VERBOSE = nil

if ENV.has_key?('SIMPLECOV')
  require 'simplecov'
  require 'simplecov-rcov'

  SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
  SimpleCov.start do
    add_filter '/spec/'
  end
else
  require 'coveralls'
  Coveralls.wear!
end

require 'json2ruby'