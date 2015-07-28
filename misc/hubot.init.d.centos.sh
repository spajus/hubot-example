#!/bin/sh
### BEGIN INIT INFO
# Provides:          hubot
# Required-Start:    $local_fs $remote_fs $network
# Required-Stop:     $local_fs $remote_fs $network
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: hubot init script
# Description:       hubot is a friendly chatbot
### END INIT INFO

# Author: Tomas Varaneckas <tomas.varaneckas@gmail.com>

# Source function library.
. /etc/rc.d/init.d/functions

DESC="Hubot ${NAME} bot"
NAME=hubot
USER=hubot
GROUP=hubot
BOT_PATH=/home/hubot/campfire
PATH=/sbin:/usr/sbin:/bin:/usr/bin:/usr/local/bin:$BOT_PATH/node_modules:$BOT_PATH/node_modules/hubot/node_modules
DAEMON=$BOT_PATH/bin/$NAME
DAEMON_ARGS="--adapter campfire --name hubot"
PIDFILE=$BOT_PATH/$NAME.pid
LOGFILE=$BOT_PATH/$NAME.log
SCRIPTNAME=/etc/init.d/$NAME

# Read configuration variable file if it is present
[ -r $BOT_PATH/hubot.conf ] && . $BOT_PATH/hubot.conf

case "$1" in
  start)
    status="0"
    status -p ${PIDFILE} ${NAME} > /dev/null || status="$?"
    if [ "$status" = 0 ]; then
      status -p ${PIDFILE} ${NAME}
      exit 2
    fi

    touch $PIDFILE && chown $USER:$GROUP $PIDFILE
    if [ "$(whoami)" != "$USER" ]; then
      runuser -c "[ -r $BOT_PATH/hubot.conf ] && . $BOT_PATH/hubot.conf && \
              cd $BOT_PATH && $DAEMON $DAEMON_ARGS" - $USER  >> \
              ${LOGFILE} 2>&1 &
      sleep 2
      PID=`pgrep -u hubot node`
      echo $PID > $PIDFILE
    else
      (cd $BOT_PATH; $DAEMON $DAEMON_ARGS  >> ${LOGFILE} 2>&1 & echo $! > $PIDFILE)
    fi
    status -p ${PIDFILE} ${NAME}
    ;;
  stop)
    killproc -p ${PIDFILE} ${NAME} -INT
    rm -f ${PIDFILE}
    status -p ${PIDFILE} ${NAME}
    ;;
  status)
    status -p ${PIDFILE} ${NAME}
    ;;
  restart)
    $0 stop
    $0 start
    ;;
  *)
    echo "Usage: $0 {start|stop|status|restart}"
    exit 1
    ;;
esac

# vim:ft=sh

