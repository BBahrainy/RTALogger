require_relative 'log_filter_base'

module RTALogger
  class LogFilterTopic < LogFilterBase
    def match_conditions(log_record)
      return true if !@enable
      result = super
      return result unless result

      result = default_regex.present? ? (Regexp.new(@default_regex).match(log_record.topic_title)) : result
      result = !result if @action == :ignore
      return result
    end
  end
end