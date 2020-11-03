require_relative '../../log_formatter_text'
require_relative '../../log_formatter_json'

module RTALogger
  module LogFactory
    def self.log_formatter_default
      # RTALogger::LogFormatterJSON.new
      RTALogger::LogFormatterText.new
    end
  end
end
