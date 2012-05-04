# $LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'profiler'
require 'profiler/data'
require 'profiler/profile'
require 'profiler/talker'
require 'scm/scm'
require 'rspec'
require 'rspec/autorun'
require 'construct'
require 'shellwords'
require 'stringio'

RSpec.configure do |config|
  config.include Construct::Helpers

  config.mock_with :rspec
  
  $stderr = StringIO.new
end

require 'simplecov'
SimpleCov.start