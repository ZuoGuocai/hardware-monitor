#!/usr/bin/env bash
#author:zuoguocai@126.com

idrac_get_value(){
	get="curl -s -connect-timeout 5 "https://${1}/redfish/v1/Chassis/System.Embedded.1/Power/PowerControl" -k -u ${2}:${3} | jq .PowerConsumedWatts"
	eval $get
}

bmc_get_value(){
	get="curl -s -connect-timeout 5 "https://${1}/redfish/v1/Chassis/1/Power/PowerControl" -k -u ${2}:${3}  |jq  .value[].PowerConsumedWatts"
	eval $get
}

idrac_insert_value(){
	watt_value=$(idrac_get_value ${1} ${2} ${3})
	run="curl -s -connect-timeout 5 –XPOST \"http://localhost:8086/write?db=watt_monitor&u=power&p=power\" --data-binary \"watt,room=${4},cabinet=${5},idrac_ip=${1}  watt_value=${watt_value}\" "
#	echo $run
	eval $run
}

bmc_insert_value(){
	watt_value=$(bmc_get_value ${1} ${2} ${3})
	run="curl -s -connect-timeout 5 –XPOST \"http://localhost:8086/write?db=watt_monitor&u=power&p=power\" --data-binary \"watt,room=${4},cabinet=${5},bmc_ip=${1}  watt_value=${watt_value}\" "
#	echo $run
	eval $run
}






while read line

do
        	oem=`echo ${line}|awk -F'|' '{print $6}'`
		ip=`echo ${line}|awk -F'|' '{print $3}'`
		user=`echo ${line}|awk -F'|' '{print $4}'`
		pass=`echo ${line}|awk -F'|' '{print $5}'`
        	room=`echo ${line}|awk -F'|' '{print $1}'`
        	cabinet=`echo ${line}|awk -F'|' '{print $2}'`
		if [ ${oem} == "idrac" ];then
			idrac_insert_value  "${ip}" "${user}" "${pass}" "${room}" "${cabinet}"  & 
		else
			bmc_insert_value    "${ip}" "${user}" "${pass}"  "${room}" "${cabinet}" &
		fi
done</root/watt_collect/idrac.list

wait

