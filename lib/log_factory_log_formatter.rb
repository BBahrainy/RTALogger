module RTALogger
  # Log factory to get new instance of log formatter
  module LogFactory
    def self.log_formatter_default
      create_formatter(:json)
    end

    def self.create_formatter(type, config_json = '')
      lib_file = @log_formatters[type.to_sym]
      raise "unregistered formatter class: #{type.to_s}" if lib_file.nil? || lib_file.empty?

      begin
        load lib_file
      rescue
        raise "unable to load formatter class file: #{lib_file}"
      end

      formatter_class_name = 'RTALogger::' + ('log_formatter_' + type.to_s).split('_').map(&:capitalize).join
      formatter_class = Object.const_get(formatter_class_name)
      return nil unless formatter_class
      result = formatter_class.new

      return result if config_json.empty?
      result.load_config(config_json) if result.present?
      return result
    end

    def self.register_log_formatter(type, class_file_name)
      @log_formatters[type.to_sym] = class_file_name
    end

    @log_formatters = {:text => 'log_formatter_text.rb',
                          :json =>  'log_formatter_json.rb'}
  end
end
