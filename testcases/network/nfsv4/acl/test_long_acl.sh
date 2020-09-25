#!/bin/bash
# PURPOSE: Try to "build" ACLs of different length. Stop when the specified maximum length is reached.
  
maxlength=$1
testdir=$2

userlist=`cat /etc/passwd | awk -F ':' '{print $1}'`
gidlist=`cat /etc/passwd | awk -F ':' '{print $4}'`

echo "test acl getfacl"
for i in $(seq 1 $maxlength)
do
	echo "the $i loop"
        touch $testdir/testfile$i
	for j in $(seq 1 $i)
        do
                randomUser=`cat /etc/passwd | shuf | awk -F ':' 'NR<=1{print $1}'`
                testuser=$randomUser
                randomMode=`expr $RANDOM % 8`
                testmode=$randomMode
		echo "testing setfacl with u:$testuser:$testmode $testdir/testfile$j"
                setfacl -m u:$testuser:$testmode $testdir/testfile$j
                checkmode=`getfacl $testdir/testfile$j | grep ${testuser}: | awk -F ':' '{print $3}'`
		if [[ $checkmode == *"r"* ]]; then
			if [ $(($testmode&4)) -eq 0 ]; then
				echo "Setfacl test failed: Expect mode for user $testuser is $testmode, but got mode $checkmode"
			fi
		fi
		if [[ $checkmode == *"w"* ]]; then
                        if [ $(($testmode&2)) -eq 0 ]; then
                                echo "Setfacl test failed: Expect mode for user $testuser is $testmode, but got mode $checkmode"
                        fi
                fi
                if [[ $checkmode == *"x"* ]]; then
                        if [ $(($testmode&1)) -eq 0 ]; then
                                echo "Setfacl test failed: Expect mode for user $testuser is $testmode, but got mode $checkmode"
                        fi
                fi
        done
done
