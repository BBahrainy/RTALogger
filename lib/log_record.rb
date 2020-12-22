require 'date'

module RTALogger
  # log data structure
  class LogRecord
    def initialize(log_topic, context_id, severity, *message)
      @log_topic = log_topic
      @context_id = context_id
      @severity = severity
      @message = message
      @occurred_at = DateTime.now
    end

    attr_reader :context_id
    attr_reader :severity
    attr_reader :message
    attr_reader :occurred_at

    def app_name
      @log_topic.log_manager.app_name
    end

    def topic_title
      @log_topic.title
    end
  end
end
