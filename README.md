# AirDrop Wi-Fi — awdl0 toggle for System Settings

A tiny System Settings pane with one switch: turn macOS's `awdl0` interface (AirDrop / Continuity) on or off.

## Why

`awdl0` (Apple Wireless Direct Link) powers AirDrop, Sidecar, Universal Control and other Continuity features. While it is up, the Wi-Fi radio regularly leaves the access point's channel to listen for nearby Apple devices. The result is random latency spikes on the local network, painful for screen sharing, remote desktop or games.

Measured on a MacBook Pro M4 over Wi-Fi 6, pinging the router:

| awdl0 | Average | Pings over 30 ms |
|---|---|---|
| up | ~17 ms | 15 % |
| down | 9.8 ms | 3 % |

## What it does

- Shows the current state of `awdl0`, refreshed every 2 s (macOS brings it back by itself)
- Switch on → `ifconfig awdl0 up`, switch off → `ifconfig awdl0 down`

## Requirements

- macOS 14 or later, Apple silicon
- Xcode Command Line Tools (`xcode-select --install`)

## Install

```sh
git clone https://github.com/Microburo/awdl-toggle.git
cd awdl-toggle
./install-sudoers.sh   # once, asks for your password
./build.sh             # builds and installs ~/Library/PreferencePanes/AWDLToggle.prefPane
```

Then open System Settings: **AirDrop Wi-Fi** is at the bottom of the sidebar. If System Settings was open, quit and reopen it.

`install-sudoers.sh` writes `/etc/sudoers.d/awdl-toggle`, which lets your user run exactly these two commands without a password, and nothing else:

```
/sbin/ifconfig awdl0 up
/sbin/ifconfig awdl0 down
```

## Caveats

- With `awdl0` down, AirDrop, Sidecar, Universal Control and Continuity Camera stop working until you switch it back on.
- macOS turns `awdl0` back on at restart, and may do so when you open AirDrop.
- The pane is ad-hoc signed, not notarized: build it yourself from source.

## Icon

`swift tools/make_icon.swift build/AWDLToggle.iconset && iconutil -c icns -o Resources/AWDLToggle.icns build/AWDLToggle.iconset`

## Uninstall

```sh
rm -rf ~/Library/PreferencePanes/AWDLToggle.prefPane
sudo rm /etc/sudoers.d/awdl-toggle
```

## License

MIT — see [LICENSE](LICENSE). Not affiliated with Apple.
