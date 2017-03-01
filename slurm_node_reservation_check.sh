#!/bin/bash 

NODE=$1 
if [ "$NODE" == "" ]; then
echo 'pass compute node name in $1'
exit 1
fi;

# script to find  if node is in reservations 
sinfo -T -h | awk '{ print $1,$NF }' |
 while read REASON NODES ;
 do
    scontrol show hostname $NODES | tr "\n" " ";
    # i use printf as I know it doesn't print new line
    printf "\t $REASON" ;
    # print new line
    echo " ";
 done | grep $1

if [ $? -ne 0 ];then
echo "no such node or $1 not in reservation"
fi
