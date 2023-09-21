require 'logger'
require 'os'

$var = OS.cpu_count

def log_ging
    logger = Logger.new(STDOUT)
    logger.level = Logger::INFO

    logger.info("Program started")
    
    while true
        logger.info("CPU count: #{$var}")
        sleep(1)
    end
end

# Start of the program
log_ging