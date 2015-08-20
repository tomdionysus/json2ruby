files = [
  'version',
  'primitive',
  'attribute',
  'collection',
  'entity',
  'cli',
].each { |file| require "#{File.dirname(__FILE__)}/json2ruby/#{file}" }
