# frozen_string_literal: true

require_relative '../../log_repository_console'
require_relative '../../log_repository_file'
require_relative '../../log_repository_udp'
#require_relative '../../log_repository_db'

module RTALogger
  # this module generates object instance
  module LogFactory
    def self.new_log_repository_console
      LogRepositoryConsole.new
    end

    def self.new_log_repository_file(file_path = 'log.txt', period = 'daily', shift_size = 1048576)
      LogRepositoryFile.new(file_path, period, shift_size)
    end

    def self.load_log_repository_file(config_json)
      file_path = config_json['File_Path'].to_s
      period = config_json['Roll_Period'].to_s
      shift_size = config_json['Roll_Size'].nil? ? 1048576 : config_json['Roll_Size'].to_i
      ::RTALogger::LogFactory.new_log_repository_file(file_path, period, shift_size)
    end

    def self.new_log_repository_udp(host = '127.0.0.1', port = 4913)
      LogRepositoryUDP.new(host, port)
    end

    def self.load_log_repository_udp(config_json)
      host = config_json['Host'].to_s
      port = config_json['Port'].nil? ? 4913 : config_json['Port'].to_i
      ::RTALogger::LogFactory.new_log_repository_udp(host, port)
    end

    def self.create_repository(type, config_json)
      result = nil
      result = new_log_repository_console if type.to_s.upcase.eql?('Console'.upcase)
      result = load_log_repository_file(config_json) if type.to_s.upcase.eql?('File'.upcase)
      result = load_log_repository_udp(config_json) if type.to_s.upcase.eql?('UDP'.upcase)
      result
    end
  end
end
