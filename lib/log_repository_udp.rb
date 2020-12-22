require 'socket'

module RTALogger
  # show log items on console out put
  class LogRepositoryUDP < LogRepository
    def initialize(host = '127.0.0.1', port = 4913)
      super()
      @udp_socket = UDPSocket.new
      @udp_socket.bind(host, port)
    end

    def load_config(config_json)
      super

      host = config_json['host'].to_s
      port = config_json['port'].nil? ? 4913 : config_json['port'].to_i
      @udp_socket = UDPSocket.new
      @udp_socket.bind(host, port)
    end

    # register :udp

    protected

    def flush_and_clear
      semaphore.synchronize do
        @log_records.each { |log_record| @udp_socket.send @formatter.format(log_record), 0, @host, @port }
      end
      super
    end
  end
end
