#!/bin/bash

WL=$1
CL=$2

usage(){
	echo "#check_gputemp.sh [warning_level] [critical_level] "
	exit 3;
}

state=0

if ( [ -z $WL ] || [ -z "$CL" ] ) ; then
	usage
fi

GPUTEMP=()

if [ -x '/usr/bin/nvidia-smi' ] ; then 

	GPUTEMP=($(nvidia-smi -a | grep Temperature -A1 | grep Gpu | cut -d: -f2 | tr -d 'C\n'))

else
	echo "UNKNOWN"
	exit 3
fi

for (( i=0 ; i<${#GPUTEMP[*]} ; i++ )) ; do  
	if [ $state -lt 2 ] ; then
		if ( [ $state -lt 1 ] && [ ${GPUTEMP[$i]} -gt $WL ] ) ; then
			state=1
		fi
		if [ ${GPUTEMP[$i]} -gt $CL ] ; then
			state=2
		fi
	fi
	 
done

case $state in  
	0)
	echo -n "OK - "
	;;
	1)
	echo -n "WARNING - "
	;;
	2)
	echo -n "CRITICAL - "
	;;
esac

for (( i=0 ; i<${#GPUTEMP[*]} ; i++ )) ; do  
	echo -n "GPU$i:${GPUTEMP[$i]} "
done

#echo -n '| '

#for (( i=0 ; i<${#GPUTEMP[*]} ; i++ )) ; do  
#	echo -n "GPU$i=${GPUTEMP[$i]} "
#done
echo  ' '
exit $state
