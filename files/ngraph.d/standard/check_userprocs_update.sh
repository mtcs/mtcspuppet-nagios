#!/bin/bash
userlist=$( cat /etc/ssh/sshd_config | grep ^AllowUsers | cut -d' ' -f2- )

color=(ff0000 00ff00 0000ff eeee00 000000 00ffff ff00ff ff9900 ff0099 00ff99 99ff00 0099ff 9900ff 880000 008800 000088 888800 880088 008888 888888 440000 004400 000044 444400 440044 004444)
colorscs=$(echo ${color[*]} | tr ' ' ',')

echo "#GENERATE AUTOMATICALLY!!!!!"> check_userprocs.ncfg
echo "#$userlist">> check_userprocs.ncfg

count=0

for i in $userlist ; do
	echo $i
	for j in CPU MEM ; do 
	echo "
define ngraph{
	service_name		User Processes
	graph_perf_regex	$i-$j=(\d+[\.,]?\d?)%
	graph_value		$i$j
	graph_units		%
	graph_legend		$i $j
	rrd_plottype		LINE3
	rrd_color		${color[$count]}
	page			$j
	colors			$colorscs
}" >> check_userprocs.ncfg
	done
	let count=$count+1
done

for i in $userlist ; do
for j in CPU MEM ; do 
echo "
define nmgraph{
	host_name		* Multigraphen
	service_name		All Processes $i $j
	# RegEX
	hosts			.*?
	# RegEX
	services		User Processes
	graph_values		$i$j
	# line or stack or area
	graph_type		line3
	# normal or reverse or leave blank
	#order			normal
	colors			$colorscs
} " >> check_userprocs.ncfg
done
done

for j in CPU MEM ; do 
echo "
define nmgraph{
	host_name		* Multigraphen
	service_name		All Processes $j
	# RegEX
	hosts			.*?
	# RegEX
	services		User Processes
	graph_values		$j
	# line or stack or area
	graph_type		line3
	# normal or reverse or leave blank
	#order			normal
	colors			$colorscs
} " >> check_userprocs.ncfg
done



#[EOF]
