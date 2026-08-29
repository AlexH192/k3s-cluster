# Power Management & Miscellaneous

Wake-on-LAN was enabled and made persistent in `05-cluster-setup.md`.

<br><br>To wake nodes up, the MAC address of their network controllers is needed. To find this:
* Run `ip -br link` to find the logical name of the device's network card. The name should start with 'en'.
* Run `ip link show [network card's logical name]`. In my case: `ip link show enp2s0`. This will return the MAC address in the form `xx:xx:xx:xx:xx:xx`.

<br>Wake-on-LAN commands are as follows:
To put system to sleep, run (while connected via SSH): `sudo systemctl suspend`
To wake system up, run (in a terminal window on the external device connected via Tailscale): `wakeonlan [MAC address here]`

<br><br>After the system wakes up, SSH connection can be performed via `ssh username@hostname` (in my case: `ssh geriatricgoose@k3s-master`).
