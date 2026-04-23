#!/bin/bash
set -euo pipefail

echo "===========Build smoke test============="
lein $LEIN_OPTIONS --time-limit 10 -w build-smoke-test -i serializable
