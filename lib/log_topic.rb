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

    def trace(context_id, *message)
      add(context_id, TRACE, message) if trace?
    end

    def debug(context_id, *message)
      add(context_id, DEBUG, message) if debug?
    end

    def info(context_id, *message)
      add(context_id, INFO, message) if info?
    end

    def warning(context_id, *message)
      add(context_id, WARN, message) if warn?
    end

    def error(context_id, *message)
      add(context_id, ERROR, message) if error?
    end

    def fatal(context_id, *message)
      add(context_id, FATAL, message) if fatal?
    end

    def unknown(context_id, *message)
      add(context_id, UNKNOWN, message) if unknown?
    end

    def trace?; @severity_level.to_i <= TRACE.to_i; end

    def debug?; @severity_level.to_i <= DEBUG.to_i; end

    def info?; @severity_level.to_i <= INFO.to_i; end

    def warn?; @severity_level.to_i <= WARN.to_i; end

    def error?; @severity_level.to_i <= ERROR.to_i; end

    def fatal?; @severity_level.to_i <= FATAL.to_i; end

    def unknown?; @severity_level.to_i <= UNKNOWN.to_i; end

    def to_builder
      jb = Jbuilder.new do |json|
        json.title title
        json.severity_level parse_severity_level_to_s(severity_level)
        json.enable enable
      end

      jb
    end

    def apply_run_time_config(config_json)
      return unless config_json
      @enable = config_json['enable'] unless config_json['enable'].nil?
      @severity_level = parse_severity_level_to_i(config_json['severity_level']) unless config_json['severity_level'].nil?
    end

    private

    def add(context_id, severity, *message)
      return unless @enable
      log_record = LogFactory.new_log_record(self, context_id, severity, message)
      @log_manager.add_log(log_record)
    end
  end
end
