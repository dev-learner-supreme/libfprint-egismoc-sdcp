> [!NOTE]
> **This branch (`hardened`)** is a hardened build of
> [TenSeventy7/libfprint-egismoc-sdcp](https://github.com/TenSeventy7/libfprint-egismoc-sdcp)
> for the **Egis ETU905A88-E (`1c7a:0584`)** match-on-chip sensor on the
> **Acer Swift SFG14-71**, tested on **Ubuntu 26.04 LTS**.
> See [Egis 1c7a:0584 on Ubuntu 26.04](#egis-1c7a0584-on-ubuntu-2604) below.

## Egis 1c7a:0584 on Ubuntu 26.04

The stock Ubuntu libfprint detects this sensor, but it doesn't support SDCP (the Secure
Device Connection Protocol), so prints never persist on the chip. The upstream fork adds
SDCP. This branch fixes the problems that made it unreliable in daily use.

### What this branch fixes

| Problem | Fix | Fork ref |
|---|---|---|
| fprintd aborts on the next open after a cancelled or timed-out scan | Route wait-for-finger failures through the task SSM so it's cleared, and discard any leftover SSM at open | [#13](https://github.com/TenSeventy7/libfprint-egismoc-sdcp/issues/13) |
| Verify fails permanently after the laptop idles or resumes (stale SDCP claim) | New `fpi_sdcp_device_reset_claim()`. The claim is reset on every open and after a MAC failure | [#16](https://github.com/TenSeventy7/libfprint-egismoc-sdcp/issues/16) |
| fprintd aborts for ~1 in 256 host keys (leading zero byte) | Serialize the private key at a fixed width with `BN_bn2binpad()` | — |
| Device responses aren't bounds-checked | Bounds checks from upstream `0ca3470` | — |
| Doesn't build on 26.04 | Detect libudev, link egismoc against OpenSSL, declare `FpiSdcpDevice` as the parent | [#3](https://github.com/TenSeventy7/libfprint-egismoc-sdcp/pull/3), [#12](https://github.com/TenSeventy7/libfprint-egismoc-sdcp/pull/12), [#14](https://github.com/TenSeventy7/libfprint-egismoc-sdcp/issues/14) |

### Install

This install leaves the distro `libfprint-2-2` package alone. The build goes into
`/opt/libfprint-sdcp`, and only `fprintd` is pointed at it, through a systemd drop-in.

```sh
# 0. build dependencies (enable deb-src first)
sudo apt build-dep libfprint

# 1. build and test as a normal user; stages into ./stage and checks that fprintd links cleanly
deploy/build.sh

# 2. install to /opt and add the fprintd drop-in
sudo deploy/install-root.sh

# 3. enroll and check
fprintd-enroll -f right-index-finger
fprintd-verify

# 4. optional: fingerprint for sudo only. The password prompt is still the fallback.
sudo deploy/enable-sudo-fingerprint.sh
```

Login and the lock screen use GNOME's stock `gdm-fingerprint` PAM service. Turn it on in
**Settings → System → Users → Fingerprint Login**. `common-auth` is left unchanged on
purpose, because adding `pam_fprintd` there races with `gdm-fingerprint` inside `gdm-password`.

### Troubleshooting and revert

```sh
journalctl -b -u fprintd           # daemon log
sudo deploy/uninstall-root.sh      # restores /etc/pam.d/sudo, removes the drop-in and /opt build
fprintd-delete "$USER"             # then drop the stale prints
```

---

<div align="center">

# LibFPrint

*LibFPrint is part of the **[FPrint][Website]** project.*

<br/>

[![Button Website]][Website]
[![Button Documentation]][Documentation]

[![Button Supported]][Supported]
[![Button Unsupported]][Unsupported]

[![Button Contribute]][Contribute]
[![Button Contributors]][Contributors]

</div>

## History

**LibFPrint** was originally developed as part of an
academic project at the **[University Of Manchester]**.

It aimed to hide the differences between consumer
fingerprint scanners and provide a single uniform
API to application developers.

## Goal

The ultimate goal of the **FPrint** project is to make
fingerprint scanners widely and easily usable under
common Linux environments.

## License

`Section 6` of the license states that for compiled works that use
this library, such works must include **LibFPrint** copyright notices
alongside the copyright notices for the other parts of the work.

**LibFPrint** includes code from **NIST's** **[NBIS]** software distribution.

We include **Bozorth3** from the **[US Export Controlled]**
distribution, which we have determined to be fine
being shipped in an open source project.

## Get in *touch*

 - [IRC] - `#fprint` @ `irc.oftc.net`
 - [Matrix] - `#fprint:matrix.org` bridged to the IRC channel
 - [MailingList] - low traffic, not much used these days

<br/>

<div align="right">

[![Badge License]][License]

</div>


<!----------------------------------------------------------------------------->

[Documentation]: https://fprint.freedesktop.org/libfprint-dev/
[Contributors]: https://gitlab.freedesktop.org/libfprint/libfprint/-/graphs/master
[Unsupported]: https://gitlab.freedesktop.org/libfprint/wiki/-/wikis/Unsupported-Devices
[Supported]: https://fprint.freedesktop.org/supported-devices.html
[Website]: https://fprint.freedesktop.org/
[MailingList]: https://lists.freedesktop.org/mailman/listinfo/fprint
[IRC]: ircs://irc.oftc.net:6697/#fprint
[Matrix]: https://matrix.to/#/#fprint:matrix.org

[Contribute]: ./HACKING.md
[License]: ./COPYING

[University Of Manchester]: https://www.manchester.ac.uk/
[US Export Controlled]: https://fprint.freedesktop.org/us-export-control.html
[NBIS]: http://fingerprint.nist.gov/NBIS/index.html


<!---------------------------------[ Badges ]---------------------------------->

[Badge License]: https://img.shields.io/badge/License-LGPL2.1-015d93.svg?style=for-the-badge&labelColor=blue


<!---------------------------------[ Buttons ]--------------------------------->

[Button Documentation]: https://img.shields.io/badge/Documentation-04ACE6?style=for-the-badge&logoColor=white&logo=BookStack
[Button Contributors]: https://img.shields.io/badge/Contributors-FF4F8B?style=for-the-badge&logoColor=white&logo=ActiGraph
[Button Unsupported]: https://img.shields.io/badge/Unsupported_Devices-EF2D5E?style=for-the-badge&logoColor=white&logo=AdBlock
[Button Contribute]: https://img.shields.io/badge/Contribute-66459B?style=for-the-badge&logoColor=white&logo=Git
[Button Supported]: https://img.shields.io/badge/Supported_Devices-428813?style=for-the-badge&logoColor=white&logo=AdGuard
[Button Website]: https://img.shields.io/badge/Homepage-3B80AE?style=for-the-badge&logoColor=white&logo=freedesktopDotOrg
