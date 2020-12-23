require 'jbuilder'
require_relative 'log_formatter_base'

module RTALogger
  # json formatter which receive log_record and
  # returns it's data as json string
  class LogFormatterJson < LogFormatterBase
    def format(log_record)
      return '' unless log_record

      jb = Jbuilder.new do |json|
        json.occurred_at log_record.occurred_at.strftime('%F %H:%M:%S:%3N')
        json.app_name log_record.app_name
        json.topic_title log_record.topic_title
        json.context_id log_record.context_id
        json.severity log_record.severity
        json.message log_record.message.flatten.join(' ')
      end

      jb.target!
    end
  end
end
