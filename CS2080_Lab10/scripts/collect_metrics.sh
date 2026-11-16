#!/usr/bin/bash

# -----------------------------------------
# CS 2080 - Server Resource Data Collector
# -----------------------------------------

# 1. Collect timestamp
timestamp=$(date "+%Y-%m-%dT%H:%M:%S")

# 2. Collect hostname
host="web-01"

# 3. Set server role
role="web"

# 4. Get the first IP address
private_ip=$(hostname -I | gawk '{print $1}')

# 5. Calculate CPU utilization
# CPU utilization = 100 - idle CPU percentage
cpu=$(top -bn1 | gawk '/%Cpu/ {
    printf "%.1f", 100 - $8
}')

# 6. Calculate memory usage percentage
memory=$(free | gawk '/Mem:/ {
    printf "%.1f", ($3/$2) * 100
}')

# 7. Get root filesystem disk usage
disk=$(df -P / | gawk 'NR==2 {
    gsub(/%/, "", $5)
    print $5
}')

# 8. Count processes
processes=$(ps -ef | gawk 'NR>1 {
    count++
}
END {
    print count
}')

# 9. Check SSH service status
if systemctl status ssh.service | grep -q "active (running)"
then
    status="UP"
else
    status="DOWN"
fi

# Make sure the data directory exists
if [ ! -d data ]
then
    mkdir data
fi

# Append one monitoring record
echo "$timestamp,$host,$role,$private_ip,$cpu,$memory,$disk,$processes,$status" \
    >> $HOME/CS2080_Lab10/data/web-01.csv

# Display the collected record
echo "Monitoring record added:"
echo "$timestamp,$host,$role,$private_ip,$cpu,$memory,$disk,$processes,$status"