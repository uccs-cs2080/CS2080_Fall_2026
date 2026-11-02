#!/usr/bin/bash
lab_dir="$HOME/CS2080_Lab9"
data_file="$lab_dir/data/monitoring.csv"
report="$lab_dir/reports/health_report.txt"
collector="$lab_dir/scripts/collect_metrics.sh"
monitor="$lab_dir/scripts/monitoring.sh"
passed=0
failed=0
pass(){ echo "[PASS] $1"; passed=$((passed+1)); }
fail(){ echo "[FAIL] $1"; failed=$((failed+1)); }

check_file(){ if [ -f "$1" ]; then pass "$2"; else fail "$2"; fi; }

echo "===== CS 2080 Lab 9 Validation ====="
echo
check_file "$data_file" "monitoring.csv exists"
check_file "$collector" "collect_metrics.sh exists"
check_file "$monitor" "monitoring.sh exists"
check_file "$report" "health_report.txt exists"

if [ -f "$data_file" ]; then
    fields=$(tail -n 1 "$data_file" | gawk -F, '{print NF}')
    if [ "$fields" -eq 9 ]; then pass "latest monitoring record has 9 fields"; else fail "latest monitoring record has 9 fields"; fi
    tail -n 1 "$data_file" | gawk -F, '$2!="" && $4!="" && $5 ~ /^[0-9]+([.][0-9]+)?$/ && $6 ~ /^[0-9]+([.][0-9]+)?$/ && $7 ~ /^[0-9]+([.][0-9]+)?$/ && $8 ~ /^[0-9]+$/ {ok=1} END{exit !ok}'
    if [ $? -eq 0 ]; then pass "latest record contains populated numeric metrics"; else fail "latest record contains populated numeric metrics"; fi
fi

if [ -f "$report" ]; then
    grep -Fq "SERVER HEALTH REPORT" "$report" && pass "report heading exists" || fail "report heading exists"
    grep -Fq "web-01" "$report" && pass "report includes web-01" || fail "report includes web-01"
    grep -Fq "app-01" "$report" && pass "report includes app-01" || fail "report includes app-01"
    grep -Fq "db-01" "$report" && pass "report includes db-01" || fail "report includes db-01"
    grep -Fq "Average CPU:" "$report" && pass "report includes Average CPU" || fail "report includes Average CPU"
    grep -Fq "Records processed:" "$report" && pass "report includes record count" || fail "report includes record count"
fi

echo
echo "===== Validation Summary ====="
echo "Passed: $passed"
echo "Failed: $failed"
if [ "$failed" -eq 0 ]; then echo; echo "LAB VALIDATION PASSED"; exit 0; else echo; echo "LAB VALIDATION FAILED"; exit 1; fi
