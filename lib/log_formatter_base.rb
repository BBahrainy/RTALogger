require 'jbuilder'
require_relative 'string'

module RTALogger
  class LogFormatterBase
    def initialize
      @delimiter = '|'
    end

    attr_accessor :delimiter

    def load_config(config_json)
      @delimiter = config_json['delimiter'].nil? ? true : config_json['delimiter']
    end

    def format(log_record)
      log_record.to_s
    end

    def to_builder
      jb = Jbuilder.new do |json|
        json.type self.class.to_s.split('::').last.underscore.sub('log_formatter_', '')
        json.delimiter delimiter
      end

      jb
    end

    def reveal_config
      to_builder.target!
    end
  end
end