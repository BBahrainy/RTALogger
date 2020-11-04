# frozen_string_literal: true

require_relative 'log_topic'

module RTALogger
  # this module generates object instance
  module LogFactory
    def self.new_log_topic(log_manager, topic_title, level = WARN)
      LogTopic.new(log_manager, topic_title, level)
    end
  end
end
