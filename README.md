# RTALogger

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/RTALogger`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'RTALogger'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install RTALogger

## Usage

require 'log_factory_manager'
require 'log_factory_repository'

controller_name = 'test_controller'
userID = 5

#create log manager instance
# this could be a global variable declared in application level
log_manager = RTALogger::LogFactory.log_manager_instance

#set log manage application name (hard code)
log_manager.app_name = 'myTestApp'

#load log manager configuration from a json config file
log_manager.config('rta_logger_config.json')

#add log repository to log manager
#log_manager.propagator.add_log_repository(RTALogger::LogFactory.new_log_repository_console)

#add new topic to log manager
# use this api to get a new log topic instance
# this api could be called in entry point of each service or class initialize method
topic = log_manager.add_topic(controller_name)

#add log information to log topic
topic.debug(userID, 'Controller Name=', controller_name, 'this is debug')
topic.info(userID, 'Controller Name=', controller_name, 'this is an information')
topic.warning(userID, 'Controller Name=', controller_name, 'this is an warning')
topic.error(userID, 'Controller Name=', controller_name, 'this is an error')
topic.fatal(userID, 'Controller Name=', controller_name, 'this is a fatal situation')
topic.unknown(userID, 'Controller Name=', controller_name, 'this is a unknown situation')

#update specific topic log level if necessary
#log_manager.update_topic_level(controller_name, RTALogger::LogSeverity::INFO)

#update all topics log level if necessary
#log_manager.update_all_topics_log_level(RTALogger::LogSeverity::INFO)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/RTALogger.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
