require 'logger'
require_relative 'log_repository'
require_relative 'log_factory_log_formatter'

module RTALogger
  # show log items on console out put
  class LogRepositoryFile < LogRepository
    def initialize(file_path = 'log.txt', period = 'daily', shift_size = 1_048_576)
      super()
      @file_logger = create_ruby_logger(file_path, period, shift_size)
      @formatter = RTALogger::LogFactory.log_formatter_default
    end

    def load_config(config_json)
      super

      file_path = config_json['file_path'].to_s
      period = config_json['roll_period'].to_s
      shift_size = config_json['roll_size'].nil? ? 1_048_576 : config_json['roll_size'].to_i
      @file_logger = create_ruby_logger(file_path, period, shift_size)
    end

    # register :file

    protected

    def create_ruby_logger(file_path, period, shift_size)
      ruby_logger = Logger.new(file_path, period, shift_size)
      ruby_logger.level = Logger::Severity::DEBUG
      ruby_logger.formatter = proc do |_severity, _datetime, _progname, msg|
        "#{msg}\n"
      end
      ruby_logger
    end

    def flush_and_clear
      semaphore.synchronize do
        @log_records.each { |log_record| @file_logger.debug(@formatter.format(log_record)) }
      end
      super
    end
  end
end
