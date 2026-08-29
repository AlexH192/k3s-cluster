# Tailscale Setup
Tailscale is critical due to the headless design of this server. It allows for SSH access from anywhere without having to risk port forwarding from the router (which can be risky).
<br>Tailscale should be installed on every node in the k3s cluster. If a node goes down, it can be connected to individually instead of having to control it from the master node.
<br>Note that Tailscale requires an account to function. The desktop app can be used to connect to the cluster from an external device.

## General Setup
Install Tailscale:
```
curl -fsSL https://tailscale.com/install.sh | sh
```

Authenticate Tailscale:
```
sudo tailscale up
```
Copy the authentication URL, open it in a browser and log in to authorize the node.

## Tailscale Configuration
Configure kubectl (installed in `05-k3s-cluster-setup.md`) to eliminate need for SSH and let Tailscale handle authentication:
```
scp geriatricgoose@k3s-master:/home/geriatricgoose/.kube/config ~/.kube/config
```
^^ where geriatricgoose is the username and k3s-master is the master node's name (hostname).
<br><br>Modify the `/etc/systemd/system/k3s.service` file to include the node's Tailscale IP:
```
sudo nano /etc/systemd/system/k3s.service
```
To the ExecStart variables, append the tailscale IP with `—tls-san [IP here]` so the ExecStart lines look as follows:
```
ExecStart=/usr/local/bin/k3s \
    server \
        --tls-san [IP here]
```
Restart systemd daemon and k3s to apply the changes:
```
sudo systemctl daemon-reload
sudo systemctl restart k3s
```
With kubectl installed and Tailscale connected (optimally via the desktop app) on the external device, commands can now be run on the cluster without the need to SSH in:
<br><img width="600" height="56" alt="kubectl get nodes example" src="https://github.com/user-attachments/assets/e2e30156-4670-4036-a8d2-176a0ac520ae" />
