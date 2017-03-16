require 'fitting/documentation/response/routes'
require 'fitting/documentation/route'

module Fitting
  class Statistics
    def initialize(documentation, white_list, all_responses)
      @routes = Fitting::Documentation::Response::Routes.new(documentation, white_list)
      @black_route = Fitting::Documentation::Route.new(all_responses, @routes.black)
      @white_route = Fitting::Documentation::Route.new(all_responses, @routes.white)
    end

    def not_coverage?
      @white_route.not_coverage.present?
    end

    def to_s
      if @routes.black.any?
        [
          ['[Black list]', @black_route.statistics].join("\n"),
          ['[White list]', @white_route.statistics_with_conformity_lists].join("\n"),
          ""
        ].join("\n\n")
      else
        [@white_route.statistics_with_conformity_lists, "\n\n"].join
      end
    end
  end
end