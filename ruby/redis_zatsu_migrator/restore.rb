require 'logger'
require 'parallel'
require 'redis'

url = ARGV[0] || 'redis://127.0.0.1:6379/0'
dumpfile = ARGV[1] || 'redis.dump'
thread_count = ARGV[2].to_i || 8
log_level = ARGV[3] || 'info'

logger = Logger.new(STDOUT)
logger.level = log_level

redis_clients = []
thread_count.times { redis_clients << Redis.new(url: url) }

serialized_values = File.read(dumpfile)
values = Marshal.load(serialized_values)

Parallel.each(values, in_threads: thread_count, progress: 'restore') do |k, v|
  unless redis_clients[Parallel.worker_number].exists(k)
    ttl = if v.fetch(:ttl) < 0
      0
    else
      v.fetch(:ttl)
    end
    redis_clients[Parallel.worker_number].restore(k, ttl, v.fetch(:value))
  end
end

logger.info("#{values.size} items restored.")
