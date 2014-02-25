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
done < /tmp/rhcoutput

#echo "hosts array length=" ${#hosts[@]}
#echo "hosts array contents=" ${hosts[@]}

export MASTER=${hosts[0]}
export STANDBY=${hosts[1]}

echo "MASTER is..." $MASTER
echo "STANDBY is..." $STANDBY

export MASTER_USER=`echo $MASTER | tr '@' '\n' | head -1`
export MASTER_HOST=`echo $MASTER | tr '@' '\n' | tail -1`
export STANDBY_USER=`echo $STANDBY | tr '@' '\n' | head -1`
export STANDBY_HOST=`echo $STANDBY | tr '@' '\n' | tail -1`
echo "MASTER_USER is..." $MASTER_USER
echo "MASTER_HOST is..." $MASTER_HOST
echo "STANDBY_USER is..." $STANDBY_USER
echo "STANDBY_HOST is..." $STANDBY_HOST
