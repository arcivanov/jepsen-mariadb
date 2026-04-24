#!/bin/bash
set -euo pipefail

echo "===========Append serializable============="
lein $LEIN_OPTIONS --time-limit 60 --key-count 40 -w append -i serializable
echo "===========Append repeatable-read============="
lein $LEIN_OPTIONS --time-limit 60 --key-count 40 -w append -i repeatable-read
echo "===========Append read-committed============="
lein $LEIN_OPTIONS --time-limit 60 --key-count 40 -w append -i read-committed
echo "===========Append read-uncommitted============="
lein $LEIN_OPTIONS --time-limit 60 --key-count 40 -w append -i read-uncommitted

echo "===========Non-repeatable read serializable============="
lein $LEIN_OPTIONS --time-limit 60 --key-count 40 -w nonrepeatable-read -i serializable
echo "===========Non-repeatable repeatable-read============="
lein $LEIN_OPTIONS --time-limit 60 --key-count 40 -w nonrepeatable-read -i repeatable-read

echo "===========mav serializable============="
lein $LEIN_OPTIONS --time-limit 60 --key-count 40 -w mav -i serializable
echo "===========mav repeatable-read============="
lein $LEIN_OPTIONS --time-limit 60 --key-count 40 -w mav -i repeatable-read
