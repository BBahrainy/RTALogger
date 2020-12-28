require_relative 'log_repository'
require_relative 'log_factory_log_formatter'

module RTALogger
  # show log items on console out put
  class LogRepositoryConsole < LogRepository
    def initialize
      super
    end

    def load_config(config_json)
      super
    end

    # register :console

    protected

    def flush_and_clear
      @semaphore.synchronize do
        @log_records.each { |log_record| puts @formatter.format(log_record) }
      end
      super
    end
  end
end
