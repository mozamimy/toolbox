require 'aws-sdk-ec2'

NORMALIZATION_FACTORS = {
  'nano' => 0.25,
  'micro' => 0.5,
  'small' => 1.0,
  'medium' => 2.0,
  'large' => 4.0,
  'xlarge' => 8.0,
  '2xlarge' => 16.0,
  '3xlarge' => 24.0,
  '4xlarge' => 32.0,
  '6xlarge' => 48.0,
  '8xlarge' => 64.0,
  '9xlarge' => 72.0,
  '10xlarge' => 80.0,
  '12xlarge' => 96.0,
  '16xlarge' => 128.0,
  '18xlarge' => 144.0,
  '24xlarge' => 192.0,
  '32xlarge' => 256.0,
}

instance_family = ARGV[0] # like m4, t3, etc

ec2 = Aws::EC2::Client.new

instances = ec2.describe_instances(
  filters: [
    {
      name: 'instance-type',
      values: ["#{instance_family}.*"],
    },
    {
      name: 'instance-state-name',
      values: ['running'],
    },
  ],
).flat_map(&:reservations).flat_map(&:instances).select { |i|
  # XXX: Cannot filter by null value in DescribeInstances API
  i.instance_lifecycle.nil?
}

instances.each do |i|
  printf "%-30s | %-30s | %-10s\n", i.instance_id, i.tags.find { |t| t.key == 'Name' }&.value, i.instance_type
end

normalized_total_quantity = instances.reduce(0) do |acc, i|
  instance_size = i.instance_type.match(/^.+\.(.+)$/)[1]
  acc += NORMALIZATION_FACTORS[instance_size]
end

puts "\nTotal instance count: #{instances.count}"
puts "Normalized total count: #{normalized_total_quantity}" 
puts "    as #{instance_family}.small #{normalized_total_quantity / NORMALIZATION_FACTORS['small']}" 
puts "    as #{instance_family}.large #{normalized_total_quantity / NORMALIZATION_FACTORS['large']}" 
