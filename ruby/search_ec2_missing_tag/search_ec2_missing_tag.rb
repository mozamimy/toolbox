#!/usr/bin/env ruby

require 'aws-sdk-ec2'

tag_key = ARGV[0]
ec2 = Aws::EC2::Client.new

results = []

ec2.describe_instances.reservations.each do |reservation|
  results << reservation.instances.select do |instance|
    instance.tags.all? { |tag| tag.key != tag_key }
  end
end

results.flatten!

if results.size < 1
  warn 'No instances.'
  exit 1
end

results = results.sort_by { |r| r.tags.find { |t| t.key == 'Name' }.value }

puts '"Name","Instance ID","Role","Status"'

results.each do |result|
  id = result.instance_id
  name = result.tags.find { |t| t.key == 'Name' }.value
  role = result.tags.find { |t| t.key == 'Role' }&.value
  status = result.state.name
  puts "\"#{name}\",\"#{id}\",\"#{role}\",\"#{status}\""
end
