require 'logger'
require 'redis'

url = ARGV[0] || 'redis://127.0.0.1:6379/0'
dumpfile = ARGV[1] || 'redis.dump'
logger = Logger.new(STDOUT)

redis = Redis.new(
  url: url,
)

serialized_values = File.read(dumpfile)
values = Marshal.load(serialized_values)

values.each do |k, v|
  logger.info(k)

  ttl = if v.fetch(:ttl) < 0
    0
  else
    v.fetch(:ttl)
  end
  redis.restore(k, ttl, v.fetch(:value))
end

logger.info("#{values.size} items restored.")
