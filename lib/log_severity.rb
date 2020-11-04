module RTALogger
  # Logging severity.
  module LogSeverity
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
  end
end
