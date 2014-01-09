#! /bin/sh
### BEGIN INIT INFO
# Provides:          hubot
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Hubot stat / stop script
# Description:       Manages starting and stopping of Hubot node bot
### END INIT INFO

# Author: Tomas Varaneckas <tomas.varaneckas@gmail.com>

# Do NOT "set -e"

# PATH should only include /usr/* if it runs after the mountnfs.sh script
DESC="Hubot node bot"
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
INIT_VERBOSE=yes

# Read configuration variable file if it is present
[ -r $BOT_PATH/hubot.conf ] && . $BOT_PATH/hubot.conf

# Load the VERBOSE setting and other rcS variables
. /lib/init/vars.sh

# Define LSB log_* functions.
# Depend on lsb-base (>= 3.2-14) to ensure that this file is present
# and status_of_proc is working.
. /lib/lsb/init-functions

do_start()
{
  status="0"
  pidofproc -p $PIDFILE node >/dev/null || status="$?"
  [ "$status" = 0 ] && return 2;

  touch $PIDFILE && chown $USER:$GROUP $PIDFILE

	start-stop-daemon --no-close --user $USER --quiet --start --pidfile $PIDFILE -c $USER:$GROUP \
	  --make-pidfile \
	  --background --chdir $BOT_PATH --exec $DAEMON -- \
		$DAEMON_ARGS >> $LOGFILE 2>&1 \
		||  return 2
}

do_stop()
{
  status="0"
  pidofproc -p $PIDFILE node >/dev/null || status="$?"
  [ "$status" = 3 ] && return 1

	start-stop-daemon --stop --quiet --pidfile $PIDFILE
	RETVAL="$?"
	[ "$RETVAL" = 2 ] && return 2
	rm -f $PIDFILE
	return "$RETVAL"
}

case "$1" in
  start)
	[ "$VERBOSE" != no ] && log_daemon_msg "Starting $DESC" "$NAME"
	do_start
	case "$?" in
		0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
		2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
	esac
	;;
  stop)
	[ "$VERBOSE" != no ] && log_daemon_msg "Stopping $DESC" "$NAME"
	do_stop
	case "$?" in
		0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
		2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
	esac
	;;
  status)
	status_of_proc -p $PIDFILE node $NAME && exit 0 || exit $?
	;;
  restart|force-reload)
	log_daemon_msg "Restarting $DESC" "$NAME"
	do_stop
	case "$?" in
	  0|1)
		do_start
		case "$?" in
			0) log_end_msg 0 ;;
			1) log_end_msg 1 ;; # Old process is still running
			*) log_end_msg 1 ;; # Failed to start
		esac
		;;
	  *)
		# Failed to stop
		log_end_msg 1
		;;
	esac
	;;
  *)
	echo "Usage: $SCRIPTNAME {start|stop|status|restart|force-reload}" >&2
	exit 3
	;;
esac

:
