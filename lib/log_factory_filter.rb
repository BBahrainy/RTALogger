require_relative 'log_filter_base'

module RTALogger
  # Log factory to get new instance of log filter
  module LogFactory
    def self.create_filter(type, config_json = '')
      lib_file = @log_filters[type.to_sym]
      raise "unregistered filter class: #{type.to_s}" if lib_file.nil? || lib_file.empty?
      begin
        load lib_file
      rescue
        raise "unable to load formatter class file: #{lib_file}"
      end

      filter_class_name = 'RTALogger::' + ('log_filter_' + type.to_s).split('_').map(&:capitalize).join
      filter_class = Object.const_get(filter_class_name)
      return nil unless filter_class
      result = filter_class.new

      return result if config_json.empty?
      result.load_config(config_json) if result.present?
      return result
    end

    def self.register_log_filter(type, class_file_name)
      @log_filters[type.to_sym] = class_file_name
    end

    @log_filters = {:topic => 'log_filter_topic.rb',
                    :context => 'log_filter_context.rb',
                    :message => 'log_filter_message.rb'}
  end
end
