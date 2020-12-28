module RTALogger
  class LogFilterBase
    def initialize
      @title = self.class.to_s.split('::').last.underscore
      @enable = true
    end

    attr_accessor :title
    attr_accessor :enable
    attr_accessor :default_regex

    def match_conditions(log_record)
      return true if !@enable
      return log_record.present?
    end

    def load_config(config_json)
      @title = config_json['title'] if config_json['title'].present?
      @enable = config_json['enable'].nil? ? true : config_json['enable'].present?
      @default_regex = config_json['default_regex'] if config_json['default_regex'].present?
    end

    def apply_run_time_config(config_json)
      @enable = config_json['enable'].nil? ? true : config_json['enable'].present?
      @default_regex = config_json['default_regex'] if config_json['default_regex'].present?
    end

    def to_builder
      jb = Jbuilder.new do |json|
        json.type self.class.to_s.split('::').last.underscore.sub('log_filter_', '')
        json.title @title
        json.enable @enable
        json.default_regex @default_regex
      end

      jb
    end
  end
end