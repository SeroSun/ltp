#!/bin/bash
# PURPOSE: Try to "build" ACLs of different length. Stop when the specified maximum length is reached.
  
nloop=$1
testdir=$2

for i in {1..5}
do
	touch $testdir/testfile$1
done

echo "setfacl stress test"
for i in $(seq 1 $nloop)
do
	echo "the $i loop"
        touch $testdir/testfile$i
	randomUser=`cat /etc/passwd | shuf | awk -F ':' 'NR<=1{print $1}'`
	randomGrpid=`cat /etc/passwd | shuf | awk -F ':' 'NR<=1{print $4}'`
	randomMode=`expr $RANDOM % 8`
	testfile=$testdir/testfile$((RANDOM%5+1))

	a=$((RANDOM%4+1))
	case $a in
		1)
			setfacl -m u:$randomUser:$randomMode $testfile
			;;
		2)
			setfacl -m g:$randomGrpid:$randomMode $testfile
			;;
		3)
			setfacl -x u:$randomUser $testfile
			;;
		4)
			setfacl -x g:$randomGrpid $testfile
			;;
	esac
done
