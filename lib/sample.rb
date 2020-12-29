require_relative 'log_factory_manager'
require_relative 'log_factory_repository'
# require_relative 'string'

# puts 'trace'.gray
# puts 'debug'.green
# puts 'info'
# puts 'warning'.brown
# puts 'error'.red
# puts 'fatal'.bg_red
# puts 'unknown'.bg_cyan

controller_name = 'test_controller'
userID = 5

# RTALogger::LogFactory.register_log_repository :console, 'log_repository_console.rb'

# create log manager instance
# this could be a global variable declared in application level
log_manager = RTALogger::LogFactory.log_manager_instance

# set log manage application name (hard code)
log_manager.app_name = 'myTestApp'

# load log manager configuration from a json config file
log_manager.config_use_json_file('rta_logger_config.json')

# add log repository to log manager
#log_manager.propagator.add_log_repository(RTALogger::LogFactory.new_log_repository_console)

# add new topic to log manager
# use this api to get a new log topic instance
# this api could be called in entry point of each service or class initialize method
topic = log_manager.add_topic(controller_name)
test_topic = log_manager.add_topic('test')
# test_topic.severity_level = ::RTALogger::SeverityLevel::FATAL
# test_topic.enable = false

# add log information to log topic
topic.trace(userID, 'Controller Name=', controller_name, 'trace')
topic.debug(userID, 'Controller Name=', controller_name, 'debug')
topic.info(userID, 'Controller Name=', controller_name, 'information')
topic.warning(userID, 'Controller Name=', controller_name, 'warning')
topic.error(userID, 'Controller Name=', controller_name, 'error')
topic.fatal(userID, 'Controller Name=', controller_name, 'fatal')
topic.unknown(userID, 'Controller Name=', controller_name, 'unknown')

test_topic.error(userID, 'test_topic', 'error')
test_topic.fatal(userID, 'test_topic', 'fatal')

# puts log_manager.reveal_config

# update specific topic log level if necessary
# log_manager.update_topic_level(controller_name, RTALogger::SeverityLevel::INFO)

# update all topics log level if necessary
# log_manager.update_all_topics_severity_level(RTALogger::SeverityLevel::INFO)
