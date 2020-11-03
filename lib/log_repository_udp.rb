require 'socket'

module RTALogger
  # show log items on console out put
  class LogRepositoryUDP < LogRepository
    def initialize(host = '127.0.0.1', port = 4913)
      super()
      @host = host
      @port = port
    end

    protected

    def flush_and_clear
      semaphore.synchronize do
        u1 = UDPSocket.new
        u1.bind(@host, @port)
        @log_records.each { |log_record| u1.send log_record.to_s, 0, @host, @port}
        u1.close
      end
      super
    end

  end
end
