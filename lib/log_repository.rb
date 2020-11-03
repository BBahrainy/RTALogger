require 'thread'

module RTALogger
  # base log repository class
  class LogRepository
    def initialize
      @semaphore = Mutex.new
      @log_records = []
      @enable = true
    end

    def add_log_records(items)
      return 0 unless @enable
      @semaphore.synchronize do
        items.each { |item| @log_records.push(item.dup) }
      end
      flush_and_clear
    end

    attr_accessor :enable

    protected

    def flush_and_clear
      @semaphore.synchronize { @log_records.clear }
    end

    attr_reader :log_records
    attr_reader :semaphore
  end
end