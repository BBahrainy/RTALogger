require_relative 'string'
require_relative 'log_factory_filter'

module RTALogger
  # base log repository class
  class LogRepository
    def initialize
      @semaphore = Mutex.new
      @log_records = []
      @title = self.class.to_s.split('::').last.underscore
      @enable = true
      @formatter = RTALogger::LogFactory.log_formatter_default
      @filters = {}
    end

    # @@sub_classes = {}

    # def self.create type
    #   requested_class = @@sub_classes[type]
    #   if requested_class
    #     requested_class.new
    #   else
    #     raise "Bad log repository type: #{type}"
    #   end
    # end
    #
    # def self.register repository_name
    #   @@sub_classes[repository_name] = self
    # end

    attr_accessor :title
    attr_accessor :enable
    attr_accessor :formatter

    def add_log_records(items)
      return 0 unless @enable
      @semaphore.synchronize do
        items.each do |item|
          @log_records.push(item.dup) if filters_accept(item)
        end
      end

      flush_and_clear
    end

    def load_config(config_json)
      @enable = config_json['enable'].nil? ? true : config_json['enable']
      @title = config_json['title'].nil? ? self.class.to_s.split('::').last.underscore : config_json['title']
      formatter_config = config_json['formatter']
      if formatter_config && formatter_config['type']
        @formatter = LogFactory.create_formatter(formatter_config['type'], formatter_config)
      end

      apply_config_filters(config_json)
    end

    def to_builder
      jb = Jbuilder.new do |json|
        json.type self.class.to_s.split('::').last.underscore.sub('log_repository_', '')
        json.enable enable
        json.formatter @formatter.to_builder.attributes!
        json.filters do
          json.array! @filters.keys.collect { |filter_key| @filters[filter_key].to_builder.attributes! }
        end
      end

      jb
    end

    def reveal_config
      to_builder.target!
    end

    def filter_by_title(title)
      result = nil
      @semaphore.synchronize do
        @filters.keys.each do |filter_key|
          result = @filters[filter_key.to_sym] if filter_key.to_s.casecmp(title).zero?
          break if result
        end
      end

      return result
    end

    def apply_run_time_config(config_json)
      return unless config_json
      @enable = config_json['enable'] unless config_json['enable'].nil?
      apply_run_time_config_filters(config_json)
    end

    protected

    def apply_config_filters(config_json)
      config_json['filters']&.each do |filter_config|
        next if filter_config['type'].nil? || filter_config['title'].nil?
        filter = LogFactory.create_filter(filter_config['type'], filter_config)
        @filters[filter_config['title'].to_sym] = filter if filter.present?
      end
    end

    def apply_run_time_config_filters(config_json)
      return unless config_json

      config_json['filters']&.each do |filter_config|
        next if filter_config['title'].nil?
        filter = filter_by_title(filter_config['title'])
        if filter.present?
          filter.apply_run_time_config(filter_config)
        else
          filter = LogFactory.create_filter(filter_config['type'], filter_config)
          @semaphore.synchronize { @filters[filter_config['title'].to_sym] = filter if filter.present? }
        end
      end
    end

    def flush_and_clear
      @semaphore.synchronize { @log_records.clear }
    end

    def filters_accept(log_record)
      result = true
      @filters&.keys.each do |filter_key|
        result = @filters[filter_key.to_sym]&.match_conditions(log_record)
        break unless result
      end

      return result
    end

    attr_reader :log_records
    attr_reader :semaphore
  end
end
