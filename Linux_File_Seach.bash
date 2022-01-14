#!/bin/bash
locate "log4j*.jar" 2> /dev/null
lsof -w| grep -ia log4j

# start AT and wait 
echo If you get errors with AT command you may need to install it or start atd manualy 
systemctl start atd
sleep 20

if test -f "/tmp/at.out"
	then
    	echo '/tmp/at.out found showing contents'
		cat /tmp/at.out
        echo "ALL DONE $Env:computername $HOST "
	else
    	echo /tmp/at.out not found running search
		# kill any searches
		killall -9 find 2> /dev/null
    	echo 'find / -iname "log4j*.jar" | tee -a /tmp/at.out' > /tmp/at.sh
		at now + 1 minutes < /tmp/at.sh
fi


# too slow ... look at open files and there paths / ALL subfolders!
# for i in `lsof -F n | grep ^n/ | cut -c2- | sort -u | grep -vE "(\.so$)" | xargs dirname|grep -iavE "(\bdev\b|proc|^\/$)"|sort -u`;do echo Path: "${i}" ;find "${i}" -iname "log4j*.jar" ;done   2> /dev/null
