require 'fitting/report/console'

module Fitting
  class Report
    def initialize(tsts, prfixes, lgger)
      @logger = lgger
      @tests = tsts
      @prefixes = prfixes
    end

    def prefixes
      @prefixes
    end

    def tests
      @tests
    end

    def logger
      @logger
    end

    def console
      logger.info("program started")
      prefixes.join(tests)
      logger.info("prefixes joined")

      prefixes.to_a.map do |prefix|
        prefix.actions.join(prefix.tests) unless prefix.skip?
      end
      logger.info("actions joined")

      prefixes.to_a.map do |prefix|
        prefix.actions.to_a.map do |action|
          action.responses.join(action.tests)
        end unless prefix.skip?
      end
      logger.info("responses joined")

      prefixes.to_a.map do |prefix|
        prefix.actions.to_a.map do |action|
          action.responses.to_a.map do |response|
            response.combinations.join(response.tests)
          end
        end unless prefix.skip?
      end
      logger.info("combinations joined")

      report = JSON.pretty_generate(
        {
          tests_without_prefixes: tests.without_prefixes,
          prefixes_details: prefixes.to_a.map { |p| p.details }
        }
      )
      logger.info("report ready")

      destination = 'fitting'
      FileUtils.mkdir_p(destination)
      FileUtils.rm_r Dir.glob("#{destination}/*"), :force => true
      File.open('fitting/report.json', 'w') { |file| file.write(report) }
      logger.info("report saved")

      logger.info("start save html report")
      gem_path = $LOAD_PATH.find { |i| i.include?('fitting') }
      source_path = "#{gem_path}/templates/bomboniere/dist"
      FileUtils.copy_entry source_path, destination
      logger.info("copied html template for report")

      json_schemas = {}
      combinations = {}
      prefixes.to_a.map do |prefix|
        prefix.actions.to_a.map do |action|
          action.responses.to_a.map do |response|
            json_schemas.merge!(response.id => response.body)
            response.combinations.to_a.map do |combination|
              combinations.merge!(combination.id => combination.json_schema)
            end
          end
        end unless prefix.skip?
      end
      File.open('fitting/json_schemas.json', 'w') { |file| file.write(JSON.pretty_generate(json_schemas)) }
      logger.info("json-schemas savied")
      File.open('fitting/combinations.json', 'w') { |file| file.write(JSON.pretty_generate(combinations)) }
      logger.info("combinations savied")
      File.open('fitting/tests.json', 'w') { |file| file.write(JSON.pretty_generate(tests.to_h)) }
      logger.info("tests savied")

      js_path =  Dir["#{destination}/js/*"].find { |f| f[0..14] == 'fitting/js/app.' and f[-3..-1] == '.js' }
      js_file =  File.read(js_path)
      new_js_file = js_file.gsub("{stub:\"prefixes report\"}", report)
      new_js_file = new_js_file.gsub("{stub:\"for action page\"}", report)
      new_js_file = new_js_file.gsub("{stub:\"json-schemas\"}", JSON.pretty_generate(json_schemas))
      new_js_file = new_js_file.gsub("{stub:\"combinations\"}", JSON.pretty_generate(combinations))
      new_js_file = new_js_file.gsub("{stub:\"tests\"}", JSON.pretty_generate(tests.to_h))
      File.open(js_path, 'w') { |file| file.write(new_js_file) }
      logger.info("data savied in html report")

      logger.info("push result in console")
      console = Fitting::Report::Console.new(
        tests.without_prefixes,
        prefixes.to_a.map { |p| p.details }
      )
    end
  end
end