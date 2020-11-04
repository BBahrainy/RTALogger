# frozen_string_literal: true

require_relative 'log_manager'

module RTALogger
  # this module generates object instance
  module LogFactory
    def self.log_manager_instance
      RTALogger::LogManager.instance
    end
  end
end
