# Automated PXE Booting (Installing OS on worker nodes)

On master node, install required services to become PXE server:
```sudo apt install dnsmasq tftpd-hpa nginx -y```

Set up TFTP boot files:
```sudo mkdir -p /var/lib/tftpboot```
```cd /var/lib/tftpboot```

Download ubuntu 24.04.4 ISO and getting UEFI bootloader:
```sudo wget https://releases.ubuntu.com/24.04.4/ubuntu-24.04.4-live-server-amd64.iso -O /tmp/ubuntu.iso```
```sudo mount -o loop /tmp/ubuntu.iso /mnt/iso```
```sudo cp /mnt/iso/casper/vmlinuz /var/lib/tftpboot/```
```sudo cp /mnt/iso/casper/initrd /var/lib/tftpboot/```

Configure the grub file for PXE:
```sudo mkdir -p /var/lib/tftpboot/grub```
```sudo nano /var/lib/tftpboot/grub/grub.cfg```
Contents:
```
set timeout=3
set default=0

menuentry "Ubuntu 24.04 Autoinstall" {
    linuxefi /vmlinuz \
        ip=dhcp \
        url=http://192.168.1.16/ubuntu.iso \
        autoinstall \
        ds=nocloud-net\;s=http://192.168.1.16/nocloud/ \
        noprompt \
        ---
    initrdefi /initrd
}
```

Serve ISO and install files over HTTP:
```sudo mkdir -p /var/www/html/nocloud```

Copy `user-data` and `meta-data` files to nginx `/var/www/html/nocloud`.
```sudo cp /usr/share/doc/cloud-init/examples/seed/user-data /var/www/html/nocloud/user-data```
```sudo cp /usr/share/doc/cloud-init/examples/seed/meta-data /var/www/html/nocloud/meta-data```

Serve ISO:
```sudo cp /tmp/ubuntu.iso /var/www/html/ubuntu.iso```

Enable and start nginx:
```sudo systemctl enable nginx```
```sudo systemctl start nginx```

With nginx running, boot secondary nodes that have PXE boot enabled. They will send a PXE request to this PXE server, which will then provide the autoinstall Ubuntu files. Nodes will install Ubuntu locally and headlessly.
