# Tailscale Setup
Tailscale is critical due to the headless design of this server. It allows for SSH access from anywhere without having to risk port forwarding from the router (which can be risky).

!!!!!Include everything on tailscale in the notes, stuff in between



Configure kubectl to eliminate need for SSH and let Tailscale handle authentication (This feature is finished in `05-tailscale-setup.md`):
```
scp geriatricgoose@k3s-master:/home/geriatricgoose/.kube/config ~/.kube/config
```
^^ where geriatricgoose is the username and k3s-master is the master node's name.

<br>Verify the nodes are running correctly with `kubectl get pods -A`
