module RTALogger
  class LogTopicWrapper
    def initialize(context_id, topic, level = 0)
      @context_id = context_id
      @topic = topic
      level = level - 1
      level = 0 if level.negative?
      level = 5 if level > 5
      self.level = level
    end

    attr_accessor :progname
    attr_accessor :context_id

    # Logging severity.
    module Severity
      # Low-level information, mostly for developers.
      DEBUG = 0
      # Generic (useful) information about system operation.
      INFO = 1
      # A warning.
      WARN = 2
      # A handleable error condition.
      ERROR = 3
      # An unhandleable error that results in a program crash.
      FATAL = 4
      # An unknown message that should always be logged.
      UNKNOWN = 5
    end
    include Severity

    # Logging severity threshold (e.g. <tt>Logger::INFO</tt>).
    attr_reader :level

    # Set logging severity threshold.
    #
    # +severity+:: The Severity of the log message.
    def level=(severity)
      if severity.is_a?(Integer)
        severity = 0 if severity.negative?
        severity = 5 if severity > 5
        @level = severity
      else
        case severity.to_s.downcase
        when 'debug'
          @level = DEBUG
        when 'info'
          @level = INFO
        when 'warn'
          @level = WARN
        when 'error'
          @level = ERROR
        when 'fatal'
          @level = FATAL
        when 'unknown'
          @level = UNKNOWN
        else
          raise ArgumentError, "invalid log level: #{severity}"
        end
      end
    end

    # Returns +true+ iff the current severity level allows for the printing of
    # +DEBUG+ messages.
    def debug?;
      @level <= DEBUG;
    end

    # Returns +true+ iff the current severity level allows for the printing of
    # +INFO+ messages.
    def info?;
      @level <= INFO;
    end

    # Returns +true+ iff the current severity level allows for the printing of
    # +WARN+ messages.
    def warn?;
      @level <= WARN;
    end

    # Returns +true+ iff the current severity level allows for the printing of
    # +ERROR+ messages.
    def error?;
      @level <= ERROR;
    end

    # Returns +true+ iff the current severity level allows for the printing of
    # +FATAL+ messages.
    def fatal?;
      @level <= FATAL;
    end

    def add(severity, message = nil, progname = nil)
      severity ||= UNKNOWN

      if progname.nil?
        progname = @progname
      end
      if message.nil?
        if block_given?
          message = yield
        else
          message = progname
          progname = @progname
        end
      end

      rta_logger_topic_log(severity, message)

      true
    end

    alias log add

    def debug(progname = nil, &block)
      add(DEBUG, nil, progname, &block)
    end

    def info(progname = nil, &block)
      add(INFO, nil, progname, &block)
    end

    def warn(progname = nil, &block)
      add(WARN, nil, progname, &block)
    end

    def error(progname = nil, &block)
      add(ERROR, nil, progname, &block)
    end

    def fatal(progname = nil, &block)
      add(FATAL, nil, progname, &block)
    end

    def unknown(progname = nil, &block)
      add(UNKNOWN, nil, progname, &block)
    end

    private

    def rta_logger_topic_log(severity, message)
      return if @topic.nil?

      case severity
      when DEBUG
        @topic.debug(@context_id, message)
      when INFO
        @topic.info(@context_id, message)
      when WARN
        @topic.warning(@context_id, message)
      when ERROR
        @topic.error(@context_id, message)
      when FATAL
        @topic.fatal(@context_id, message)
      when UNKNOWN
        @topic.unknown(@context_id, message)
      end
    end
  end
end
