# Resolving Issues

**29/3/2026 | Issue 1: Wi-Fi Card Failed due to Incompatibility**
Error message returned upon checking status of Wi-Fi card:

!!! unknown header type 7f
interrupt: pin ? routed to IRQ 23
Region 0: memory at b2100000 (64-bit, non-prefetchable) [size=8K]
Kernel modules: iwlwifi
iwlwifi unable to change power state from d3cold to hw_rev=0xFFFFFFFF, PCI issues?

* Symptom: Wi-Fi functionality unavailable
* Cause: Wi-Fi card header is unknown to the motherboard, causing power to be cut off from the component, in turn leading to failure to communicate.
* Solution: Physically removed the incompatible card and pivoted to internet connection per ethernet instead of wireless.


**23/8/2026 | Issue 2: Headless Boot Stuck on BIOS Error Screen (CMOS/RTC)**
* Symptom: The node fails to boot headlessly after a power cycle, failing to boot into Linux and connecting to the network. Attaching a monitor reveals "Time-of-day not set" and "Incomplete System Configuration" BIOS errors requiring an F1 keypress to bypass.
* Cause: A faulty CMOS battery causes some BIOS settings to reset each boot -- including the Real-Time Clock (RTC) and System Config settings.
* Solution: Replaced the CR2032 3V coin cell battery on the motherboard; system-critical processes like RTC are now kept alive by the battery and headless booting is possible.


**26/8/2026 | Issue 3: Network Interface Power-Down**
* Symptom: Ethernet port LED is active during standby but turns off shortly after Ubuntu boots, it seems Ubuntu itself is killing network access.
* Cause: Linux kernel restricts the network card with PCIe power management and Energy Efficient Ethernet (EEE) states, causing it to shut down instantly after boot. Missing network config file caused Linux to have problems recognizing the network card.
* Solution: Appended `pcie_aspm=off pcie_port_pm=off` to kernel boot parameters. This was injected into the `autoinstall/user-data` file in order to rewrite `/etc/default/grub`. Created missing network config file naming and configuring the network card:

```bash
sudo bash -c 'cat << EOF > /etc/netplan/01-netcfg.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    enp2s0:
      dhcp4: true
EOF'
```


**27/8/2026 | Issue 4: PXE Boot on Secondary Nodes**
* Symptom: With the master node configured to act as the PXE server, worker nodes are not sending PXE requests.
* Cause: The PXE boot setting was disabled in the worker nodes' BIOS settings, causing them to boot straight into their existing operating system.
* Solution: Enabled PXE boot in both worker nodes' BIOS settings.


**27/8/2026 | Issue 5: Port 80 being intercepted, nginx blocked**
* Symptom: nginx was unable to run on port 80, and returned an error message.
* Cause: Another process, Traefik, was intercepting traffic to 192.168.1.16:80 as its own.
* Solution: Moved nginx to port 192.168.1.16:8888, a port with no other processes listening.
