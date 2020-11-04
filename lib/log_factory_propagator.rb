# frozen_string_literal: true

require_relative 'log_propagator'

module RTALogger
  # this module generates object instance
  module LogFactory
    def self.new_log_propagator
      LogPropagator.new
    end
  end
end
