# Node Network Configuration

Due to aggressive power-saving settings on this hardware, kernel and network configs changes must be made in order to create a stable connection.

## Kernel Parameter Injections (GRUB)
As mentioned in `docs/troubleshooting.md` issue 3:
Appended `pcie_aspm=off pcie_port_pm=off` to kernel boot parameters. This was injected into the `autoinstall/user-data` file in order to rewrite `/etc/default/grub`. 

## Netplan Configuration
As mentioned in `docs/troubleshooting.md` issue 3:
Created missing network config file naming and configuring the network card:

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
