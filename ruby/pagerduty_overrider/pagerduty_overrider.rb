require 'faraday'
require 'json'
require 'pp'
require 'time'

class PagerDuty
  def initialize(service_key:)
    @conn = Faraday.new(url: 'https://api.pagerduty.com/') do |f|
      f.adapter :net_http
    end
    @request_headers = {
      'Content-Type' => 'application/json',
      'Accept' => 'application/vnd.pagerduty+json;version=2',
      'Authorization' => "Token token=#{service_key}",
    }
  end

  def list_schedules
    resp = @conn.get do |req|
      req.url('/schedules')
      req.headers = @request_headers
    end
    JSON.parse(resp.body)
  end

  def create_override(schedule:, start_time:, end_time:, user:)
    resp = @conn.post do |req|
      req.url("/schedules/#{schedule['id']}/overrides")
      req.headers = @request_headers
      req.body = {
        start: start_time.iso8601,
        end: end_time.iso8601,
        user: {
          id: user['id'],
          type: user['type'],
        },
      }.to_json
    end
    JSON.parse(resp.body)
  end
end

pd = PagerDuty.new(service_key: ENV.fetch('PD_SERVICE_KEY'))

schedules = pd.list_schedules
puts '== Your schedule list'
schedules['schedules'].each_with_index do |schedule, i|
  puts "#{i}: #{schedule['name']} (#{schedule['id']})"
end
print 'Choose schedules (comma separated) > '
input = gets
target_schedules = input.split(',').map(&:strip).reject(&:empty?).map { |s| schedules['schedules'][Integer(s)] }
puts "You choosed schedules #{target_schedules.map { |s| s['name']}.join(', ')}"

target_users_by_schedule = {}
target_schedules.each do |schedule|
  puts "== Users in schedule #{schedule['name']} (#{schedule['name']})"
  users = schedule['users']
  users.each_with_index do |user, i|
    puts "#{i}: #{user['summary']} (#{user['id']})"
  end
  print 'Choose EXCLUDED users (comma separated) > '
  input = gets
  target_users = users - input.split(',').map(&:strip).reject(&:empty?).map { |s| users[Integer(s)] }
  puts "Target users are #{target_users.map { |u| u['summary'] }.join(', ')}"
  target_users_by_schedule[schedule] = target_users
end

# FIX: inefficiency code
loop do
  target_users_by_schedule.each do |_, users|
    users.shuffle!
  end
  is_shuffled_correctry = true
  target_users_by_schedule.each do |schedule, users|
    users.each_with_index do |user, i|
      target_users_by_schedule.each do |compaired_schedule, compaired_users|
        next if schedule == compaired_schedule
        is_shuffled_correctry = false if i < compaired_users.length && user['id'] == compaired_users[i]['id']
      end
    end
  end
  break if is_shuffled_correctry
end

print 'Input start day (e.g. 2018-12-29 09:30 +0900) > '
start_time = Time.parse(gets)
puts "You input is #{start_time} as start day"

print 'Input end day (e.g. 2019-01-03 09:30 +0900) > '
end_time = Time.parse(gets)
puts "You input is #{end_time} as end day"

print 'Input duration (secondes) (e.g. 86400) > '
duration = Integer(gets.strip)
puts "You input is #{duration} as duration"

plan = {}
target_schedules.each do |schedule|
  current_time = start_time
  i = 0
  plan[schedule] = []
  while current_time <= end_time
    oncall_start_time = current_time
    current_time += duration
    oncall_end_time = current_time
    user_index = i % target_users_by_schedule[schedule].length

    plan[schedule] << {
      user: target_users_by_schedule[schedule][user_index],
      oncall_start_time: oncall_start_time,
      oncall_end_time: oncall_end_time,
    }

    i += 1
  end
end

plan.each do |schedule, oncalls|
  puts "== Review a plan for #{schedule['name']}"
  oncalls.each do |oncall|
    puts "#{oncall[:oncall_start_time]} ~ #{oncall[:oncall_end_time]} -> #{oncall[:user]['summary']}"
  end
end

print 'Are you sure to create these overrides? (y|n) > '
if gets.strip == 'y'
  plan.each do |schedule, oncalls|
    oncalls.each do |oncall|
      pd.create_override(
        schedule: schedule,
        start_time: oncall[:oncall_start_time],
        end_time: oncall[:oncall_end_time],
        user: oncall[:user],
      )
    end
  end
  puts 'Created overrides.'
else
  puts 'Aborted.'
end
