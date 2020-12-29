require 'jbuilder'
require_relative 'string'
require_relative 'severity_level'

module RTALogger
  class LogFormatterBase
    include SeverityLevel

    def initialize
      @delimiter = '|'
      @colorize = false
    end

    attr_accessor :delimiter
    attr_accessor :colorize

    def load_config(config_json)
      @delimiter = config_json['delimiter'].nil? ? true : config_json['delimiter']
      @colorize = config_json['colorize'].nil? ? false : config_json['colorize']
    end

    def format(log_record)
      log_record.to_s
    end

    def to_builder
      jb = Jbuilder.new do |json|
        json.type self.class.to_s.split('::').last.underscore.sub('log_formatter_', '')
        json.delimiter @delimiter
        json.colorize @colorize
      end

      jb
    end

    def reveal_config
      to_builder.target!
    end

    def apply_run_time_config(config_json)
      @delimiter = config_json['delimiter'] unless config_json['delimiter'].nil?
      @colorize = config_json['colorize'] unless config_json['colorize'].nil?
    end

    protected

    def severity_text(severity)
      text = parse_severity_level_to_s(severity)
      text = severity_colorized_text(severity, text) if @colorize
      return text
    end

    def severity_colorized_text(severity, text)
      case severity
      when 0
        text.trace_color
      when 1
        text.debug_color
      when 2
        text
      when 3
        text.warning_color
      when 4
        text.error_color
      when 5
        text.fatal_color
      when 6
        text.unknown_colorj
      else
        text
      end
    end
  end
end