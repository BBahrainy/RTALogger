require 'date'
require 'thread'
require 'singleton'
require_relative 'log_factory_propagator'
require_relative 'log_factory_repository'
require_relative 'log_factory_topic'
require_relative 'log_severity'

# the module will contain all logger requirements
module RTALogger
  # the class is the main class
  class LogManager
    include Singleton
    include LogSeverity
    include RTALogger::LogFactory

    def initialize
      @enable = true
      @app_name = ENV.fetch('RTA_LOGGER_APP_NAME', 'unknown_app')
      @default_log_level = ENV.fetch('RTA_LOGGER_LOG_SEVERITY', ::RTALogger::LogSeverity::WARN)
      @topic_semaphore = Mutex.new
      @log_semaphore = Mutex.new
      @buffer_size = ENV.fetch('RTA_LOGGER_BUFFER_SIZE', 100)
      @flush_size = @buffer_size * 20 / 100
      @flush_wait_time = ENV.fetch('RTA_LOGGER_FLUSH_WAIT_SECONDS', 15)
      @topics = {}
      @log_records = []
      @propagator = LogFactory.new_log_propagator
      @last_flush_time = DateTime.now
      @exit_flush_scheduler = false
      initialize_flush_scheduler
      ObjectSpace.define_finalizer(self, proc {
        @exit_flush_scheduler = true
        flush_all
      })
      @flush_scheduler.run
    end

    def config_use_json_file(config_file_name, manager_name = '')
      config_json = load_config_from_json_file(config_file_name, manager_name)
      apply_config(config_json)
    rescue StandardError => e
      puts e.message
      @propagator.drop_all_repositories
      @propagator.add_log_repository(LogFactory.new_log_repository_console)
    end

    def config_use_json_string(config_string, manager_name = '')
      config_json = load_config_from_json_string(config_string, manager_name)
      apply_config(config_json)
    rescue StandardError => e
      puts e.message
      @propagator.drop_all_repositories
      @propagator.add_log_repository(LogFactory.new_log_repository_console)
    end

    attr_accessor :enable
    attr_accessor :app_name
    attr_reader :propagator
    attr_reader :default_log_level

    def add_topic(topic_title, log_level = @default_log_level)
      @topic_semaphore.synchronize {
        @topics[topic_title.to_sym] ||= LogFactory.new_log_topic(self, topic_title, log_level)
      }

      @topics[topic_title.to_sym].enable = @enable
      @topics[topic_title.to_sym]
    end

    def add_log(log_record)
      return unless @enable
      @log_semaphore.synchronize { @log_records.push(log_record) }
      check_for_flush
    end

    def update_topic_log_level(topic, log_level = WARN)
      @topic_semaphore.synchronize { @topics[topic].log_level = log_level if @topics[topic] }
    end

    def update_all_topics_log_level(log_level = WARN)
      @topic_semaphore.synchronize { @topics.keys.each { |topic| @topics[topic].log_level = log_level } }
    end

    private

    def load_config_from_json_file(config_file_name, manager_name = '')
      config_file = File.open config_file_name
      config_json = JSON.load config_file
      config_json = extract_config(config_json, manager_name)
      config_json
    end

    def load_config_from_json_string(config_string, manager_name = '')
      config_json = JSON.parse(config_string)
      config_json = extract_config(config_json, manager_name)
      config_json
    end

    def extract_config(json_data, manager_name = '')
      config_json = json_data['rta_logger']
      raise 'RTALogger configuration not found!' unless config_json
      raise 'Log_Managers section does not exists json configuration' unless config_json['log_managers']
      raise 'No config manager defined in json configuration' unless config_json['log_managers'].count.positive?
      manager_name = config_json['default_manager'] if manager_name.blank?
      unless manager_name.to_s.strip.empty?
        config_json = config_json['log_managers'].find { |item| item['manager_name'] == manager_name }
      end
      config_json ||= config_json['log_managers'][0]
      raise 'Unable to extract RTA Log Manager configuration!' unless config_json
      config_json
    end

    def apply_config(config_json)
      raise 'json config not available' unless config_json
      @enable = config_json['enable'].nil? ? true : config_json['enable']
      @app_name = config_json['app_name'] if config_json['app_name'].present?
      @default_log_level = parse_log_level_to_i(config_json['log_severity']) if config_json['log_severity'].present?
      @buffer_siz = config_json['buffer_size'] if config_json['buffer_size'].present?
      @flush_wait_time = config_json['flush_wait_seconds'] if config_json['flush_wait_seconds'].present?
      @propagator.drop_all_repositories
      config_json['repos']&.each { |item| @propagator.load_log_repository(item) }
    end

    def initialize_flush_scheduler
      @flush_scheduler = Thread.new do
        loop do
          elapsed_seconds = ((DateTime.now - @last_flush_time) * 24 * 60 * 60).to_i
          flush if elapsed_seconds > @flush_wait_time
          sleep(1)
          break if @exit_flush_scheduler
        end
      end
    end

    def check_for_flush
      flush if count > @buffer_size
    end

    def count
      @log_semaphore.synchronize { @log_records.count }
    end

    def flush
      @last_flush_time = DateTime.now
      @log_semaphore.synchronize do
        @log_records[0...@flush_size].each { |log| propagate(log) }
      end
      @log_semaphore.synchronize { @log_records.shift(@flush_size) }
      propagate_thread = Thread.new { @propagator.propagate }
      propagate_thread.join
    end

    def flush_all
      @log_semaphore.synchronize do
        @log_records[0...@log_records.count].each { |log|  propagate(log) }
        @log_records.clear
      end
      @propagator.propagate
    end

    def propagate(log_record)
      @propagator.add_log(log_record)
    end

    def parse_log_level_to_i(log_level)
      return log_level if log_level.is_a? ::Integer

      case log_level.upcase
      when 'DEBUG'
        0
      when 'INFO'
        1
      when 'INFORMATIONّٔ'
        1
      when 'WARN'
        2
      when 'WARNING'
        2
      when 'ERROR'
        3
      when 'FATAL'
        4
      when 'UNKNOWN'
        5
      end
    end
  end
end
