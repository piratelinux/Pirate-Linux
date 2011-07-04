#
# Regular cron jobs for the piratepack package
#
0 4	* * *	root	[ -x /usr/bin/piratepack_maintenance ] && /usr/bin/piratepack_maintenance
