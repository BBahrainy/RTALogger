require_relative 'log_repository'
require_relative 'factory/origin/log_factory_log_formatter'

module RTALogger
  # show log items on console out put
  class LogRepositoryConsole < LogRepository
    def initialize
      super

      @formatter = RTALogger::LogFactory::log_formatter_default
    end

    protected

    def flush_and_clear
      semaphore.synchronize do
        @log_records.each { |log_record| puts @formatter.format(log_record) }
      end
      super
    end

  end
end
