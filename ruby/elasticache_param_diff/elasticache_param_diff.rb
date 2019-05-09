require 'aws-sdk-elasticache'
require 'colorize'

Diff = Struct.new(:diff_type, :key, :before_value, :after_value) do
  COLORS_BY_DIFF_TYPE = {
    '+' => :green,
    '-' => :red,
    '~' => :yellow,
  }

  def to_s
    "#{diff_type} #{key}: #{before_value.inspect} => #{after_value.inspect}".colorize(COLORS_BY_DIFF_TYPE[diff_type])
  end
end

def describe_cache_parameters(pg)
  elasticache = Aws::ElastiCache::Client.new

  response = elasticache.describe_cache_parameters(
    cache_parameter_group_name: pg,
  )

  response.flat_map(&:parameters).group_by(&:parameter_name)
end

def compare(hx, hy, &block)
  diffs = []
  block ||= lambda { |v| v }

  keys_only_hx = hx.keys - hy.keys
  keys_only_hy = hy.keys - hx.keys
  keys_only_hx.each do |key|
    diffs << Diff.new(
      '-',
      key,
      block.call(hx[key]),
      nil,
    )
  end
  keys_only_hy.each do |key|
    diffs << Diff.new(
      '+',
      key,
      nil,
      block.call(hy[key]),
    )
  end

  common_keys = hx.keys & hy.keys
  common_keys.each do |key|
    before = block.call(hx[key])
    after = block.call(hy[key])
    if before != after
      diffs << Diff.new(
        '~',
        key,
        before,
        after,
      )
    end
  end

  diffs
end

source_pg = ARGV[0]
target_pg = ARGV[1]

source = describe_cache_parameters(source_pg)
target = describe_cache_parameters(target_pg)

puts compare(source, target) { |v| v[0].parameter_value }
