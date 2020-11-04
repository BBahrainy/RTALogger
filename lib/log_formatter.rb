module RTALogger
  # Log Formatter base class
  class LogFormatter
    def format(log_record)
      log_record.to_s
    end
  end
end
