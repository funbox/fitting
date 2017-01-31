module Fitting
  class Report
    def initialize(tests)
      documented = {}
      not_documented = {}
      statistics = {
        'responses' => {
          'valid' => 0,
          'invalid' => 0,
          'all' => 0
        }
      }
      tests.map do |location, test|
        request = MultiJson.load(test['request'])
        response = MultiJson.load(test['response'])
        if request['schema'].nil?
          not_documented["#{request['method']} #{request['path']}"] = {}
        else
          code = response['status'].to_s
          valid = response['valid']
          status = "#{request['schema']['method']} #{request['schema']['path']}"
          local_tests = {}
          if documented[status]
            local_tests = documented[status]['responses'][code]['tests']
          end
          unless valid
            fully_validates = response['schemas'].map do |schema|
              schema['fully_validate']
            end

            local_tests[location] = {
              'reality' => {
                'body' => response['body']
              },
              'fully_validates' => fully_validates.first
            }
          end

          valid = false if local_tests.present?

          documented[status] = {
            'responses' => {
              code => {
                'valid' => valid,
                'tests' => local_tests
              }
            }
          }
        end
      end

      documented.map do |request|
        request.last['responses'].map do |response|
          if response.last['valid']
            statistics['responses']['valid'] += 1
          else
            statistics['responses']['invalid'] += 1
          end
          statistics['responses']['all'] += 1
        end
      end

      @json = {
        'statistics' => statistics,
        'requests' => {
          'documented' => documented,
          'not_documented' => not_documented
        }
      }
    end

    def self.blank
      {}
    end

    def to_hash
      @json
    end
  end
end
