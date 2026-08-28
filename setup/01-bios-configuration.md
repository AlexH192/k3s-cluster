# BIOS & Firmware Configuration

Before installing Ubuntu or attempting connection, specific UEFI/BIOS settings must be configured on each node to allow headless operation and external boot media (in my case: PXE booting).

## Boot Sequence Requirements
* Secure Boot: **Disabled**; unnecessary for the home-server setup and might cause conflicts with programs. Linux kernel updates may cause secure boot to break the setup.
* Boot Mode: **UEFI**; standard for modern server setups. Increases security and support for drives.
* Fast Boot: **Disabled**; fast boot conflicts with Wake-on-LAN, a feature this cluster relies on for power management. It also conflicts with PXE booting, another feature relied upon for the installation of OS on worker nodes.

## Power Management Config
* Deep Sleep Control: **S4/S5 Sleep Disabled**; S4/S5 sleep shuts the network card off completely during sleep, preventing Wake-on-LAN.
* Wake on LAN: **Enabled**; Wake-on-LAN allows for power saving during development. Instead of keeping the server running, it can be put to sleep and woken up from anywhere with one command.
* Power On After Power Loss: **Enabled**; critical to maintain server's uptime if power loss occurs, it will reboot automatically and continue running containers without human intervention.
