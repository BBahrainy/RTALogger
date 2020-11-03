require 'logger'
require_relative 'log_repository'
require_relative 'factory/origin/log_factory_file_logger'
require_relative 'factory/origin/log_factory_log_formatter'

module RTALogger
  # show log items on console out put
  class LogRepositoryFile < LogRepository
    def initialize(file_path = 'log.txt', period = 'daily', shift_size = 1048576)
      super()
      @file_logger = RTALogger::LogFactory.new_file_logger(file_path, period, shift_size)
      @formatter = RTALogger::LogFactory::log_formatter_default
    end

    protected

    def flush_and_clear
      semaphore.synchronize do
        @log_records.each { |log_record| @file_logger.debug(@formatter.format(log_record)) }
      end
      super
    end

  end
end
