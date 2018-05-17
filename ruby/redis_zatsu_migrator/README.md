# redis_zatsu_migrator

## Example to dump

```
$ bundle exec ruby dump.rb 'redis://127.0.0.1:6379/0' 'pypicloud*' ~/tmp/redis.dump 8 info
```

## Example to restore

```
$ bundle exec ruby restore.rb 'redis://127.0.0.1:6379/0' ~/tmp/redis.dump 8 info
```
