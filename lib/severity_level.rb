module RTALogger
  # Logging severity.
  module SeverityLevel
    # Low-level information, mostly for developers.
    DEBUG = 0
    # Generic (useful) information about system operation.
    INFO = 1
    # A warning.
    WARN = 2
    # A handleable error condition.
    ERROR = 3
    # An un-handleable error that results in a program crash.
    FATAL = 4
    # An unknown message that should always be logged.
    UNKNOWN = 5


    def parse_severity_level_to_i(severity_level)
      return severity_level if severity_level.is_a? ::Integer

      case severity_level.upcase
      when 'DEBUG'
        0
      when 'INFO'
        1
      when 'INFORMATIONّٔ'
        1
      when 'WARN'
        2
      when 'WARNING'
        2
      when 'ERROR'
        3
      when 'FATAL'
        4
      when 'UNKNOWN'
        5
      end
    end

    def parse_severity_level_to_s(severity_level)
      return severity_level if severity_level.is_a? ::String

      case severity_level.to_i
      when 0
        'DEBUG'
      when 1
        'INFO'
      when 2
        'WARN'
      when 3
        'ERROR'
      when 4
        'FATAL'
      when 5
        'UNKNOWN'
      end
    end
  end
end
