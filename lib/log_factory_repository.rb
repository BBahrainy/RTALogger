# frozen_string_literal: true

module RTALogger
  # this module generates object instance
  module LogFactory
    def self.create_repository(type, config_json = '')
      lib_file = @log_repositories[type.to_sym]
      raise "unregistered repository class: #{type.to_s}" if lib_file.nil? || lib_file.empty?

      begin
        load lib_file
      rescue
        raise "unable to load repository class file: #{lib_file}"
      end

      # repo_class_name = 'RTALogger::' + type.split('_').map(&:capitalize).join
      repo_class_name = 'RTALogger::' + ('log_repository_' + type.to_s).split('_').map(&:capitalize).join
      repo_class = Object.const_get(repo_class_name)
      return nil unless repo_class
      result = repo_class.new

      # result = LogRepository.create type.to_sym
      return result if config_json.empty?
      result.load_config(config_json) if result.present?
      return result
    end

    def self.register_log_repository(type, class_file_name)
      @log_repositories[type.to_sym] = class_file_name
    end

    @log_repositories = {:console => 'log_repository_console.rb',
                          :file =>  'log_repository_file.rb',
                          :udp =>  'log_repository_upd.rb',
                          :fluentd => 'log_repository_fluetnd.rb'}
  end
end
