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
- Some useful features
```ruby
    # change log manager app name at run time
    log_manager.app_name = 'myTestApp'

    # update specific topic log level if necessary
    log_manager.update_topic_level(controller_name, RTALogger::LogSeverity::INFO)

    # update all topics log level if necessary
    log_manager.update_all_topics_log_level(RTALogger::LogSeverity::INFO)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/BBahrainy/RTALogger.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
