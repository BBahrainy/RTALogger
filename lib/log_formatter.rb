# Log Formatter base class
module RTALogger
  class LogFormatter
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
  end
end
