module RTALogger
  # base log repository class
  class LogRepository
    def initialize
      @semaphore = Mutex.new
      @log_records = []
      @enable = true
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

    attr_accessor :enable

    def add_log_records(items)
      return 0 unless @enable
      @semaphore.synchronize do
        items.each { |item| @log_records.push(item.dup) }
      end
      flush_and_clear
    end

    def load_config(config_json)
      @enable = config_json['enable'].nil? ? true : config_json['enable']

      formatter_config = config_json['formatter']
      if formatter_config && formatter_config['type']
        @formatter = LogFactory.create_formatter(formatter_config['type'], formatter_config)
      end
    end

    protected

    def flush_and_clear
      @semaphore.synchronize { @log_records.clear }
    end

    attr_reader :log_records
    attr_reader :semaphore
  end
end
