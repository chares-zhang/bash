#!/bin/bash
echo "变更了，这个废弃"
exit
echo "填写task要同步的模块"
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
echo "是否发布到线上，y为是"
read online
if [ "$online" = 'y' ];then
   echo "同步到线上"
else
  echo "不同步到线上"
fi
IPS="hlg54 hlg55 hlg58 hlg59 hlg60 hlg62 hlg63 hlg64 hlg65 hlg67 hlg68 hlg113 hlg16 hlg186 hlg11 hlg110 hlg238 tae117"
com="cd /service/task/app/code/Core;";
if [ "$var" != '' ]; then
BaseDir="/service/dev/hlg/promo"
for arg in $var; do
   if [ "$arg" = "lib" ];then
   	  cd ${BaseDir}/$arg
   	  git checkout dev
	git pull
	 if [ "$online" = "y" ]; then
   	  echo "marge into master"
   	  git checkout master
   	  git pull
   	  git pull . dev
   	  git push
   	  fi
      com=$com"cd ../../../"$arg";echo 'pull "$arg"';git pull;echo 'pull "$arg" done';cd ../app/code/Core;"   
   elif [ "$arg" = "design" ] || [ "$arg" = "cron" ];then
   	  cd ${BaseDir}/app/$arg
   	  git checkout dev
   		git pull 
   		 if [ "$online" = "y" ]; then
	 echo "marge into master"
   	  git checkout master
   	  git pull
   	  git pull . dev
   	  git push
   	  fi
      com=$com"cd ../../"$arg";echo 'pull "$arg"';git pull;echo 'pull "$arg" done';cd ../code/Core;"
   elif [ "$arg" = "js" ] || [ "$arg" = "css" ];then
   	  cd ${BaseDir}/www/$arg
   	  git checkout dev
	git pull
	 if [ "$online" = "y" ]; then
   	  echo "marge into master"
   	  git checkout master
   	  git pull
   	  git pull . dev
   	  git push
   	  fi
      com=$com"cd ../../../www/"$arg";echo 'pull "$arg"';git pull;echo 'pull "$arg" done';cd ../../app/code/Core;"
   elif [ "$arg" = "img" ];then
   	  cd ${BaseDir}/www/$arg
   	  git pull
      com=$com"cd ../../../www/"$arg";echo 'pull "$arg"';git pull;echo 'pull "$arg" done';cd ../../app/code/Core;"
   else
   		cd ${BaseDir}/app/code/$arg
   		git checkout dev
   		git pull
   		 if [ "$online" = "y" ]; then
		echo "marge into master"
	   	git checkout master
	   	git pull
	   	git pull . dev
	   	git push
	   	fi
     	com=$com"cd ../"$arg";echo 'pull "$arg"';git pull;echo 'pull "$arg" done';"
   fi
done;
fi
if [ "$clean" = "y" ]; then
  rm -rf ${BaseDir}/var/cache/*
  com=$com"echo 'clean cache';rm -rf /service/task/var/cache/*;"
fi
com=$com"exit;";
if [ "$online" = "y" ]; then
for ip in $IPS;do 
   echo $ip
   ssh $ip $com &
done;
fi
#sleep 6;
echo "all done.";
exit 0
