# frozen_string_literal: true

require_relative '../../log_record'

module RTALogger
  # this module generates object instance
  module LogFactory
    def self.new_log_record(log_topic, context_id, severity, *message)
      LogRecord.new(log_topic, context_id, severity, message)
    end
  end
end
