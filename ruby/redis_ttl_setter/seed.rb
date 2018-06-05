require 'logger'
require 'redis'
require 'securerandom'

url = ARGV[0] || 'redis://127.0.0.1:6379/0'
count = ARGV[1] || 10_000_000
log_level = ARGV[1] || 'info'

logger = Logger.new($stdout)
logger.level = log_level

redis = Redis.new(url: url)

redis.pipelined do
  Array.new(count).map { |v|
    SecureRandom.uuid
  }.each { |v|
    redis.set(v, 'dummy')
  }
end

logger.info('finished.')
