#!/bin/bash
# Requires 5 arguments. First 3 as port numbers, next two are
# server address and username respectively
ports="$1 $2 $3"
host="$4"

for x in $ports
do
    nmap -Pn --host-timeout 201 --max-retries 0 -p $x $host
    sleep 1
done
ssh $5@${host}
