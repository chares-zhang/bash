#!/bin/bash
echo "填写api要同步的模块"
read var
echo $var
echo "是否发布到线上，y为是"
read online
if [ "$online" = 'y' ];then
   echo "同步到线上"
else
  echo "不同步到线上"
fi
IPS="hlg54 hlg55 hlg58 hlg59 hlg60 hlg61 hlg62 hlg63 hlg64 hlg65 hlg67 hlg68 hlg113 hlg16 hlg186 hlg11 hlg110 hlg238 hlg121119 hlg121181 hlg121238 hlg121239 hlg121249"
com="cd /service/api;";
if [ "$var" != '' ]; then
BaseDir="/service/dev/hlg/api"
for arg in $var; do
   		cd ${BaseDir}/$arg
   		git checkout dev
   		git pull
   		 if [ "$online" = "y" ]; then
			echo "marge into master"
		   	git checkout master
		   	git pull
		   	git pull . dev
		   	git push
			git checkout dev
	   	fi
     	com=$com"cd "$arg";echo 'pull "$arg"';git pull;echo 'pull "$arg" done';cd ..;"
     	#com=$com"git clone git@hlg28:lib.git;cd ..;"
done;
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
