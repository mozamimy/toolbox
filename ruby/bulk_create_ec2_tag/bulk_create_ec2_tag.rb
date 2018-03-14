#!/usr/bin/env ruby

require 'aws-sdk-ec2'

tag_key = ARGV[0]
attach_value = ARGV[1]
name_prefix = ARGV[2]
ec2 = Aws::EC2::Client.new

no_tags_instances = []

ec2.describe_instances.reservations.each do |reservation|
  no_tags_instances << reservation.instances.select do |instance|
    instance.tags.all? { |tag| tag.key != tag_key }
  end
end

no_tags_instances.flatten!
no_tags_instances = no_tags_instances.select do |instance|
  name = instance.tags.find { |t| t.key == 'Name' }&.value
  name.start_with?(name_prefix)
end
no_tags_instance_ids = no_tags_instances.map(&:instance_id)

if no_tags_instance_ids.size < 1
  warn 'No instances.'
  exit 1
end

pp no_tags_instance_ids

resp = ec2.create_tags({
  dry_run: ENV['DRY_RUN'] ? true : false,
  resources: no_tags_instance_ids,
  tags: [
    {
      key: 'Project',
      value: attach_value,
    }
  ],
})

pp resp
