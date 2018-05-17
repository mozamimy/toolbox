require 'logger'
require 'parallel'
require 'redis'

url = ARGV[0] || 'redis://127.0.0.1:6379/0'
pattern = ARGV[1] || '*'
dumpfile = ARGV[2] || 'redis.dump'
thread_count = ARGV[3].to_i || 8
log_level = ARGV[4] || 'info'

logger = Logger.new(STDOUT)
logger.level = log_level

redis_clients = []
thread_count.times { redis_clients << Redis.new(url: url) }

raw_results = Parallel.map(redis_clients[0].keys(pattern), in_threads: thread_count, progress: 'dump') do |key|
  {
    key: key,
    value: redis_clients[Parallel.worker_number].dump(key),
    ttl: redis_clients[Parallel.worker_number].ttl(key),
  }
end

results = {}
raw_results.each do |raw_result|
  results[raw_result.fetch(:key)] = {
    value: raw_result.fetch(:value),
    ttl: raw_result.fetch(:ttl),
  }
end

serialized_results = Marshal.dump(results)
File.write(dumpfile, serialized_results)

logger.info("#{raw_results.size} items dumped.")
