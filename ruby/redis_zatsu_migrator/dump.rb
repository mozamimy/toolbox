require 'logger'
require 'redis'

url = ARGV[0] || 'redis://127.0.0.1:6379/0'
pattern = ARGV[1] || '*'
dumpfile = ARGV[2] || 'redis.dump'
logger = Logger.new(STDOUT)

redis = Redis.new(
  url: url,
)

values = {}
redis.keys(pattern).each do |key|
  logger.info(key)
  values[key] = {
    value: redis.dump(key),
    ttl: redis.ttl(key),
  }
end

serialized_values = Marshal.dump(values)
File.write(dumpfile, serialized_values)

logger.info("#{values.size} items dumped.")
