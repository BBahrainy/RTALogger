# frozen_string_literal: true

require_relative 'log_topic'

module RTALogger
  # this module generates object instance
  module LogFactory
    def self.new_log_topic(log_manager, title, level = WARN, enable = true)
      LogTopic.new(log_manager, title, level, enable)
    end
  end
end
