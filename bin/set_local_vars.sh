rhc app show myapp --gears  > /tmp/foo
declare -a hosts=();
while read line;
do 
	case "$line" in
		*@*)
#			echo "yes ...." $line ;
			hoststring=`echo $line | cut --delimiter=' ' --fields=6`;
#			echo "hoststring=" $hoststring;
			hosts=("${hosts[@]}" $hoststring);
			;;
	esac
done < /tmp/foo

#echo "hosts array length=" ${#hosts[@]}
#echo "hosts array contents=" ${hosts[@]}

export pgmaster=${hosts[0]}
export pgstandby=${hosts[1]}

echo "master is..." $pgmaster
echo "standby is..." $pgstandby

export pgmasteruser=`echo $pgmaster | tr '@' '\n' | head -1`
export pgmasterhost=`echo $pgmaster | tr '@' '\n' | tail -1`
export pgstandbyuser=`echo $pgstandby | tr '@' '\n' | head -1`
export pgstandbyhost=`echo $pgstandby | tr '@' '\n' | tail -1`
echo "master user is..." $pgmasteruser
echo "master host is..." $pgmasterhost
echo "standby user is..." $pgstandbyuser
echo "standby host is..." $pgstandbyhost
