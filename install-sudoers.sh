#!/bin/bash
# One-time: allow the current user to run exactly "ifconfig awdl0 up|down" without a password
set -euo pipefail
F=/etc/sudoers.d/awdl-toggle
echo "$(id -un) ALL=(root) NOPASSWD: /sbin/ifconfig awdl0 up, /sbin/ifconfig awdl0 down" | sudo tee "$F.tmp" >/dev/null
sudo chmod 440 "$F.tmp"
sudo visudo -cf "$F.tmp"
sudo mv "$F.tmp" "$F"
echo "OK $F"
