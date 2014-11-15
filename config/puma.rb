#daemonize

workers    1 # should be same number of your CPU core
threads    1, 6

pidfile    "tmp/lanes.pid"
#stdout_redirect 'log/lanes.log', 'log/lanes-error.log', true
