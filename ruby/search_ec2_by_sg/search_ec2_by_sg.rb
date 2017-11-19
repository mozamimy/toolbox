#!/usr/bin/env ruby

require 'aws-sdk-ec2'
require 'pp'

filter = Regexp.new(ARGV[0] ? ARGV[0] : '.*')
ec2 = Aws::EC2::Client.new

results = []

ec2.describe_instances.reservations.each do |reservation|
  results << reservation.instances.select do |instance|
    instance.security_groups.any? { |s| s.group_name =~ filter }
  end
end

results.flatten!

if results.size < 1
  warn "No instances searched by #{filter}"
  exit 1
end

results.each do |result|
  instance_id = result.instance_id
  instance_name = result.tags.find { |t| t.key == 'Name' }.value
  puts "\"#{instance_name}\", \"#{instance_id}\""
end
