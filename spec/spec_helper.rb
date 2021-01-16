require 'rspec'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'simplecov'
SimpleCov.start

require 'json-schema'
require 'byebug'
require 'fitting'

FileUtils.rm_r Dir.glob("log/*"), :force => true
