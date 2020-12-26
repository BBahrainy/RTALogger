# RTALogger

RTA Log Manager has been designed and implemented to provide standard logging API for developers.
This prevents chaos in log data format. 
Also provide multiple extendable log repositories including wrapping existing loggers, like 'Fluentd' or implement completely new custom logger. 
All log manager's main features are configable through a json config file.

Main purposes of developing this gem are:
- Creating standard logging API to seperate application from existing variety of loggers.
- Wrapping around existing loggers to get advantage of different loggers at the same time.
- Make it possible to easily replace a logger component with new one without any changes in the consumer application.(for example Rails standard Logger with Fluentd)
- Creating easy to use logger interface for developers.
- Apply some rules and restrictions about log structure and data format, which prevents chaos in application's log information.
- No interrupt, wait time or overhead for log consumer modules.
- Utilize multiple log repositories at the same time in background (Console, File, UDP, FluentD, etc.) 
- Make it possible to implement customize log repositories.

Main Features:
- Creating multiple log manager instances with different configuration is possible entire application.
- Each log manager instance could be configured via a json file.
- Each log manager instance could be config to use multiple log repositories such as Console, File, UDP, Fluentd.
- Runtime configurations could be applied through log manager APIs.
- By using multi threading and buffering techniques, all logging process will handled in seperated thread.
  So the log consumer modules should not be wait for log manager to finish the logging task.
- Multiple standard log severity levels are available through topic APIs (debug, info, warning, error, fatal, unknown)
- Main features could be set and manipulate through json configuration file.
- And at the end, it is easy to use for ruby developers. 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'RTALogger'
```

Then execute:

    $ bundle install

Or install it yourself via following command:

    $ gem install RTALogger

To add gem to your rails application:
   
     $ bundle add RTALogger
     
## Usage
#### RTA Log Data Structure
To use log manager APIs, first step is to have a quick review on Log Data Structure
- Application: The root of each log data record is the Application name, which specify the log data owner application.
- Topic: By adding multiple topics to log manager you can categorize log data in logical topics.
- Context: Under each topic, one or multiple contexts (in one level) could be defined. 
- As an instance for Application 'MyEShopApp', one of Topics could be 'Authentication' and 
  Context could be 'uer_name' which attend in application authorization process.
- The next step is log severity level, which determines the log record severity (debug, information, warning, error, fatal, unknown)
- At last the final element is log message, which contains log message data.

### Which Log Severity Levels to use
- DEBUG = 0 : Low-level information, mostly for developers.
- INFO = 1 : Generic (useful) information about system operation.
- WARN = 2 : A warning, which it does NOT cause crashing the process.
- ERROR = 3 : A handleable error condition.
- FATAL = 4 : An un-handleable error that results in a program crash.
- UNKNOWN = 5 : An unknown message that should always be logged.
    
### Time for coding
- create log manager instance:
```ruby
    # add required files
    require 'log_factory_manager'

    # create log manager instance using LogFactory
    log_manager = RTALogger::LogFactory.log_manager_instance
```
- Apply configuration using json config file
```ruby
    # the parameter is the json config file
    log_manager.config_use_json_file('rta_logger_config.json')
```
- Sample configuration json file
```
{
  "rta_logger":
  {
    "default_manager": "develop",
    "log_managers":
      [
        {
          "manager_name": "develop",
          "enable": true,
          "app_name": "TestApp",
          "severity_level": "debug",
          "buffer_size": 100,
          "flush_wait_seconds": 15,
          "repositories":
                  [
                    {
                      "enable": true,
                      "type": "console",
                      "formatter": "delimited_text",
                      "delimiter": "|"
                    },
                    {
                      "enable": true,
                      "type": "File",
                      "file_path": "./log/log.txt",
                      "roll_period": "daily",
                      "roll_size": "1048576",
                      "formatter": "delimited_text",
                      "delimiter": "|"
                    },
                    {
                      "enable": true,
                      "type": "fluentd",
                      "host": "localhost",
                      "port": "8888",
                      "formatter": "json"
                    }
                  ]
        }
      ]
  }
}
``` 
- Add new topic to log manager and get the topic instance
```ruby
    # the parameter is the topic name
    # if add_topic API called multiple times with same parameter,
    # only one instance will be created for that topic 
    topic = log_manager.add_topic('Authentication')
```
- Finally add log message using topic instance
```ruby
    # Assume user 'Tom' is trying to authenticate we will use user_name as log Context_id
    user_name = 'Tom'
    topic = log_manager.add_topic('Authentication')
    topic.debug(user_name, 'use_id is nil for user:', user_name)
    topic.info(user_name, 'User ', user_name , ' is trying to login.')
    topic.warning(user_name, 'Authentication failed for user ', user_name)
    topic.error(user_name, 'Error connecting to data base for user ', user_name)
    topic.fatal(user_name, 'Authentication service has been stopped working')
    topic.unknown(user_name, 'An unknown error occured during authentication. user name:', user_name)
```
the result will be:
```
    {"occurred_at":"2020-11-04 15:56:58:785","app_name":"TestApp","topic_title":"Authentication","context_id":"Tom","severity":"DEBUG","message":"user_id is nil for user: Tom"}
    {"occurred_at":"2020-11-04 15:56:58:785","app_name":"TestApp","topic_title":"Authentication","context_id":"Tom","severity":"INFO","message":"User Tom is trying to login"}
    {"occurred_at":"2020-11-04 15:56:58:785","app_name":"TestApp","topic_title":"Authentication","context_id":"Tom","severity":"WARN","message":"Authentication failed for user Tom"}
    {"occurred_at":"2020-11-04 15:56:58:785","app_name":"TestApp","topic_title":"Authentication","context_id":"Tom","severity":"ERROR","message":"Error connecting to data base for user Tom"}
    {"occurred_at":"2020-11-04 15:56:58:785","app_name":"TestApp","topic_title":"Authentication","context_id":"Tom","severity":"FATAL","message":"Authentication service has been stopped working"}
    {"occurred_at":"2020-11-04 15:56:58:785","app_name":"TestApp","topic_title":"Authentication","context_id":"Tom","severity":"UNKNOWN","message":"An unknown error occured during authentication. user name: Tom"}
```
- json config file sample
```json
{
  "rta_logger":
  {
    "default_manager": "develop",
    "log_managers":
    [
      {
        "manager_name": "develop",
        "enable": true,
        "app_name": "TestApp",
        "severity_level": "debug",
        "buffer_size": 100,
        "flush_wait_seconds": 15,
        "repositories":
        [
          {
            "enable": true,
            "type": "console",
            "formatter":
            {
              "type": "text",
              "delimiter": "|"
            }
          },
          {
            "enable": false,
            "type": "file",
            "file_path": "log.txt",
            "roll_period": "daily",
            "roll_size": "1048576",
            "formatter":
            {
              "type": "text",
              "delimiter": "|"
            }
          },
          {
            "enable": false,
            "type": "fluentd",
            "host": "localhost",
            "port": "8888",
            "formatter":
            {
              "type": "json"
            }
          }
        ],
        "topics":
        [
          {
            "title": "test",
            "enable": true,
            "severity_level": "info"
          }
        ]
      }
    ]
  }
}
```
- json config file structure 
```comment
  As we described you cap apply RTA log manager using a json config file.
  
  log_manager.config_use_json_file('rta_logger_config.json')
     
  The file structure:
  - rta_logger : the root element of rta_logger json configuration.
    - default_manager: the name of default log manager config, when there is 
      multiple log manager configuration in Log_Managers array.
    - log_managers : the array of LogManagers with different configuration.
      It is possible to define multiple log manager configurations for differen usages.
      - manager_name: the name of log manager. It will be used to define the default log manager.
      - enable: (true/false) The value of this property activate or deactivate entire log manager.
      - app_name: Application name as the owner of log data.
      - severity_level: Defines which level of log data will be stored in log repositories.
      - buffer_size: Minimune possible value for this attribute is 100 and defines memory buffer size (number of buffered log objects) to 
        decread api consumers wait time. when the buffer is full the flush operation will
        save buffered logs to log repositoies.
      - flush_wait_seconds: Minimum possible value for this attribure is 10 seconds and defines time in soconds which log managers wait to flush buffered log records
        to log repository.
      - repositories: Array of log repositories. It is possible to define multiple log repositories to
        store log data. there are variaty of log repositories and it is possible to
        add new ones. Each item in Repos array will configure a log repository.
        Pre-defined types are described below, also it's possible to implement your custome repo type 
        and register it to RTALogger.
        - Log repository types and config:
          1- console: Show log data in text format on standard out put
             - "type": "console"
             - "enable": [true/false] this will activate or deactivate log repository.
             - "foramtter" is the text, json or any custome defined types as LogRecord formatter
                - "type": ["text"/"json"] type of formatter
                - "delimiter": [any text delimiter you need.(as an instance pipe line "|")]
                if formatter not defined then the json formatter will be used
          2- file: Store log data in a file.
             - "type": "console"
             - "enable": [true/false] this will activate or deactivate log repository.
             - "file_path": [file path and file name] the path and the name to store log data.
             - "roll_period": ["daily"/"weekly"/"monthly"] the period to generate new log file.
             - "roll_size": [bytes]  the maximum size of log file to 
                roll file and create the new log file
             - "foramtter" is the text, json or any custome defined types as LogRecord formatter
                - "type": ["text"/"json"] type of formatter
                - "delimiter": [any text delimiter you need.(as an instance pipe line "|")]
                if formatter not defined then the json formatter will be used
          3- udp: Send log data over UDP on network. 
             - "type": "udp"
             - "enable": [true/false] this will activate or deactivate log repository.
             - "host": IP of the server to send log data.
             - "port": Port of server to send log data.
          4- fluentd: send log data to Fluentd Log collector over network using TCP/IP protocol.
             - "type": "fluentd"
             - "enable": [true/false] this will activate or deactivate log repository.
             - "host": IP of the server to send log data.
             - "port": Port of server to send log data.
             - "tls_options": TLS configuration to stablish a secure TCP connection to Fluentd Server.
             - "foramtter" is the text, json or any custome defined types as LogRecord formatter
                - "type": ["text"/"json"] type of formatter
                - "delimiter": [any text delimiter you need.(as an instance pipe line "|")]
                if formatter not defined then the json formatter will be used
        - topics: This is an optional item. When you need to customize a specific topic severity level or
                  enable value, you can define the settings here.
          - title: The topic title to customize. (mandatoy).
          - severity_level: Defines which level of log data will be stored in log repositories.
          - enable: [true/false] to enable or disable logging process of the topic.
```
- Some useful features
```ruby
    # change log manager app name at run time
    log_manager.app_name = 'myTestApp'

    # update specific topic log level if necessary
    log_manager.update_topic_severity_level(topic_title, RTALogger::SeverityLevel::INFO)

    # update all topics severity level if necessary
    log_manager.update_all_topics_severity_level(RTALogger::SeverityLevel::INFO)

    # enable or disable specific topic if necessary
    log_manager.update_topic_enable(topic_title, [true/false])

    # enable or disable all topic if necessary
    log_manager.update_all_topics_enable([true/false])
```
- Implement and Expand
  It is possible to implement new log repositories. There will be fue rules to implement and
  integrate new customized log repository with RTALogger LogManager.
  
  1- Define you class inside RTALogger module.
  
  2- The class should be inherited from 'RTALogger::LogRepository'.
  
  3- Also appropriate naming convention is necessary. 
     As an example if you are implementing a Console Repo, your class name should be LogRepositoryConsole and 
     your source code in a ruby file and name it log_repository_console.rb
  
  4- After implementing your own log repository, you should register the class at run-time using the following syntax:
  ```ruby
  RTALogger::LogFactory.register_log_repository :console, 'log_repository_console.rb'
  ```
  Another example: LogRepositoryMyCustomizedUdp

  ```ruby
  RTALogger::LogFactory.register_log_repository :my_customized_udp, 'log_repository_my_customized_udp.rb'
  ```
  Here is 'LogRepositoryConsole' implementation:
```ruby
require_relative 'log_repository'
require_relative 'log_factory_log_formatter'

module RTALogger
  # show log items on console out put
  class LogRepositoryConsole < LogRepository
    def initialize
      super

      @formatter = RTALogger::LogFactory.log_formatter_default
    end

    protected

    def flush_and_clear
      semaphore.synchronize do
        @log_records.each { |log_record| puts @formatter.format(log_record) }
      end
      super
    end
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/BBahrainy/RTALogger.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
