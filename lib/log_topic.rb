require_relative 'severity_level'
require_relative 'log_factory_record'
require 'jbuilder'

module RTALogger
  # the main class to logging data as topic
  class LogTopic
    include SeverityLevel
    include RTALogger::LogFactory

    def initialize(log_manager, title, severity_level = WARN, enable = true)
      #  Logger logger = Logger.new(Logger::DEBUG)
      @enable = enable
      @log_manager = log_manager
      @title = title.to_s.dup
      @severity_level = severity_level
    end

    attr_accessor :enable
    attr_reader :log_manager
    attr_reader :title
    attr_accessor :severity_level

    def debug(context_id, *message)
      add(context_id, DEBUG, message) if @severity_level.to_i <= DEBUG.to_i
    end

    def info(context_id, *message)
      add(context_id, INFO, message) if @severity_level.to_i <= INFO.to_i
    end

    def warning(context_id, *message)
      add(context_id, WARN, message) if @severity_level.to_i <= WARN.to_i
    end

    def error(context_id, *message)
      add(context_id, ERROR, message) if @severity_level.to_i <= ERROR.to_i
    end

    def fatal(context_id, *message)
      add(context_id, FATAL, message) if @severity_level.to_i <= FATAL.to_i
    end

    def unknown(context_id, *message)
      add(context_id, UNKNOWN, message) if @severity_level.to_i <= UNKNOWN.to_i
    end

    def to_builder
      jb = Jbuilder.new do |json|
        json.title title
        json.severity_level parse_severity_level_to_s(severity_level)
        json.enable enable
      end

      jb
    end
    private

    def add(context_id, severity, *message)
      return unless @enable
      log_record = LogFactory.new_log_record(self, context_id, severity, message)
      @log_manager.add_log(log_record)
    end
  end
end
