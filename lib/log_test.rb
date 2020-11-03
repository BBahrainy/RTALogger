#require 'logger'
#require 'date'
require_relative 'factory/origin/log_factory_manager'
require_relative 'factory/origin/log_factory_repository'
require 'socket'

controller_name = 'test_controller'
userID = 5

log_manager = RTALogger::LogFactory.log_manager_instance
log_manager.app_name = 'myTestApp'
log_manager.config('../../../config/rta_logger_config.json')
#log_manager.propagator.add_log_repository(RTALogger::LogFactory.new_log_repository_console)
#log_manager.propagator.add_log_repository(RTALogger::LogFactory.new_log_repository_file('../../../log/log.txt'))
#log_manager.propagator.add_log_repository(RTALogger::LogFactory.new_log_repository_udp('127.0.0.1', 4913))
# log_manager.propagator.add_log_repository(RTALogger::LogFactory.new_log_repository_db)

topic = log_manager.add_topic(controller_name)

topic.info(userID, 'Controller Name=', controller_name, 'Called by client 1')

#logger.level = RTALogger::LogSeverity::INFO
#manager.update_topic_level(controller_name, RTALogger::LogSeverity::INFO)

log_manager.update_all_topics_log_level(RTALogger::LogSeverity::INFO)

topic.info(userID, 'Controller Name|', controller_name, 'Called by client |2|')
topic.error(userID, 'Controller Name=', controller_name, 'Called by client 3')

#sleep(10)

topic.info(userID, 'Controller Name=', controller_name, 'Called by client |4|')
topic.fatal(userID, 'Controller Name=', controller_name, 'Called by client 5')
topic.info(userID, 'Controller Name=', controller_name, 'Called by client 6')

#ruby_logger = Logger.new(STDOUT)
#ruby_logger.formatter = proc do |severity, datetime, progname, msg|
#  "NICE: #{msg}\n"
#end
#ruby_logger.info('logged by ruby default logger')

