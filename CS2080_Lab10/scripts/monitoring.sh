#!/usr/bin/bash

mkdir -p $HOME/CS2080_Lab9/reports

{
    echo "SERVER HEALTH REPORT"
    echo "Last Updated: $(date)"
    echo

    gawk -f script.gawk ../data/monitoring.csv

} > /var/www/html/monitoring/health_report.txt

cat /var/www/html/monitoring/health_report.txt