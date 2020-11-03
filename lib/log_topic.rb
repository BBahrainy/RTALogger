# topic

require_relative './log_severity'
require_relative 'factory/origin/log_factory_record'

module RTALogger
  # the main class to logging data
  class LogTopic
    include LogSeverity
    include RTALogger::LogFactory

    def initialize(log_manager, topic_title, log_level = WARN)
      #  Logger logger = Logger.new(Logger::DEBUG)
      @enable = true
      @log_manager = log_manager
      @topic_title = topic_title.to_s.dup
      @log_level = log_level
    end

    attr_accessor :enable
    attr_reader :log_manager
    attr_reader :topic_title
    attr_accessor :log_level

    def debug(context_id, *message)
      add(context_id, DEBUG, message) if @log_level.to_i <= DEBUG.to_i
    end

    def info(context_id, *message)
      add(context_id, INFO, message) if @log_level.to_i <= INFO.to_i
    end

    def warning(context_id, *message)
      add(context_id, WARN, message) if @log_level.to_i <= WARN.to_i
    end

    def error(context_id, *message)
      add(context_id, ERROR, message) if @log_level.to_i <= ERROR.to_i
    end

    def fatal(context_id, *message)
      add(context_id, FATAL, message) if @log_level.to_i <= FATAL.to_i
    end

    def unknown(context_id, *message)
      add(context_id, UNKNOWN, message) if @log_level.to_i <= UNKNOWN.to_i
    end

    private

    def add(context_id, severity, *message)
      return unless @enable
      log_record = LogFactory.new_log_record(self, context_id, severity, message)
      @log_manager.add_log(log_record)
    end
  end
end
