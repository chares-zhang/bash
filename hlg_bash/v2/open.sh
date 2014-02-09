#!/bin/bash
echo "填写open要同步的模块"
read var
echo $var
echo "是否清除缓存,y清除，其余否"
read clean
if [ "$clean" != 'y' ];then
   echo "不用清除缓存"
   if [ "$var" = '' ];then
   		echo "没模块"
   		exit
	fi
else
  echo "清除缓存"
fi
IPS="hlg28"
com="cd /service/open/app/code/Core;";
if [ "$var" != '' ]; then
for arg in $var; do
   if [ "$arg" = "lib" ];then
      com=$com"cd ../../../"$arg";echo 'pull "$arg"';git pull;echo 'pull "$arg" done';cd ../app/code/Core;"   
   elif [ "$arg" = "design" ];then
      com=$com"cd ../../"$arg";echo 'pull "$arg"';git pull;echo 'pull "$arg" done';cd ../code/Core;"
   elif [ "$arg" = "js" ];then
      com=$com"cd ../../../www/"$arg";echo 'pull "$arg"';git pull;echo 'pull "$arg" done';cd ../../app/code/Core;"
   elif [ "$arg" = "css" ];then
      com=$com"cd ../../../www/"$arg";echo 'pull "$arg"';git pull;echo 'pull "$arg" done';cd ../../app/code/Core;"
   elif [ "$arg" = "img" ];then
      com=$com"cd ../../../www/"$arg";echo 'pull "$arg"';git pull;echo 'pull "$arg" done';cd ../../app/code/Core;"
   else
     	com=$com"cd ../;";
   		if [ -d $arg ] ;then
   			com=$com"cd "$arg";echo 'pull "$arg"';git pull;echo 'pull "$arg" done';"
   		else
   			com=$com"echo 'clone "$arg"';git clone git@hlg28:"$arg".git;cd "$arg";echo 'pull "$arg" done';"
   		fi
     	#com=$com"cd ../"$arg";echo 'pull "$arg"';git pull;echo 'pull "$arg" done';"
   fi
done;
fi
if [ "$clean" = "y" ]; then
  com=$com"echo 'clean cache';rm -rf /service/open/var/cache/*;"
fi
com=$com"exit;";
for ip in $IPS;do 
   echo $ip
   ssh $ip $com &
done;
#sleep 6;
echo "all done.";
exit 
