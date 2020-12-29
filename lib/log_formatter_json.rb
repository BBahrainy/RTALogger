require 'jbuilder'
require_relative 'log_formatter_base'
require_relative 'string'

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
        json.severity parse_severity_level_to_s(log_record.severity)
        json.message log_record.message.flatten.join(' ')
      end

      result = jb.target!
      result = colorize_json(result) if @colorize

      return result
    end

    protected

    def colorize_json(json_text)
      json_text.gsub(/"severity":"TRACE"/i, '"severity":"TRACE"'.trace_color)
               .gsub(/"severity":"DEBUG"/i, '"severity":"DEBUG"'.debug_color)
               .gsub(/"severity":"WARN"/i, '"severity":"WARN"'.warning_color)
               .gsub(/"severity":"ERROR"/i, '"severity":"ERROR"'.error_color)
               .gsub(/"severity":"FATAL"/i, '"severity":"FATAL"'.fatal_color)
               .gsub(/"severity":"UNKNOWN"/i, '"severity":"UNKNOWN"'.unknown_color)
    end
  end
end
