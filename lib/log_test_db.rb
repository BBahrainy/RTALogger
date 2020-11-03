#require 'active_record'
#require 'pg'
# require 'active_record'  # uncomment for not Rails environment

#ActiveRecord::Base.establish_connection(:adapter => "postgresql",
#                                        :username => "postgre",
#                                        :database => "rails_test_development")

require 'log_record'

module RTALogger
  class LogFormatter
    def initialize(log_record,
                   delimiter = '|',
                   time_format = '%Y-%m-%d %H:%M:%S.%3N')
      @log_record = log_record
      @delimiter = delimiter
      @time_format = time_format
      @format_chance = format_chance
    end

    attr_accessor :log_record
    attr_accessor :delimiter
    attr_accessor :time_format

    def self.default_formatter(log_record)
      LogFormatter.new(log_record)
    end

    def to_s
      result = "#{occurred_at}#{@delimiter}#{@log_record.app_name}#{@delimiter}"
      result << "#{@log_record.topic_title}#{@delimiter}#{@log_record.context_id}"
      result << "#{@delimiter}#{@log_record.severity}#{@delimiter}#{log_message}"

      if @format_chance
        result unless @format_chance.call(occurred_at,
                                          @log_record.app_name,
                                          @log_record.topic_title,
                                          @log_record.context_id,
                                          @log_record.severity,
                                          log_message)
      end
      else
        result
      end
    end

    protected

    def log_message
      @log_record.message.join.gsub(delimiter, '&dlm&')
    end

    def occurred_at
      @log_record.occurred_at.strftime(time_format)
    end
  end
end

