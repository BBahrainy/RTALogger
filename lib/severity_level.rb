module RTALogger
  # Logging severity.
  module SeverityLevel
    # all information that helps us to trace the processing of an incoming request through our application
    TRACE = 0
    # Low-level information, mostly for developers.
    DEBUG = 1
    # Generic (useful) information about system operation.
    INFO = 2
    # A warning.
    WARN = 3
    # A handleable error condition.
    ERROR = 4
    # An un-handleable error that results in a program crash.
    FATAL = 5
    # An unknown message that should always be logged.
    UNKNOWN = 6


    def parse_severity_level_to_i(severity_level)
      return severity_level if severity_level.is_a? ::Integer

      case severity_level.upcase
      when 'TRACE'
        0
      when 'DEBUG'
        1
      when 'INFO'
        2
      when 'INFORMATIONّٔ'
        2
      when 'WARN'
        3
      when 'WARNING'
        5
      when 'ERROR'
        4
      when 'FATAL'
        5
      when 'UNKNOWN'
        6
      else
        2
      end
  end

  def parse_severity_level_to_s(severity_level)
    return severity_level if severity_level.is_a? ::String

    case severity_level.to_i
    when 0
      'TRACE'
    when 1
      'DEBUG'
    when 2
      'INFO'
    when 3
      'WARN'
    when 4
      'ERROR'
    when 5
      'FATAL'
    when 6
      'UNKNOWN'
    end
  end
end
end
