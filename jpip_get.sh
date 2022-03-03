#!/bin/sh

CRONDIR="/home/hogehoge/hogehoge.domain/public_html/cron"

DESTDIR="/home/hogehoge/hogehoge.domain/public_html/"

/bin/php $CRONDIR/get_ip.php > $CRONDIR/.htaccess.new

SIZE=`ls -l $CRONDIR/.htaccess.new | awk '{ print $5 }'`

if [ -e $CRONDIR/.htaccess.new ] && [ $SIZE -gt 50000 ]; then

rm $CRONDIR/.htaccess.old
mv $CRONDIR/.htaccess $CRONDIR/.htaccess.old
mv $CRONDIR/.htaccess.new $CRONDIR/.htaccess

\cp -f $CRONDIR/.htaccess $DESTDIR/.htaccess

fi
