require 'date'
require 'thread'
require 'singleton'
require 'json'
require 'json/version'
require 'json/generic_object'
require_relative 'log_factory_propagator'
require_relative 'log_factory_repository'
require_relative 'log_factory_topic'
require_relative 'severity_level'
require 'jbuilder'

# the module will contain all logger requirements
module RTALogger
  # the class is the main class
  class LogManager
    include Singleton
    include SeverityLevel
    include RTALogger::LogFactory

    def initialize
      @enable = true
      @title = 'default_log_manager'
      @app_name = ENV.fetch('RTA_LOGGER_APP_NAME', 'unknown_app')
      @severity_level = ENV.fetch('RTA_LOGGER_SEVERITY_LEVEL', INFO)
      @config_file_name = ''
      @topic_semaphore = Mutex.new
      @log_semaphore = Mutex.new
      self.buffer_size = ENV.fetch('RTA_LOGGER_BUFFER_SIZE', 100)
      self.flush_wait_time = ENV.fetch('RTA_LOGGER_FLUSH_WAIT_SECONDS', 5)
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

    attr_reader :title
    attr_accessor :enable
    attr_accessor :app_name
    attr_reader :propagator
    attr_accessor :default_severity_level
    attr_reader :flush_size
    attr_reader :topics
    attr_reader :config_file_name

    def buffer_size
      @buffer_size
    end

    def buffer_size=(size)
      @buffer_size = size < 100 ? 100 : size
      @flush_size = @buffer_size * 20 / 100
    end

    def flush_wait_time
      @flush_wait_time
    end

    def flush_wait_time=(time_in_seconds)
      @flush_wait_time = time_in_seconds < 5 ? 5 : time_in_seconds
    end

    def config_use_json_file(file_name, title = '')
      config_json = load_config_from_json_file(file_name, title)
      @config_file_name = file_name if config_json
      apply_config(config_json)
    rescue StandardError => e
      @propagator.drop_all_repositories
      @propagator.add_log_repository(LogFactory.create_repository(:console))
    end

    def config_use_json_string(config_string, title = '')
      config_json = load_config_from_json_string(config_string, title)
      apply_config(config_json)
    rescue StandardError => e
      @propagator.drop_all_repositories
      @propagator.add_log_repository(LogFactory.create_repository(:console))
    end

    def add_topic(title, severity_level = @default_severity_level, enable = true)
      @topic_semaphore.synchronize {
        @topics[title.to_sym] ||= LogFactory.new_log_topic(self, title, severity_level, enable)
      }

      @topics[title.to_sym]
    end

    def add_log(log_record)
      return unless @enable
      @log_semaphore.synchronize { @log_records.push(log_record) }
      check_for_flush
    end

    def update_topic_enable(topic, enable = true)
      @topic_semaphore.synchronize { @topics[topic.to_sym].enable = enable if @topics[topic.to_sym] }
    end

    def update_all_topics_enable(enable = true)
      @topic_semaphore.synchronize { @topics.keys.each { |topic| @topics[topic].enable = enable } }
    end

    def update_topic_severity_level(topic, severity_level = WARN)
      @topic_semaphore.synchronize { @topics[topic.to_sym].severity_level = severity_level if @topics[topic.to_sym] }
    end

    def update_all_topics_severity_level(severity_level = WARN)
      @topic_semaphore.synchronize { @topics.keys.each { |topic| @topics[topic].severity_level = severity_level } }
    end

    def topic_by_title(title)
      result = nil
      @topic_semaphore.synchronize do
        @topics.keys.each do |topic_key|
          result = @topics[topic_key.to_sym] if topic_key.to_s.casecmp(title).zero?
          break if result
        end
      end

      return result
    end

    def to_builder
      @topic_semaphore.synchronize do
        jb = Jbuilder.new do |json|
          json.title title
          json.enable enable
          json.app_name app_name
          json.config_file_name config_file_name
          json.default_severity_level default_severity_level
          json.buffer_size buffer_size
          json.flush_size flush_size
          json.flush_wait_time flush_wait_time
          json.repositories do
            # json.array! @propagator.repositories.collect { |repository| repository.to_builder.attributes! }
            json.array! @propagator.to_builder
          end
          json.topics do
            json.array! topics.keys.collect { |topic_key| @topics[topic_key].to_builder.attributes! }
          end
        end

        jb
      end
    end

    def reveal_config
      to_builder.target!
    end

    def apply_run_time_config(config_json)
      return unless config_json
      @enable = config_json['enable'] unless config_json['enable'].nil?
      @default_severity_level = parse_severity_level_to_s(config_json['severity_level']) unless config_json['severity_level'].nil?
      self.buffer_size = config_json['buffer_size'] unless config_json['buffer_size'].nil?
      self.flush_wait_time = config_json['flush_wait_time'] unless config_json['flush_wait_time'].nil?
      @propagator.apply_run_time_config(config_json)
      apply_run_time_config_topics(config_json)
    end

    private

    def apply_run_time_config_topics(config_json)
      config_json['topics']&.each do |topic_config|
        next if topic_config['title'].nil?
        topic = topic_by_title(topic_config['title'])
        topic.apply_run_time_config(topic_config) if topic.present?
      end
    end

    def load_config_from_json_file(config_file_name, title = '')
      config_file = File.open config_file_name
      config_json = ::JSON.load(config_file)
      config_json = extract_config(config_json, title)
      config_json
    end

    def load_config_from_json_string(config_string, title = '')
      config_json = ::JSON.parse(config_string)
      config_json = extract_config(config_json, title)
      config_json
    end

    def extract_config(json_data, title = '')
      config_json = json_data['rta_logger']
      raise 'RTALogger configuration not found!' unless config_json
      raise 'Log_Managers section does not exists json configuration' unless config_json['log_managers']
      raise 'No config manager defined in json configuration' unless config_json['log_managers'].count.positive?
      title = config_json['default_manager'] if title.empty?
      unless title.to_s.strip.empty?
        config_json = config_json['log_managers'].find { |item| item['title'] == title }
      end
      config_json ||= config_json['log_managers'][0]
      raise 'Unable to extract RTA Log Manager configuration!' unless config_json
      @title = title if config_json
      config_json
    end

    def apply_config(config_json)
      raise 'json config not available' unless config_json
      @enable = config_json['enable'].nil? ? true : config_json['enable']
      @app_name = config_json['app_name'] unless config_json['app_name'].empty?
      @default_severity_level = parse_severity_level_to_i(config_json['severity_level']) if config_json['severity_level']
      self.buffer_size = config_json['buffer_size'] if config_json['buffer_size']
      self.flush_wait_time = config_json['flush_wait_seconds'] if config_json['flush_wait_seconds']
      @propagator.load_repositories(config_json)
      apply_config_topics(config_json)
    end

    def apply_config_topics(config_json)
      config_json['topics']&.each do |topic|
        next unless topic['title']
        result_topic = add_topic(topic['title'])
        next unless result_topic
        result_topic.severity_level = parse_severity_level_to_i topic['severity_level'] if topic['severity_level']
        result_topic.enable = topic['enable'] if topic['enable']
      end
    end

    def initialize_flush_scheduler
      @flush_scheduler = Thread.new do
        loop do
          elapsed_seconds = ((DateTime.now - @last_flush_time) * 24 * 60 * 60).to_i
          flush if elapsed_seconds > flush_wait_time
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
        @log_records[0...@log_records.count].each { |log| propagate(log) }
        @log_records.clear
      end
      @propagator.propagate
    end

    def propagate(log_record)
      @propagator.add_log(log_record)
    end

  end
end
