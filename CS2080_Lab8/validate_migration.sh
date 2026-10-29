#!/usr/bin/bash

# CS 2080 Lab 8 - Migration Validator
# Run this script from the Lab 8 workspace after migrate_all.sh.
# Expected migrated files:
#   migrated/prod.conf
#   migrated/staging.conf
#   migrated/backup.conf

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

for file in prod.conf staging.conf backup.conf
do
    path="migrated/$file"
    if [ -f "$path" ]
    then
        pass "$path exists"
    else
        fail "$path exists"
    fi
done

echo

# Stop detailed checks for a file if it does not exist.
for file in prod.conf staging.conf backup.conf
do
    path="migrated/$file"

    if [ ! -f "$path" ]
    then
        continue
    fi

    echo "--- Checking $path ---"

    check_present "$path" "SERVICE_USER=appsvc" \
        "$file: SERVICE_USER changed to appsvc"

    check_absent "$path" "SERVICE_USER=legacyuser" \
        "$file: legacy SERVICE_USER removed"

    check_present "$path" "# Managed by CS2080 migration" \
        "$file: management comment inserted"

    check_present "$path" "LOG_LEVEL=WARNING" \
        "$file: LOG_LEVEL changed to WARNING"

    check_absent "$path" "LEGACY_MODE=" \
        "$file: LEGACY_MODE removed"

    check_present "$path" "HEALTH_CHECK=enabled" \
        "$file: HEALTH_CHECK appended"

    check_present "$path" "TLS=Y" \
        "$file: TLS flag changed to Y"

    check_absent "$path" "TLS=N" \
        "$file: old TLS flag removed"

    echo
done

# Environment-specific hostname/IP checks.
if [ -f migrated/prod.conf ]; then
    check_present migrated/prod.conf "NODE_ADDRESS=prod-app-01:10.20.1.25" \
        "prod.conf: prod-app-01 IP changed to 10.20.1.25"
fi

if [ -f migrated/staging.conf ]; then
    check_present migrated/staging.conf "NODE_ADDRESS=stage-app-01:10.20.2.25" \
        "staging.conf: stage-app-01 IP changed to 10.20.2.25"
fi

if [ -f migrated/backup.conf ]; then
    check_present migrated/backup.conf "NODE_ADDRESS=dr-app-01:10.20.3.25" \
        "backup.conf: dr-app-01 IP changed to 10.20.3.25"
fi

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
    echo "Review the [FAIL] lines, correct your sed rules, and run the validator again."
    exit 1
fi
