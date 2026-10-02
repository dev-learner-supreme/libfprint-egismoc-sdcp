#!/bin/bash
# Build the hardened egismoc-only libfprint as a normal user and run its tests.
set -euo pipefail
SRC="$(cd "$(dirname "$0")/.." && pwd)"
PREFIX=/opt/libfprint-sdcp
cd "$SRC"
rm -rf build stage
meson setup build --prefix="$PREFIX" --libdir=lib \
  -Ddrivers=egismoc -Dintrospection=true -Ddoc=false -Dgtk-examples=false \
  -Dudev_rules=disabled -Dudev_hwdb=disabled -Dinstalled-tests=false
meson compile -C build
meson test -C build --print-errorlogs --no-suite data  # data: metainfo URL check, fork issue #8
DESTDIR="$SRC/stage" meson install -C build --no-rebuild

# fprintd must resolve every libfprint symbol it imports from the new library.
LIB="$SRC/stage$PREFIX/lib"
if LD_LIBRARY_PATH="$LIB" ldd -r /usr/libexec/fprintd 2>&1 | grep -E 'undefined symbol|not found'; then
  echo "ERROR: fprintd does not link cleanly against the new libfprint" >&2; exit 1
fi
LD_LIBRARY_PATH="$LIB" ldd /usr/libexec/fprintd | grep -E 'libfprint|libcrypto'
echo "OK: staged in $SRC/stage$PREFIX"
