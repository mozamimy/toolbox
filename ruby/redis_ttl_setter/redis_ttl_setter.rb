require 'logger'
require 'redis'

master_url = ARGV[0] || 'redis://127.0.0.1:6379/0'
slave_url = ARGV[1] || 'redis://127.0.0.1:6380/0'
pattern = ARGV[2] || '*'
ttl = ARGV[3] || 60 * 60 * 24 * 2 # 2 days
batch_size = ARGV[3] || 100_000
log_level = ARGV[4] || 'info'

logger = Logger.new($stdout)
logger.level = log_level

master = Redis.new(url: master_url)
slave = Redis.new(url: slave_url, timeout: 120)

keys = slave.keys(pattern)

keys.each_slice(batch_size) do |sliced_keys|
  master.pipelined do
    sliced_keys.each do |key|
      master.expire(key, ttl)
    end
    logger.info('Sent pipelined commands.')
    sleep 3
  end
end

logger.info('Finished.')
