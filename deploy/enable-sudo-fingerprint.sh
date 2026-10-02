#!/bin/bash
# Run with sudo. Adds fingerprint as an optional first factor for sudo only.
# Password always remains available: any fingerprint failure, timeout or
# daemon problem falls through to the normal password prompt.
set -euo pipefail
[ "$(id -u)" = 0 ] || { echo "run with sudo" >&2; exit 1; }
F=/etc/pam.d/sudo
LINE='auth       sufficient   pam_fprintd.so max-tries=1 timeout=10'
grep -q pam_fprintd "$F" && { echo "already enabled"; exit 0; }
cp -a "$F" "$F.pre-fprintd"
# insert directly before common-auth so it is tried before the password
awk -v l="$LINE" '/^@include common-auth/ {print l} {print}' "$F.pre-fprintd" > "$F.new"
grep -c pam_fprintd "$F.new" | grep -qx 1
grep -q '^@include common-auth' "$F.new"
chmod 644 "$F.new"; mv "$F.new" "$F"
echo "Enabled. Backup at $F.pre-fprintd"; cat "$F"
