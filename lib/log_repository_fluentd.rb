require 'fluent-logger'
require_relative 'log_repository'

module RTALogger
  class LogRepositoryFluentd < LogRepository
    def initialize(host = 'localhost', port = 24224, tls_options = nil)
      super()
      @host = host
      @port = port
      @fluent_logger = create_fluentd_logger(host, port, tls_options)
    end

    def load_config(config_json)
      super

      host = config_json['host'].to_s
      port = config_json['port'].to_s
      tls_options = config_json['tls_options']

      @fluent_logger = create_fluentd_logger(host, port, tls_options)
    end

    def to_builder
      json = super
      json.enable enable
      json.host @host
      json.port @port

      json
    end
    # register :fluentd

    protected

    def create_fluentd_logger(host, port, tls_options)
      unless tls_options
        fluent_logger = ::Fluent::Logger::FluentLogger.new(nil, :host => host, :port => port, :use_nonblock => true, :wait_writeable => false)
      else
        fluent_logger = ::Fluent::Logger::FluentLogger.new(nil, :host => host, :port => port, :tls_options => tls_options, :use_nonblock => true, :wait_writeable => false)
      end

      fluent_logger
    end

    def flush_and_clear
      semaphore.synchronize do
        @log_records.each do |log_record|
          fluent_tag = log_record.app_name + '.' + log_record.topic_title
          log_json_string = @formatter.format(log_record)
          log_json = JSON.parse(log_json_string)

          @fluent_logger.post(fluent_tag, log_json)
        end
      end
      super
    end
  end
end
