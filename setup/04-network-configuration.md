# Node Network Configuration

Due to aggressive power-saving settings on this hardware, kernel and network configs changes must be made in order to create a stable connection. Static IP addresses should also be assigned to all nodes to further ensure stability.

## Kernel Parameter Injections (GRUB)
As mentioned in `docs/troubleshooting.md` issue 3:
<br>Appended `pcie_aspm=off pcie_port_pm=off` to kernel boot parameters. This was injected into the `autoinstall/user-data` file in order to rewrite `/etc/default/grub`. 

## Netplan Configuration
As mentioned in `docs/troubleshooting.md` issue 3:
<br>Created missing network config file naming and configuring the network card:

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
 **Application:** `sudo netplan apply`

## Static IP Address Assignment
Each of the three nodes should be assigned a static IP address in order to ensure stability and ease of access. To do this:

* Log into the home router's admin panel
* Navigate to the DHCP Reservations section
* Add the MAC address of each node and assign it a static IP. Note that this IP must be outside of the general DHCP pool to avoid clashes.
* Reboot all nodes.

On the node:
* Configure static IP by changing netplan file as in `k3s/manifests/networking-configs`.
* Run `sudo netplan apply` to apply changes.
