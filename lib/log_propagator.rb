require_relative 'log_repository'

module RTALogger
  # propagate log records to multiple log repositories
  class LogPropagator
    def initialize
      @semaphore = Mutex.new
      @records = []
      @repositories = []
    end

    attr_reader :repositories

    def add_log(record)
      @semaphore.synchronize { @records.push(record.dup) }
    end

    def add_log_repository(repository)
      return unless repository.is_a? RTALogger::LogRepository
      @repositories.push(repository) unless @repositories.include?(repository)
    end

    def load_log_repository(config_json)
      type = config_json['type']
      return if type.to_s.strip.empty?
      enable = config_json['enable'].nil? ? true : config_json['enable']
      return unless enable

      repository = ::RTALogger::LogFactory.create_repository(type, config_json)
      add_log_repository(repository)
    end

    def drop_all_repositories
      @semaphore.synchronize { @repositories.clear }
    end

    def propagate
      @semaphore.synchronize do
        @repositories.each do |repository|
          repository.add_log_records(@records)
        end
        @records.clear
      end
    end
  end
end
