#!/usr/bin/bash

# CS 2080 Lab 8 - Migration Validator
# Run after executing scripts/migrate_all.sh.

lab_dir="$HOME/CS2080_Lab8"
migrated_dir="$lab_dir/migrated"

passed=0
failed=0

pass() {
    echo "[PASS] $1"
    passed=$((passed + 1))
}

fail() {
    echo "[FAIL] $1"
    failed=$((failed + 1))
}

check_present() {
    file="$1"
    pattern="$2"
    message="$3"

    if grep -Fxq "$pattern" "$file" 2>/dev/null
    then
        pass "$message"
    else
        fail "$message"
    fi
}

check_absent() {
    file="$1"
    pattern="$2"
    message="$3"

    if grep -Fq "$pattern" "$file" 2>/dev/null
    then
        fail "$message"
    else
        pass "$message"
    fi
}

echo "===== CS 2080 Lab 8 Migration Validation ====="
echo

# --------------------------------------------------
# Check that final migrated files exist
# --------------------------------------------------

for file in prod_migrated.conf staging_migrated.conf backup_migrated.conf
do
    path="$migrated_dir/$file"

    if [ -f "$path" ]
    then
        pass "$file exists"
    else
        fail "$file exists"
    fi
done

echo

# --------------------------------------------------
# Check common migration requirements
# --------------------------------------------------

for file in prod_migrated.conf staging_migrated.conf backup_migrated.conf
do
    path="$migrated_dir/$file"

    if [ ! -f "$path" ]
    then
        continue
    fi

    echo "--- Checking $file ---"

    check_present "$path" "SERVICE_USER=appsvc" \
        "$file: SERVICE_USER changed to appsvc"

    check_absent "$path" "legacyuser" \
        "$file: legacy username removed"

    check_absent "$path" "legacyapp" \
        "$file: legacy application path removed"

    check_present "$path" "# Managed by CS2080 migration" \
        "$file: management comment inserted"

    check_present "$path" "LOG_LEVEL=WARNING" \
        "$file: LOG_LEVEL changed to WARNING"

    check_absent "$path" "LEGACY_MODE=" \
        "$file: LEGACY_MODE removed"

    check_present "$path" "HEALTH_CHECK=enabled" \
        "$file: HEALTH_CHECK added"

    check_present "$path" "TLS=Y" \
        "$file: TLS flag changed to Y"

    check_absent "$path" "TLS=N" \
        "$file: old TLS flag removed"

    echo
done

# --------------------------------------------------
# Check environment-specific IP migrations
# --------------------------------------------------

check_present "$migrated_dir/prod_migrated.conf" \
    "NODE_ADDRESS=prod-app-01:10.20.1.25" \
    "prod_migrated.conf: prod-app-01 IP changed to 10.20.1.25"

check_present "$migrated_dir/staging_migrated.conf" \
    "NODE_ADDRESS=stage-app-01:10.20.2.25" \
    "staging_migrated.conf: stage-app-01 IP changed to 10.20.2.25"

check_present "$migrated_dir/backup_migrated.conf" \
    "NODE_ADDRESS=dr-app-01:10.20.3.25" \
    "backup_migrated.conf: dr-app-01 IP changed to 10.20.3.25"

echo
echo "===== Validation Summary ====="
echo "Passed: $passed"
echo "Failed: $failed"

if [ "$failed" -eq 0 ]
then
    echo
    echo "LAB VALIDATION PASSED"
    exit 0
else
    echo
    echo "LAB VALIDATION FAILED"
    echo "Review the [FAIL] lines, correct your migration, and run the validator again."
    exit 1
fi
