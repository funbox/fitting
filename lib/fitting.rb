require 'fitting/version'
require 'fitting/documentation'
require 'fitting/configuration'

require 'yaml'
require 'fitting/storage/yaml_file'
require 'fitting/report/response/macro'

module Fitting
  class << self
    def configure
      yield configuration
    end

    def configuration
      @configuration ||= Configuration.new
    end
  end
end

module RSpec
  module Core
    # Provides the main entry point to run a suite of RSpec examples.
    class Runner
      alias origin_run_specs run_specs

      def run_specs(example_groups)
        Fitting::Storage::YamlFile.craft

        origin_run_specs(example_groups)

        tests = Fitting::Storage::YamlFile.load
        Fitting::Storage::YamlFile.destroy

        report = Fitting::Report::Response::Macro.new(tests).to_hash
        File.open('report_response_macro.yaml', 'w') do |file|
          file.write(YAML.dump(report))
        end
      end
    end
  end
end
