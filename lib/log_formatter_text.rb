require_relative 'log_formatter_base'

module RTALogger
  # text formatter which receive log_record and
  # returns it's data as delimited text string
  class LogFormatterText < LogFormatterBase
    def format(log_record)
      return '' unless log_record

      result = log_record.occurred_at.strftime('%F %H:%M:%S:%3N')
      result << @delimiter << log_record.app_name
      result << @delimiter << log_record.topic_title
      result << @delimiter << log_record.context_id
      result << @delimiter << log_record.severity
      result << @delimiter << log_record.message.join(' ').gsub(delimiter, '$<$')

      result
    end
  end
end
