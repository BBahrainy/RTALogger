require 'fluent-logger'
require_relative 'log_repository'

module RTALogger
  class LogRepositoryFluentd < LogRepository
    def initialize(host = 'localhost', port = 24224, tls_options = nil)
      super()
      @host = host
      @port = port
      @tls_options = tls_options
      @fluent_logger = nil
    end

    def load_config(config_json)
      super

      @host = config_json['host'].to_s
      @port = config_json['port'].to_i
      @tls_options = config_json['tls_options']

      @semaphore.synchronize { @fluent_logger = nil }
    end

    def host=(host)
      if @host != host
        @host = host ? host : 'localhost'
        @semaphore.synchronize { @fluent_logger = nil }
      end
    end

    def host
      @host
    end

    def port=(port)
      if @port != port
        @port = port ? port : 24224
        @semaphore.synchronize { @fluent_logger = nil }
      end
    end

    def port
      @port
    end

    def to_builder
      json = super
      json.enable @enable
      json.host @host
      json.port @port
      json.tls_options @tls_options

      json
    end

    # register :fluentd

    def apply_run_time_config(config_json)
      super config_json

      @host = config_json['host'] unless config_json['host'].nil?
      @port = config_json['port'] unless config_json['port'].nil?
      @tls_options = config_json['tls_options'] unless config_json['tls_options'].nil?
      @semaphore.synchronize { @fluent_logger = nil }

      @formatter.colorize = false
    end

    protected

    def create_fluentd_logger(host, port, tls_options)
      return nil unless @enable

      unless tls_options
        fluent_logger = ::Fluent::Logger::FluentLogger.new(nil, :host => host, :port => port, :use_nonblock => true, :wait_writeable => false)
      else
        fluent_logger = ::Fluent::Logger::FluentLogger.new(nil, :host => host,
                                                           :port => port,
                                                           :tls_options => tls_options,
                                                           :use_nonblock => true,
                                                           :wait_writeable => false)
      end

      fluent_logger
    end

    def flush_and_clear
      @semaphore.synchronize do
        @fluent_logger = create_fluentd_logger(@host, @port, @tls_options) unless @fluent_logger.present?

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
