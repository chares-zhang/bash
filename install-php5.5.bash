#!/bin/bash
# linux lnmp安装脚本centos5.8 php版本:php-5.5.18 mysql版本:5.5.18
# script name: install.bash
# version: 1.0

softpath=/usr/local/src
outip=`ifconfig eth0 | grep 'inet addr' | cut -d: -f2 | cut -d' ' -f1`
inip=`ifconfig eth0 | grep 'inet addr' | cut -d: -f2 | cut -d' ' -f1`
#innodb_buffer_pool_size='512M'

function wgetsoft()
{
	url="
	http://php.net/get/php-5.5.18.tar.gz/from/this/mirror
	http://blog.s135.com/soft/linux/nginx_php/libiconv/libiconv-1.13.1.tar.gz
	http://blog.s135.com/soft/linux/nginx_php/mcrypt/libmcrypt-2.5.8.tar.gz
	http://blog.s135.com/soft/linux/nginx_php/mcrypt/mcrypt-2.6.8.tar.gz
	http://blog.s135.com/soft/linux/nginx_php/memcache/memcache-2.2.5.tgz
	http://blog.s135.com/soft/linux/nginx_php/mhash/mhash-0.9.9.9.tar.gz
	http://blog.s135.com/soft/linux/nginx_php/pcre/pcre-8.10.tar.gz
	http://blog.s135.com/soft/linux/nginx_php/eaccelerator/eaccelerator-0.9.6.1.tar.bz2
	http://blog.s135.com/soft/linux/nginx_php/pdo/PDO_MYSQL-1.0.2.tgz
	http://blog.s135.com/soft/linux/nginx_php/imagick/ImageMagick.tar.gz
	http://blog.s135.com/soft/linux/nginx_php/imagick/imagick-2.3.0.tgz 
	http://pecl.php.net/get/imagick-3.1.0RC2.tgz
	http://monkey.org/~provos/libevent-1.4.14b-stable.tar.gz
	http://memcached.googlecode.com/files/memcached-1.4.13.tar.gz
	http://www.nginx.org/download/nginx-1.6.1.tar.gz
	http://dev.mysql.com/get/Downloads/MySQL-5.5/mysql-5.5.41-linux2.6-x86_64.tar.gz
	http://launchpadlibrarian.net/75887410/libmemcached-0.51.tar.gz
	http://pecl.php.net/get/memcached-1.0.2.tgz
	http://pecl.php.net/get/memcached-2.2.0.tgz
	"
	for i in $url
	do
		if wget $i -P $softpath; then
			:
		else
			return 1
		fi
	done
	return 0
}

function yumsoft()
{
	yum -y install gcc gcc-c++ autoconf libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2c libxml2-devel zlib zlib-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel libidn libidn-devel openssl openssl-devel openldap openldap-devel nss_ldap openldap-clients openldap-servers libevent ImageMagick ImageMagick-devel libevent-devel libxslt-devel
	if [ $? -eq 0 ]; then
	  return 0
	else
	  return 1
	fi
}

function libiconv()
{
	cd $softpath
	tar zxf libiconv-1.13.1.tar.gz
	cd libiconv-1.13.1
	if ./configure --prefix=/usr/local; then
	  if make && make install; then
		   return 0
	  else
		   return 1
	  fi
	else
	  return 1
	fi    
}

function libmcrypt()
{
	cd $softpath
	tar zxf libmcrypt-2.5.8.tar.gz
	cd libmcrypt-2.5.8/
	if ./configure; then
		if make && make install; then
			/sbin/ldconfig
		else
			return 1
		fi
		cd libltdl/
		if ./configure --enable-ltdl-install; then
			if make && make install; then
				return 0
			else
				return 1
			fi
		else
			return 1
		fi
	else
		return 1
	fi
}


function mhash()
{
	cd $softpath
	tar zxf mhash-0.9.9.9.tar.gz
	cd mhash-0.9.9.9/
	if ./configure; then
		if make && make install; then
			return 0
		else
			return 1
		fi
	else
		return 1
	fi
}

function lnlib()
{
	src=/usr/local/lib
	dest=/usr/lib

	for i in `ls $src | egrep "libmcrypt.|libmhash.|libmcrypt-config"`
	do
		ln -s $src/$i $dest/$i
		if $? -ne 0; then
			return 1
		fi
	done

	ln -s /lib64/libldap-2.4.so.2.5.6 /usr/lib/libldap.so
	return 0
}

function mcrypt()
{
	cd $softpath
	tar zxf mcrypt-2.6.8.tar.gz
	cd mcrypt-2.6.8/
	if /sbin/ldconfig; then
		if ./configure; then
			if make && make install; then
				return 0
			else
				return 1
			fi
		else
			return 1
		fi
	else
		return 1
	fi
}

function installmysql()
{
if grep 'mysql' /etc/passwd; then
     :
else
     useradd -r mysql -M -s /sbin/nologin
fi

cd $softpath
tar zxvf mysql-5.5.41-linux2.6-x86_64.tar.gz
if mv mysql-5.5.41-linux2.6-x86_64 /usr/local/mysql; then
     if chown -R mysql:mysql /usr/local/mysql; then
          :
     else
          return 1
     fi
else
     return 1
fi
if mkdir -p /data/mysql/{data,binlog,relaylog,ib_logfile} && chown -R mysql:mysql /data/mysql; then
     /usr/local/mysql/scripts/mysql_install_db --basedir=/usr/local/mysql --datadir=/data/mysql/data --user=mysql
     if [ $? -ne 0 ]; then
          return 1
     fi
else
     return 1
fi
if [ -f /etc/my.cnf ];then
     mv /etc/my.cnf /etc/my.cnf.backup
fi
cat >/etc/my.cnf <<Mayday
[client]
# default-character-set = utf8
port    = 3306
socket  = /tmp/mysql.sock

[mysqld]
# bind-address = $inip
character-set-server = utf8
# binlog-do-db = cafe_tg
binlog-ignore_db = mysql,information_schema,test
replicate-ignore-db = mysql
replicate-ignore-db = test
replicate-ignore-db = information_schema
user    = mysql
port    = 3306
socket  = /tmp/mysql.sock
basedir = /usr/local/mysql
datadir = /data/mysql/data
log-warnings
log-error = /data/mysql/error.log
pid-file = /data/mysql/mysql.pid
open_files_limit    = 10240
back_log = 600
max_connections = 200
max_connect_errors = 1000
table_cache = 1200
external-locking = FALSE
max_allowed_packet = 32M
sort_buffer_size = 1M
join_buffer_size = 1M
thread_cache_size = 300
thread_concurrency = 8
query_cache_size = 256M
query_cache_limit = 256M
query_cache_min_res_unit = 2k
default-storage-engine = InnoDB
thread_stack = 192K
transaction_isolation = READ-COMMITTED
#tmp_table_size = 246M
#max_heap_table_size = 246M
tmp_table_size = 512M
max_heap_table_size = 512M
log-slave-updates
log-bin = /data/mysql/binlog/binlog
#sync_binlog = 1
binlog_cache_size = 2M
#binlog_format = STATEMENT
binlog_format = MIXED
max_binlog_cache_size = 64M
max_binlog_size = 1G
relay-log-index = /data/mysql/relaylog/relaylog
relay-log-info-file = /data/mysql/relaylog/relaylog
relay-log = /data/mysql/relaylog/relaylog
expire_logs_days = 7
#Noting that "key_buffer_size" is a MyISAM parameter
#key_buffer_size = 2048M
read_buffer_size = 1M
read_rnd_buffer_size = 16M
bulk_insert_buffer_size = 64M
#myisam_sort_buffer_size = 128M
#myisam_max_sort_file_size = 10G
#myisam_repair_threads = 1
#myisam_recover

interactive_timeout = 30
wait_timeout = 30

skip-name-resolve
#master-connect-retry = 10
slave-skip-errors = 1032,1062,126,1114,1146,1048,1396

#master-host     =  192.168.2.236
#master-user     =  slave248
#master-password =  slave951623
#master-port     =  3306

server-id = 1

#独立表空间
innodb_file_per_table = 1
innodb_additional_mem_pool_size = 512M
innodb_buffer_pool_size = 512M
innodb_data_file_path = ibdata1:2048M:autoextend
innodb_file_io_threads = 8
innodb_thread_concurrency = 8
#http://dev.mysql.com/doc/refman/5.0/en/innodb-parameters.html#sysvar_innodb_flush_log_at_trx_commit
innodb_flush_log_at_trx_commit = 2
innodb_log_buffer_size = 32M
innodb_log_group_home_dir = /data/mysql/ib_logfile
innodb_log_file_size = 512M
innodb_log_files_in_group = 2
innodb_max_dirty_pages_pct = 90
innodb_lock_wait_timeout = 30

slow-query-log = 1
long_query_time = 1
slow-query-log-file = /data/mysql/slow.log
#log-queries-not-using-indexes

[mysqldump]
default-character-set = utf8
port    = 3306
socket  = /tmp/mysql.sock
quick
max_allowed_packet = 512M
Mayday
if [ $? -ne 0 ]; then
     return 0
fi
if cp /usr/local/mysql/support-files/mysql.server /etc/rc.d/init.d/mysqld; then
     if chkconfig --add mysqld && chkconfig mysqld off && echo "/usr/local/mysql/lib" >> /etc/ld.so.conf.d/mysql.conf && /sbin/ldconfig; then
          return 0
     else
          return 1
     fi
else
     return 1
fi
}

function installphp()
{
cp -frp /usr/lib64/libldap* /usr/lib/
cd $softpath
tar zxvf php-5.5.18.tar.gz
if [ $? -ne 0 ]; then
     return 1
fi
cd php-5.5.18/
./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --with-mysql=/usr/local/mysql --with-mysqli=/usr/local/mysql/bin/mysql_config --with-iconv-dir=/usr/local --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-safe-mode --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl --with-curlwrappers --enable-mbregex --enable-fpm --with-fpm-user=nobody --with-fpm-group=nobody --enable-mbstring --with-mcrypt --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-ldap --with-ldap-sasl --with-xmlrpc --enable-zip --enable-soap --with-xsl
if [ $? -eq 0 ]; then
     make ZEND_EXTRA_LIBS='-liconv' && make install
     if [ $? -ne 0 ]; then
          return 1
     fi
else
     return 1
fi
if [ -f /etc/php.ini ]; then
     mv /etc/php.ini /etc/php.ini.backup
fi
if cp php.ini-production /usr/local/php/etc/php.ini; then
     return 0
else
     return 1
fi
}    

function libevent()
{
cd $softpath
tar zxvf libevent-1.4.14b-stable.tar.gz
cd libevent-1.4.14b-stable
if ./configure --prefix=/usr/local/libevent; then
     if make && make install && rm -f /usr/lib64/libevent-1.4.so.2 && ln -s /usr/local/libevent/lib/libevent-1.4.so.2 /usr/lib64/libevent-1.4.so.2; then
          return 0
     else
          return 1
     fi
else
     return 1
fi
}

function memcached()
{
cd $softpath
tar zxvf memcached-1.4.13.tar.gz
cd memcached-1.4.13
if ./configure --prefix=/usr/local/memcached; then
     if make && make install; then
          return 0
     else
          return 1
     fi
else
     return 1
fi
}

function memcache()
{
cd $softpath
tar zxvf memcache-2.2.5.tgz
cd memcache-2.2.5/
if /usr/local/php/bin/phpize; then
     ./configure  --with-php-config=/usr/local/php/bin/php-config
     if [ $? -eq 0 ]; then
          if make && make install; then
               return 0
          else
               return 1
          fi
     else
          return 1
     fi
else
     return 1
fi
}

function eaccelerator()
{
cd $softpath
tar jxvf eaccelerator-0.9.6.1.tar.bz2
cd eaccelerator-0.9.6.1/
if /usr/local/php/bin/phpize; then
     ./configure --enable-eaccelerator=shared --with-php-config=/usr/local/php/bin/php-config
     if [ $? -eq 0 ]; then
          if make && make install; then
               return 0
          else
               return 1
          fi
     else
          return 1
     fi
else
     return 1
fi
}

function PDO_MYSQL()
{
cd $softpath/php-5.5.18/ext/pdo_mysql
if /usr/local/php/bin/phpize; then
     ./configure --with-php-config=/usr/local/php/bin/php-config --with-pdo-mysql=/usr/local/mysql
     if [ $? -eq 0 ]; then
          if make && make install; then
               return 0
          else
               return 1
          fi
     else
          return 1
     fi
     return 1
fi
}

function ImageMagick()
{
cd $softpath
tar zxvf ImageMagick.tar.gz
cd ImageMagick-6.5.1-2/
if ./configure; then
     if make && make install; then
          return 0
     else
          return 1
     fi
else
     return 1
fi
}

function imagick()
{
cd $softpath
tar zxvf imagick-3.1.0RC2.tgz
cd imagick-3.1.0RC2/
if /usr/local/php/bin/phpize; then
     ./configure --with-php-config=/usr/local/php/bin/php-config
     if [ $? -eq 0 ]; then
          if make && make install; then
               return 0
          else
               return 1
          fi
     else
          return 1
     fi
else
     return 1
fi    
}

function installlibmemcached()
{
cd $softpath
tar zxvf libmemcached-0.51.tar.gz
cd libmemcached-0.51
if ./configure --prefix=/usr/local/libmemcached --with-memcached=/usr/local/memcached/bin/memcached; then
    if make && make install; then
        return 0;
    else
        return 1;
    fi
else
    return 1;
fi
}

function installmemcached()
{
cd $softpath
tar zxvf memcached-2.2.0.tgz
cd memcached-2.2.0
if /usr/local/php/bin/phpize; then
   if ./configure --prefix=/usr/local/libmemcached --with-php-config=/usr/local/php/bin/php-config --with-libmemcached-dir=/usr/local/libmemcached; then
       if make && make install; then
            return 0
        else
            return 1
        fi
    else
        return 1
    fi
else
    return 1
fi
}

function sedphpini()
{
sed -i 's#extension_dir = "./"#/usr/local/php/lib/php/extensions/no-debug-non-zts-20121212/"\nextension = "memcache.so"\nextension = "pdo_mysql.so"\nextension = "imagick.so"\nextension = "memcached.so"\n#' /usr/local/php/etc/php.ini && sed -i 's#output_buffering = Off#output_buffering = On#' /usr/local/php/etc/php.ini && sed -i "s#;always_populate_raw_post_data = On#always_populate_raw_post_data = On#g" /usr/local/php/etc/php.ini && sed -i "s#;cgi.fix_pathinfo=0#cgi.fix_pathinfo=0#g" /usr/local/php/etc/php.ini
if [ $? -eq 0 ]; then
     return 0
else
     return 1
fi
}

function configeaccelerator()
{
mkdir -p /usr/local/eaccelerator_cache && chown -R nobody:nobody /usr/local/eaccelerator_cache && chmod -R 0777 /usr/local/eaccelerator_cache
cat >>/usr/local/php/etc/php.ini <<Mayday

[eaccelerator]
zend_extension="/usr/local/php/lib/php/extensions/no-debug-non-zts-20121212/eaccelerator.so"
eaccelerator.shm_size="64"
eaccelerator.cache_dir="/usr/local/eaccelerator_cache"
eaccelerator.enable="1"
eaccelerator.optimizer="1"
eaccelerator.check_mtime="1"
eaccelerator.debug="0"
eaccelerator.filter=""
eaccelerator.shm_max="0"
eaccelerator.shm_ttl="3600"
eaccelerator.shm_prune_period="3600"
eaccelerator.shm_only="0"
eaccelerator.compress="1"
eaccelerator.compress_level="9"
Mayday

if [ $? -eq 0 ]; then
     return 0
else
     return 1
fi
}

function addwww()
{
if [ -d /data/www ]; then
     :
else
     mkdir -p /data/www/
fi
if chmod +w /data/www/ && chown -R nobody:nobody /data/www/; then
     return 0
else
     return 1
fi
}

function pcre()
{
cd $softpath
tar zxvf pcre-8.10.tar.gz
cd pcre-8.10/
if ./configure; then
     if make && make install; then
          return 0
     else
          return 1
     fi
else
     return 1
fi
}

function nginx()
{
cd $softpath
tar zxvf nginx-1.6.1.tar.gz
cd nginx-1.6.1/
./configure --user=nobody --group=nobody --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_ssl_module
if [ $? -eq 0 ]; then
     if make && make install; then
          return 0
     else
          return 1
     fi
else
     return 1
fi
}

function mkdirdata()
{
if [ -d /data/logs ]; then
     :
else
     mkdir -p /data/logs
fi

if chmod +w /data/logs && chown -R nobody:nobody /data/logs; then
     return 0
else
     return 1
fi
}

function configfcgi()
{
     cat >/usr/local/nginx/conf/fcgi.conf <<Mayday
fastcgi_param  GATEWAY_INTERFACE  CGI/1.1;
fastcgi_param  SERVER_SOFTWARE    nginx;

fastcgi_param  QUERY_STRING       \$query_string;
fastcgi_param  REQUEST_METHOD     \$request_method;
fastcgi_param  CONTENT_TYPE       \$content_type;
fastcgi_param  CONTENT_LENGTH     \$content_length;

fastcgi_param  SCRIPT_FILENAME    \$document_root\$fastcgi_script_name;
fastcgi_param  SCRIPT_NAME        \$fastcgi_script_name;
fastcgi_param  REQUEST_URI        \$request_uri;
fastcgi_param  DOCUMENT_URI       \$document_uri;
fastcgi_param  DOCUMENT_ROOT      \$document_root;
fastcgi_param  SERVER_PROTOCOL    \$server_protocol;

fastcgi_param  REMOTE_ADDR        \$remote_addr;
fastcgi_param  REMOTE_PORT        \$remote_port;
fastcgi_param  SERVER_ADDR        \$server_addr;
fastcgi_param  SERVER_PORT        \$server_port;
fastcgi_param  SERVER_NAME        \$server_name;

# PHP only, required if PHP was built with --enable-force-cgi-redirect
fastcgi_param  REDIRECT_STATUS    200;
Mayday
if [ $? -eq 0 ]; then
     return 0
else
     return 1
fi
}

function confignginx()
{
cat >/usr/local/nginx/conf/nginx.conf.new <<MayDay
user  nobody nobody;

worker_processes 8;

error_log  /data/logs/nginx_error.log  crit;

pid        /usr/local/nginx/nginx.pid;

worker_rlimit_nofile 65535;

events
{
  use epoll;
  worker_connections 65535;
}

http
{
  include       mime.types;
  default_type  application/octet-stream;

  #charset  gb2312;
     
  server_names_hash_bucket_size 128;
  client_header_buffer_size 32k;
  large_client_header_buffers 4 32k;
  client_max_body_size 8m;
     
  sendfile on;
  tcp_nopush     on;

  keepalive_timeout 0;

  tcp_nodelay on;

  fastcgi_connect_timeout 300;
  fastcgi_send_timeout 300;
  fastcgi_read_timeout 300;
  fastcgi_buffer_size 64k;
  fastcgi_buffers 4 64k;
  fastcgi_busy_buffers_size 128k;
  fastcgi_temp_file_write_size 128k;

  gzip on;
  gzip_min_length  1k;
  gzip_buffers     4 16k;
  gzip_http_version 1.0;
  gzip_comp_level 2;
  gzip_types       text/plain application/x-javascript text/css text/xml application/xml;
  gzip_vary on;

  #limit_zone  crawler  \$binary_remote_addr  10m;
  server_tokens off;

  server
  {
    listen  80;
    server_name  $outip;

    location /nginx_status {
    stub_status on;
    access_log  off;
    }
  }

  server
  {
    listen       80;
    server_name  dynamic.dapaidangth.snsplus.com;
    index index.html index.htm index.php;
    root  /data/www/cafe_tg;

    location ~ .*\.(php|php5)?\$
    {     
      # fastcgi_pass  unix:/tmp/php-cgi.sock;
      fastcgi_pass  $inip:9000;
      fastcgi_index index.php;
      include fcgi.conf;
    }

    location ~ .*\.(gif|jpg|jpeg|png|bmp|swf)\$
    {
      expires      30d;
       access_log   off;
    }

    location ~ .*\.(js|css)?\$
    {
      expires      1h;
       access_log   off;
    }   

    log_format  cafe_tg  '\$remote_addr - \$remote_user [\$time_local] [\$request_time] "\$request"'
              '\$status \$body_bytes_sent "\$http_referer"'
              '"\$http_user_agent" \$http_x_forwarded_for';
    access_log  /data/logs/cafe_tg.log  cafe_tg;
  }

}
MayDay
if [ $? -eq 0 ]; then
     :
else
     return 1
fi

if ulimit -SHn 65535 && /usr/local/nginx/sbin/nginx; then
     cp /etc/rc.d/rc.local /etc/rc.d/rc.local.backup
     cat >>/etc/rc.d/rc.local <<Mayday
ulimit -SHn 65535 && /usr/local/php/sbin/php-fpm start
ulimit -SHn 65535 && /usr/local/nginx/sbin/nginx
Mayday
     if [ $? -eq 0 ]; then
          return 0
     else
          return 1
     fi
else
     return 1
fi
}

function cut_nginx_log()
{
if [ -f /usr/local/nginx/sbin/cut_nginx_log.sh ]; then
     mv /usr/local/nginx/sbin/cut_nginx_log.sh /usr/local/nginx/sbin/cut_nginx_log.sh.backup
fi
cat >>/usr/local/nginx/sbin/cut_nginx_log.bash <<Mayday
#!/bin/bash
# set -x
declare -x PATH="/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin"
declare log_names="test.log"
declare logs_path="/data/logs/"
declare pid_file="/usr/local/nginx/nginx.pid"

for i in \$log_names
do
        mkdir -p \${logs_path}\$(date -d "yesterday" +"%Y")/\$(date -d "yesterday" +"%m")/
        mv \${logs_path}\$i \${logs_path}\$(date -d "yesterday" +"%Y")/\$(date -d "yesterday" +"%m")/\$(date -d "yesterday" +"%Y%m%d")_\$i
done

kill -USR1 \`cat \$pid_file\`
Mayday
if [ $? -eq 0 ]; then
     chmod u+x /usr/local/nginx/sbin/cut_nginx_log.bash
else
     return 1
fi
if [ $? -eq 0 ]; then
     cat >>/var/spool/cron/root <<Mayday
00 00 * * * /bin/bash  /usr/local/nginx/sbin/cut_nginx_log.bash >/tmp/cut_nginx_log.log 2>&1
Mayday
     if [ $? -eq 0 ]; then
          return 0
     else
          return 1
     fi
else
     return 1
fi
}

function redis()
{
cd /usr/local/src
tar zxvf redis-1.2.6.tar.gz
cd redis-1.2.6
if make; then
     if cp redis-benchmark redis-cli redis-server /usr/bin; then
          return 0
     else
          return 1
     fi
else
     return 1
fi
}

function addphpfpmservice()
{
     cp /usr/local/src/php-5.5.18/sapi/fpm/init.d.php-fpm /etc/rc.d/init.d/php-fpm
     chmod 0755 /etc/rc.d/init.d/php-fpm
     chown root:root /etc/rc.d/init.d/php-fpm
     chkconfig --add php-fpm
     chkconfig php-fpm on
}

# by zcx
function phpfpmconfig()
{
    #listen.allowed_clients
    #listen = 192.168.1.2:9000
    #pm.max_children = 64
    service php-fpm start
}

function path()
{
cat >>/root/.bashrc <<Mayday

# add by zcx
PATH=/usr/local/nginx/sbin:/usr/local/mysql/bin:/usr/local/mysql/bin:/usr/local/php/bin:/usr/local/php/sbin:\$PATH
Mayday
if [ $? -eq 0 ]; then
    return 0
else
    return 1
fi
}

# yumsoft libiconv libmcrypt mhash lnlib mcrypt installmysql installphp libevent memcached installlibmemcached installmemcached memcache eaccelerator PDO_MYSQL imagick sedphpini configeaccelerator addwww pcre nginx mkdirdata configfcgi confignginx cut_nginx_log addphpfpmservice
# for i in installphp libevent memcached installlibmemcached installmemcached memcache PDO_MYSQL imagick sedphpini addwww pcre nginx mkdirdata configfcgi confignginx cut_nginx_log addphpfpmservice path
# for i in installlibmemcached installmemcached memcache PDO_MYSQL imagick sedphpini addwww pcre nginx mkdirdata configfcgi confignginx cut_nginx_log addphpfpmservice path
 for i in installlibmemcached installmemcached memcache PDO_MYSQL imagick sedphpini addwww pcre nginx mkdirdata configfcgi confignginx cut_nginx_log addphpfpmservice path
do
     if $i; then
          echo -e "\n$i success\n"
     else
          echo -e "\n$i failed\n"
          exit 1
     fi
done

