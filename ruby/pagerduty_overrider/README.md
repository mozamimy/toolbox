# pagerduty_overrider

## つかいかた

```bash
bundle install
read -s PD_SERVICE_KEY
# PagerDuty の API キーをコピペ
export PD_SERVICE_KEY
bundle exec ruby pagerduty_overrider.rb
```

1. override を設定したいスケジュールを選択する
2. 振り分けから **除外する** ユーザを選択する
3. 開始日、終了日、交代するまでの時間を設定する
4. オンコールのプランが出てくるので、よさそうなら適用する
