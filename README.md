# AppReporter

It is a CLI tool that summarizes the daily installation numbers and user reviews of an app and posts them to Slack.

## Require

macOS(over 11.0)
Swift 5.9

## Build

```swift
git clone https://github.com/fromkk/AppReporter.git
cd ./AppReporter
swift build -c release
```

## Useage

```sh
.build/arm64-apple-macosx/debug/AppReporter -h
USAGE: arguments <key-id> <issuer-id> <private-key> <app-id> <date> [--vendor-number <vendor-number>] [--time-zone <time-zone>] [--locale <locale>] [--slack-webhook-url <slack-webhook-url>]

ARGUMENTS:
  <key-id>                Key ID
  <issuer-id>             Issuer ID
  <private-key>           Path for private key *.p8
  <app-id>                App ID
  <date>                  Date(YYYY-MM-DD)

OPTIONS:
  -v, --vendor-number <vendor-number>
                          Vendor Number
  -t, --time-zone <time-zone>
                          TimeZone(ex. Asia/Tokyo)
  -l, --locale <locale>   Locale(ex. ja_JP)
  -s, --slack-webhook-url <slack-webhook-url>
                          Slack Webhook URL
  -h, --help              Show help information.
```
