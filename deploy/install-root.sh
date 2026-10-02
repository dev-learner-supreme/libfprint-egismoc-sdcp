#!/bin/bash
# Run with sudo. Installs the staged build to /opt and points only fprintd at it.
# The distro libfprint package is left untouched.
set -euo pipefail
[ "$(id -u)" = 0 ] || { echo "run with sudo" >&2; exit 1; }
SRC="$(cd "$(dirname "$0")/.." && pwd)"
PREFIX=/opt/libfprint-sdcp
STAGED="$SRC/stage$PREFIX"
[ -f "$STAGED/lib/libfprint-2.so.2" ] || { echo "run deploy/build.sh first" >&2; exit 1; }

rm -rf "$PREFIX.new"
cp -a "$STAGED" "$PREFIX.new"
chown -R root:root "$PREFIX.new"
rm -rf "$PREFIX"
mv "$PREFIX.new" "$PREFIX"

install -d /etc/systemd/system/fprintd.service.d
cat > /etc/systemd/system/fprintd.service.d/50-egismoc-sdcp.conf <<CONF
# Hardened egismoc SDCP libfprint (source: $SRC). Remove this file to revert
# to the distro libfprint: sudo $SRC/deploy/uninstall-root.sh
[Service]
Environment=LD_LIBRARY_PATH=$PREFIX/lib
# Belt and braces for stale SDCP sessions (driver also resets on every open)
ExecStartPre=-/usr/bin/find /var/lib/fprint/egismoc -name sdcp-claim -delete
CONF

systemctl daemon-reload
systemctl stop fprintd.service || true
echo "Installed. fprintd will use $PREFIX on next start."
