require_relative 'log_formatter_text'
require_relative 'log_formatter_json'

module RTALogger
  # Log factory to get new instance of log formatter
  module LogFactory
    def self.log_formatter_default
      RTALogger::LogFormatterJSON.new
      # RTALogger::LogFormatterText.new
    end

    def self.log_formatter_json
      RTALogger::LogFormatterJSON.new
    end

    def self.log_formatter_text
      RTALogger::LogFormatterText.new
    end
  end
end
