# file:/usr/local/nginx/sbin/cut_nginx_log.bash
#!/bin/bash
# set -x
declare -x PATH="/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin"
declare log_names="access.log error.log"
declare logs_path="/data/logs/"
declare pid_file="/usr/local/nginx/nginx.pid"
declare backup_path=${logs_path}nginx_log_backup/

for i in $log_names
do
        mkdir -p ${backup_path}
	mv ${logs_path}$i ${backup_path}$(date -d "yesterday" +"%Y%m%d")_$i
done

kill -USR1 `cat $pid_file`

#删除一个月前的日志
find ${backup_path} -mtime +30 | xargs rm -fr 
