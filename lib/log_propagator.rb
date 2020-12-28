require_relative 'log_repository'

module RTALogger
  # propagate log records to multiple log repositories
  class LogPropagator
    def initialize
      @semaphore = Mutex.new
      @records = []
      @repositories = {}
    end

    attr_reader :repositories

    def add_log(record)
      @semaphore.synchronize { @records.push(record.dup) }
    end

    def add_log_repository(repository)
      return if repository.nil? || repository.title.to_s.empty?
      return unless repository.is_a? RTALogger::LogRepository
      @semaphore.synchronize { @repositories[repository.title.to_sym] = repository unless @repositories[repository.title.to_sym].present? }
    end

    def load_log_repository(config_json)
      type = config_json['type']
      return if type.to_s.strip.empty?

      repository = ::RTALogger::LogFactory.create_repository(type, config_json)
      add_log_repository(repository)
    end

    def load_repositories(config_json)
      return if config_json.nil?

      @semaphore.synchronize do
        @repositories.clear
        config_json['repositories']&.each do |repository_config|
          type = repository_config['type']
          next if type.to_s.strip.empty?

          repository = ::RTALogger::LogFactory.create_repository(type, repository_config)
          @repositories[repository.title.to_sym] = repository unless @repositories[repository.title.to_sym].present?
        end
      end
    end

    def drop_all_repositories
      @semaphore.synchronize { @repositories.clear }
    end

    def repository_by_title(title)
      result = nil
      @semaphore.synchronize do
        @repositories.keys.each do |repository_key|
          result = @repositories[repository_key.to_sym] if repository_key.to_s.casecmp(title).zero?
          break if result
        end
      end

      return result
    end

    def apply_run_time_config(config_json)
      return unless config_json
      apply_run_time_config_repositories(config_json)
    end

    def propagate
      @semaphore.synchronize do
        @repositories.keys.each do |repository_key|
          @repositories[repository_key.to_sym].add_log_records(@records)
        end
        @records.clear
      end
    end

    def to_builder
      result = nil
      @semaphore.synchronize do
        result = @repositories&.keys.collect { |repository_key| @repositories[repository_key].to_builder.attributes! }
      end

      return result
    end

    private

    def apply_run_time_config_repositories(config_json)
      config_json['repositories']&.each do |repository_config|
        next if repository_config['title'].nil?
        repository = repository_by_title(repository_config['title'])
        if repository.present?
          repository.apply_run_time_config(repository_config)
        else
          repository = ::RTALogger::LogFactory.create_repository(repository_config['type'], config_json)
          add_log_repository(repository)
        end
      end
    end

  end
end
