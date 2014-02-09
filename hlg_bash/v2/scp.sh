#!/bin/bash
echo "填写本地要要同步的文件"
read local
if [ "$local" = '' ];then
   echo "没文件"
   exit
fi
echo "类别：task,tb,api"
read task
echo $task
if [ "$task" = 'task' ];then
   IPS="hlg54 hlg55 hlg58 hlg61 hlg59 hlg60 hlg62 hlg63 hlg64 hlg65 hlg67 hlg68 hlg113 hlg16 hlg186 hlg11 hlg110 hlg238  hlg121119 hlg121181 hlg121238 hlg121239 hlg121249"
elif [ "$task" = 'api' ];then
   IPS="hlg16 hlg186"
else
   IPS="hlg30 hlg45 hlg46 hlg47 hlg48 hlg49 hlg50 hlg53"
fi
echo "填写要要同步到远程的位置"
read remote
if [ "$remote" = '' ];then
   echo "未指定远程路径"
   exit
fi
for ip in $IPS;do 
   echo $ip
   scp $local $ip":"$remote
done;
#sleep 6;
echo "all done.";
exit

