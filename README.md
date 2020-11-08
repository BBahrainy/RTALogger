# RTALogger

RTA Log Manager has been designed and implemented to provide standard logging API for developers.
This prevents chaos in log data format. 
Also provide multiple extendable log repositories including wrapping existing loggers, like 'Fluentd' or implement completely new custom logger. 
All log manager's main features are configable through a json config file.

Main purposes of developing this gem are:
- Creating easy to use logger interface.
- Apply some rules and restrictions about log structure and data format, which prevents chaos in application log information.
- No interrupt or wait time for log consumer modules.
- Utilize multiple log repositories at the same time in background (Console, File, UDP, FluentD, etc.) 
- Make it possible to implement customized log repositories.

Main Features:
- Creating multiple log manager instances with different configuration is possible entire application.
- Each log manager instance could be configured via a json file.
- Each log manager instance could be config to use multiple log repositories such as Console, File, UDP, Fluentd.
- Runtime configurations could be applied through log manager APIs.
- By using multi threading techniques and also buffering techniques, 
  all logging process will handled in seperated thread.
  So the log consumer modules should not be wait for log manager to finish the logging task.
- Multiple standard log severity levels are available through topic APIs (debug, info, warning, error, fatal, unknown)
- Main features could be set and manipulate through json configuration file.
- And at the end, it is easy to use for ruby backend developers. 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'RTALogger'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install RTALogger

To add gem to your rails application:
   
     $ bundle add RTALogger
     
## Usage
#### RTA Log Data Structure
To use log manager APIs, first step is to have a quick review on Log Data Structure
- Application: The root of each log data record is Application, which specify the log data owner application.
- Topic: By adding multiple topics to log manager you can categorize log data in logical topics.
- Context: Under each topic, one or multiple contexts (in one level) could be defined. 
- As an instance the Application could by 'MyEShopApp', one of Topics could be 'Authentication' and 
  Contexts could be 'uer_name' which attend in application authorization process.
- The next step is log severity level, which determines that the log record severity (debug, information, warning, error, fatal, unknown)
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
    {"occurred_at":"2020-11-04 15:56:58:785","app_name":"TestApp","topic_title":"Authentication","context_id":"Tom","severity":0,"message":"user_id is nil for user: Tom"}
    {"occurred_at":"2020-11-04 15:56:58:785","app_name":"TestApp","topic_title":"Authentication","context_id":"Tom","severity":1,"message":"User Tom is trying to login"}
    {"occurred_at":"2020-11-04 15:56:58:785","app_name":"TestApp","topic_title":"Authentication","context_id":"Tom","severity":2,"message":"Authentication failed for user Tom"}
    {"occurred_at":"2020-11-04 15:56:58:785","app_name":"TestApp","topic_title":"Authentication","context_id":"Tom","severity":3,"message":"Error connecting to data base for user Tom"}
    {"occurred_at":"2020-11-04 15:56:58:785","app_name":"TestApp","topic_title":"Authentication","context_id":"Tom","severity":4,"message":"Authentication service has been stopped working"}
    {"occurred_at":"2020-11-04 15:56:58:785","app_name":"TestApp","topic_title":"Authentication","context_id":"Tom","severity":5,"message":"An unknown error occured during authentication. user name: Tom"}
```
- json config file sample
```json
{
  "RTALogger":
  {
    "Default_Manager": "Develop",
    "Log_Managers":
    [
      {
        "Manager_Name": "Develop",
        "Enable": true,
        "App_Name": "TestApp",
        "Log_Severity": 2,
        "Buffer_Size": 100,
        "Flush_Wait_Seconds": 15,
        "Formatter" : "JSON",
        "Repos":
        [
          {
            "Enable": true,
            "Type": "Console"
          },
          {
            "Enable": true,
            "Type": "UDP",
            "Host": "localhost",
            "Port": 8888
          },
          {
            "Enable": false,
            "Type": "File",
            "File_Path": "../../log/log.txt",
            "Roll_Period": "daily",
            "Roll_Size": "1048576"
          },
          {
            "Enable": true,
            "Type": "Fluentd",
            "Host": "localhost",
            "Port": "24442",
            "TLS_Options": 
            {
              "ca":",/path/to/cacert.pem",
              "cert":"/path/to/client-cert.pem",
              "key":"/path/to/client-key.pem",
              "key_passphrase":"test"
             }
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
  - RTALogger : the root element of RTALogger json configuration.
    - Default_Manager: the name of default log manager config, when there is 
      multiple log manager configuration in Log_Managers array.
    - Log_Managers : the array of LogManagers with different configuration.
      It is possible to define multiple log manager configurations for differen usages.
      - Name: the name of log manager. It will be used to define the default log manager.
      - Enable: (true/false) The value of this property activate or deactivate entire log manager.
      - App_Name: Application name as the owner of log data.
      - Log_Severity: Defines which level of log data will be stored in log repositories.
      - BufferSize: The memory buffer size (number of buffered log objects) to 
        decread api consumers wait time. when the buffer is full the flush operation will
        save buffered logs to log repositoies.
      - Flush_Wait_Seconds: Time in soconds which log managers wait to flush buffered log objects
        to log repository.
      - Formatter: (JSON/TEXT) declare log format when it's required to converrt log object to text.
      - Repos: Array of log repositories. It is possible to define multiple log repositories to
        store log data. there are variaty of log repositories and it is possible to
        add new ones. Each item in Repos array will configure a log repository.
        - Log repository types and config:
          1- Console: Show log data in text format on standard out put
             - "Type":"Console"
             - "Enable": [true/false] this will activate or deactivate log repository.
          2- File: Store log data in a file.
             - "Type":"Console"
             - "Enable": [true/false] this will activate or deactivate log repository.
             - "File_Path": [file path and file name] the path and the name to store log data.
             - "Roll_Period": ["daily"/"weekly"/"monthly"] the period to generate new log file.
             - "Roll_Size": [bytes]  the maximum size of log file to 
                roll file and create the new log file
          3- UDP: Send log data over UDP on network. 
             - "Type":"Console"
             - "Enable": [true/false] this will activate or deactivate log repository.
             - "Host": IP of the server to send log data.
             - "Port": Port of server to send log data.
          4- Fluentd: send log data to Fluentd Log collector over network using TCP/IP protocol.
             - "Type":"Console"
             - "Enable": [true/false] this will activate or deactivate log repository.
             - "Host": IP of the server to send log data.
             - "Port": Port of server to send log data.
             - "TLS_Options": TLS configuration to stablish a secure TCP connection to Fluentd Server.
 
```
- Some useful features
```ruby
    # change log manager app name at run time
    log_manager.app_name = 'myTestApp'

    # update specific topic log level if necessary
    log_manager.update_topic_level(controller_name, RTALogger::LogSeverity::INFO)

    # update all topics log level if necessary
    log_manager.update_all_topics_log_level(RTALogger::LogSeverity::INFO)
```
- Implement and Expand
  It is possible to implement new log repositories.
  All repository classes should inherit from 'RTALogger::LogRepository'
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
