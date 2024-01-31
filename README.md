# Switch OC Revitalized

[![License: GPL v3](https://img.shields.io/badge/License-GPL_v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0.html)
[![Downloads](https://img.shields.io/github/downloads/Cod3xDev/Switch-OC-Revitalized/total)](https://github.com/Cod3xDev/Switch-OC-Revitalized/releases)

---

**Disclaimer: Use at your own risk!**

This project introduces an Overclocking Suite for Nintendo Switch consoles running Atmosphere CFW. Please be aware that utilizing this suite carries inherent risks, as it can potentially harm your console. It is strongly advised not to proceed unless you fully understand the implications. By choosing to use this software, you do so at your own risk, as it is provided "AS IS," without any warranty.

---

## Overview

Switch OC Revitalized is an overclocking solution designed to enhance the performance of Nintendo Switch consoles operating with Atmosphere Custom Firmware. The project aims to provide users with additional control over CPU, GPU, and DRAM frequencies, though it comes with inherent risks and potential hardware damage.

---

## License

This project is licensed under the [GNU General Public License v3.0](https://www.gnu.org/licenses/gpl-3.0.html). Please review the license terms before proceeding.

---

## Project Resources

- **Project Homepage:** [Switch OC Revitalized](https://cod3xdev.github.io/Switch-OC-Revitalized)
- **Downloads:** [Latest Releases](https://github.com/Cod3xDev/Switch-OC-Revitalized/releases)

---

## Installation

1. Download the latest [release](https://github.com/Cod3xDev/Switch-OC-Revitalized/releases).
2. Obtain `x.x.x_loader.kip` for your Atmosphere version, rename it to `loader.kip`, and place it in `/atmosphere/kips/`.
3. [Optional] Customize settings via the [online loader configurator](https://cod3xdev.github.io/Switch-OC-Revitalized/#config).
    <details>

    | Defaults   | Mariko        | Erista        |
    | ---------- | ------------- | ------------- |
    | CPU OC     | 2295 MHz Max  | 2091 MHz Max  |
    | CPU Volt   | 1235 mV       | 1235 mV       |
    | GPU OC     | 1267 MHz Max  | 998 Mhz max   |
    | RAM OC     | 1996 MHz      | 1862 MHz      |
    | RAM Volt   | Disabled      | Disabled      |
    | RAM Timing | Auto-Adjusted | Auto-Adjusted |
    | CPU UV     | Disabled      | N/A           |
    | GPU UV     | Disabled      | N/A           |

    </details>

4. For Hekate-ipl bootloader (fss0) only (Not required for AMS fusee), add `kip1=atmosphere/kips/loader.kip` to any boot entry in `bootloader/hekate_ipl.ini`.
5. Install [sys-clk-oc](https://github.com/Cod3xDev/Switch-OC-Revitalized/releases/latest/download/sys-clk-oc.zip).

---

## Updating via AIO

1. Download and copy `custom_packs.json` to `/config/aio-switch-updater/custom_packs.json`.
2. Launch AIO Switch Updater and go to the Custom Downloads tab.
3. Select Switch OC Revitalized and press Continue.

---

## Build

<details>

1. Copy Switch OC Revitalized files into the Atmosphere folder.
2. Run `patch.py` in `Atmosphere/stratosphere/loader/source/` to insert the OC module into the loader sysmodule.
3. Compile Atmosphere loader with devkitpro.
4. After compilation, uncompress the kip: `hactool -t kip1 Atmosphere/stratosphere/loader/out/nintendo_nx_arm64_armv8a/release/loader.kip --uncompress=./loader.kip`

</details>

---

## Acknowledgments

- CTCaer for [Hekate-ipl](https://github.com/CTCaer/hekate) bootloader, RE, and hardware research.
- [devkitPro](https://devkitpro.org/) for All-In-One homebrew toolchains.
- masagrator for [ReverseNX-RT](https://github.com/masagrator/ReverseNX-RT) and information on BatteryChargeInfoFields in psm module.
- Nvidia for [Tegra X1 Technical Reference Manual](https://developer.nvidia.com/embedded/dlc/tegra-x1-technical-reference-manual).
- RetroNX team for [sys-clk](https://github.com/retronx-team/sys-clk).
- SciresM and Reswitched Team for the state-of-the-art [Atmosphere](https://github.com/Atmosphere-NX/Atmosphere) CFW of Switch.
- Switchbrew [wiki](http://switchbrew.org/wiki/) for Switch in-depth info.
- Switchroot for their [modified L4T kernel and device tree](https://gitlab.com/switchroot/kernel).
- ZatchyCatGames for RE and original OC loader patches for Atmosphere.
- KazushiMe for [Switch OC Revitalized](https://github.com/Cod3xDev/Switch-OC-Revitalized).
- lineon for research and help.

---
