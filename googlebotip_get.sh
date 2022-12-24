#!/bin/sh

CRONDIR="/home/hogehoge/hogehoge.domain/public_html/cron"

curl -s https://developers.google.com/search/apis/ipranges/googlebot.json | jq -r '.prefixes[] | if .ipv4Prefix != null then .ipv4Prefix else .ipv6Prefix end' | sed -e 's/^/Require ip /' > $CRONDIR/googlebot_ip.txt