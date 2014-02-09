#!/bin/bash
cd /service/dev/hlg/tb-v2/app/code
newModel="Core Crm Finance Icon Material Monitor Promotion Promoprops Qianniu Ratedesc Shopreport Tool Udp Setting"
for model in $newModel; do
	git clone git@hlg28:api/$model.git
	cd $model
	git checkout dev
	git checkout master
	git pull . dev
	git add .
	git commit -am 'init'
	git push 
	cd ..
done
oldModel="Act Appstore Customer  Forum   List News    Orders  Project   Shop   Sub     Tb   Wangwangmanage Activity  Care Crmfront  Designer  Helper   Notify  Performance  Promodesc   Server   Taobao   Work Admin   Csa   Member    Msg     Optim   Point   Rate     Smart  Task    Trace  Vip"
for model in $oldModel; do
	git clone git@hlg28:$model.git
	cd $model
	git checkout dev
	git checkout master
	cd ..
done