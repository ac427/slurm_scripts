#!/bin/bash
# program to print load higher than total cpu 


usage(){

echo "Help: \"$(basename "$0") -e \" to send report via email. "
echo "Help: \"$(basename "$0")  \" will print to stdout and no email sent "

}

report() {

TEMPFILE=$( mktemp --tmpdir=/tmp )
TEMPLOGFILE=$( mktemp --tmpdir=/tmp )
SPACE=','
#SPACE='\t '

#run scontrol and egrep for NodeName and CPULoad and trim to get the items we need . ie., NodeName and CPUTot & CPULoad

scontrol show node | egrep "NodeName|CPULoad" |
#TO PRINT ALL CPU INFO 
#awk '{ if ($1 ~ /NodeName/) printf "\n %s,",$1; else if ($1 ~ /CPU/) for (i=1;i<=NF;i++)  printf "%s,",$i }' | tee $TEMPFILE

#IF YOU WANT JUST TOTAL CPU AND LOAD
awk '{ if ($1 ~ /NodeName/) printf "\n %s,",$1; else if ($1 ~ /CPU/)  printf "%s,%s",$(NF-1),$NF}  END {printf "\n" }' | tee -a $TEMPFILE 

# ignore the nodes that are Down* state 

for node in $(cat $TEMPFILE | grep -v "N/A");
do
	CPUTot=$( echo $node | awk -F, '{print $2}' | awk -F= '{print $2}')
	CPULoad=$( echo $node | awk -F, '{print $3}' | awk -F= '{print $2}')

	# rounding float to int 
	intCPULoad=${CPULoad%.*}
	# incrementing CPUTot+=3.  
	intCPUTot=$((CPUTot+3))

		if [ $intCPULoad -ge $intCPUTot ]
		then
			echo $node  | tee -a $TEMPLOGFILE
		fi
done

}

email(){
#send email. replace foo@foodomain.com with your email address 
mail -s "Nodes with High CPULoad `hostname`" foo@foodomain.com < ${TEMPLOGFILE}
}

#cleanup 
cleanup(){
rm $TEMPFILE
rm $TEMPLOGFILE
}

case $1 in
   "-e") report > /dev/null
         email
         cleanup
        ;;
   "-h") usage ;;
   *)    report
         cleanup
        ;;
esac

