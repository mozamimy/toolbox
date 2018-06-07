# redis_ttl_setter

## Example to use

```
#                                       master url, slave url, pattern, ttl, batch size, log level
$ bundle exec ruby redis_ttl_setter.rb 'redis://127.0.0.1:6379/0' 'redis://127.0.0.1:6380/0' '*' 172800 100000 info
```

## Test this script on local environment

```
$ docker-compose -d
$ bundle exec ruby seed.rb 'redis://127.0.0.1:16379/0'
$ bundle exec ruby restore.rb 'redis://127.0.0.1:6379/0' ~/tmp/redis.dump 8 info
```
