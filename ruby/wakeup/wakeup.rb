require_relative './auth'

service = Auth.generate_service

result = service.list_user_messages(
  'me',
  q: 'label:Waker is:unread',
)

unless result.messages.nil?
  system '/opt/brew/bin/mpv --no-video ring.mkv'
end
