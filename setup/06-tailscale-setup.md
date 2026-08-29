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

<br>Verify the nodes are running correctly with `kubectl get pods -A`
<br>An example is shown below:
<img width="665" height="131" alt="kubectl get pods output" src="https://github.com/user-attachments/assets/06676286-0daf-4395-b848-766eb52ecad7" />
