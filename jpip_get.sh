#!/bin/sh

/bin/php /home/hogehoge/hogehoge.domain/public_html/cron/get_ip.php > /home/hogehoge/hogehoge.domain/public_html/cron/.htaccess.new

SIZE=`ls -l /home/hogehoge/hogehoge.domain/public_html/cron/.htaccess.new | awk '{ print $5 }'`

if [ -e /home/hogehoge/hogehoge.domain/public_html/cron/.htaccess.new ] && [ $SIZE -gt 50000 ]; then

rm /home/hogehoge/hogehoge.domain/public_html/cron/.htaccess.old
mv /home/hogehoge/hogehoge.domain/public_html/cron/.htaccess /home/hogehoge/hogehoge.domain/public_html/cron/.htaccess.old
mv /home/hogehoge/hogehoge.domain/public_html/cron/.htaccess.new /home/hogehoge/hogehoge.domain/public_html/cron/.htaccess

\cp -f /home/hogehoge/hogehoge.domain/public_html/cron/.htaccess /home/hogehoge/hogehoge.domain/public_html/.htaccess

fi