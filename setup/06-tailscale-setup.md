

Configure kubectl to eliminate need for SSH and let Tailscale handle authentication (This feature is finished in `05-tailscale-setup.md`):
```
scp geriatricgoose@k3s-master:/home/geriatricgoose/.kube/config ~/.kube/config
```
^^ where geriatricgoose is the username and k3s-master is the master node's name.

<br>Verify the nodes are running correctly with `kubectl get pods -A`
