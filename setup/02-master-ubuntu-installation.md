# Master Node Ubuntu Installation

The Dell Wyse 5070 acts as the control plane and master node of the entire cluster. Because the other nodes rely on it for PXE booting, Ubuntu must first be manually installed on it via USB flash drive.

## Flashing Installer
The Ubuntu ISO is flashed onto the USB flash drive:
*   OS Version: Ubuntu 24.04.4 LTS Server from https://ubuntu.com/download/server
*   Tool Used: BalenaEtcher

## Installation Process
*   Boot Device Selection: After booting, repeatedly press the F2 key until UEFI appears. Navigate to the boot priority settings, and set the USB flash drive as the first priority (even above the SSD)
*   Storage Allocation: Accept the default LVM settings. Storage allocation is fixed in `05-k3s-cluster-setup.md`.
*   Network Setup: Leave on DHCP for now, Netplan is configured in `04-network-configuration.md`.
*   User Setup: Created the primary administrator account (`geriatricgoose`), which will be used for all Tailscale and Kubernetes authentication.
