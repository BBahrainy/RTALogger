# frozen_string_literal: true
require 'logger'

module RTALogger
  # this module generates object instance
  module LogFactory
    def self.new_file_logger(file_path = 'log.txt', period = 'daily', shift_size = 1048576)
      @ruby_logger = Logger.new(file_path, period, shift_size)
      @ruby_logger.level = Logger::Severity::DEBUG
      @ruby_logger.formatter = proc do |severity, datetime, progname, msg|
        "#{msg}\n"
      end
      @ruby_logger
    end
  end
end
