require 'spec_helper'
require 'logger'

require 'fitting/report'
require 'fitting/report/prefixes'
require 'fitting/report/tests'

RSpec.describe Fitting::Report do
  let(:test) { Fitting::Report::Tests.new_from_config('fitting_tests/*.json') }
  let(:prefixes) { Fitting::Report::Prefixes.new('spec/fixtures/console/.fitting.yml') }
  let(:logger) { Logger.new('logfile.log') }

  subject { described_class.new(test, prefixes, logger) }

  describe '#console' do
    it do
      expect { subject.console }.not_to raise_exception
    end
  end
end
