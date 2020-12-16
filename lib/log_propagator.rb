require_relative 'log_repository'

module RTALogger
  # propagate log records to multiple log repositories
  class LogPropagator
    def initialize
      @semaphore = Mutex.new
      @log_records = []
      @log_repositories = []
    end

    def add_log(log_record)
      @semaphore.synchronize { @log_records.push(log_record.dup) }
    end

    def add_log_repository(log_repository)
      return unless log_repository.is_a? RTALogger::LogRepository
      @log_repositories.push(log_repository) unless @log_repositories.include?(log_repository)
    end

    def load_log_repository(config_json)
      type = config_json['type']
      return if type.to_s.strip.empty?
      enable = config_json['enable'].nil? ? true : config_json['enable']
      return unless enable

      log_repository = ::RTALogger::LogFactory.create_repository(type, config_json)
      add_log_repository(log_repository)
    end

    def drop_all_repositories
      @semaphore.synchronize { @log_repositories.clear }
    end

    def propagate
      @semaphore.synchronize do
        @log_repositories.each do |log_repository|
          log_repository.add_log_records(@log_records)
        end
        @log_records.clear
      end
    end
  end
end
