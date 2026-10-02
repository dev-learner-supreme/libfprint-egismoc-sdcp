#!/bin/bash
# Run with sudo. Full revert to the distro fingerprint stack.
set -uo pipefail
[ "$(id -u)" = 0 ] || { echo "run with sudo" >&2; exit 1; }
if [ -f /etc/pam.d/sudo.pre-fprintd ]; then
  mv /etc/pam.d/sudo.pre-fprintd /etc/pam.d/sudo && echo "restored /etc/pam.d/sudo"
fi
rm -f /etc/systemd/system/fprintd.service.d/50-egismoc-sdcp.conf
rmdir /etc/systemd/system/fprintd.service.d 2>/dev/null
systemctl daemon-reload
systemctl stop fprintd.service
rm -rf /var/lib/fprint/egismoc /opt/libfprint-sdcp
echo "Reverted. Also run: fprintd-delete \$USER (as your user) to drop stale prints."
