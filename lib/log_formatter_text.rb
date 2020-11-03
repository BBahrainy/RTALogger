require_relative 'log_formatter'

module RTALogger
  class LogFormatterText < LogFormatter
    def format(log_record)
      return '' unless log_record

      result = log_record.occurred_at.strftime("%F %H:%M:%S:%3N")
      result << '|' << log_record.app_name
      result << '|' << log_record.topic_title
      result << '|' << log_record.context_id
      result << '|' << log_record.severity
      result << '|' << log_record.message.join(' ').gsub('|' , '$<$')

      result
    end
  end
end
