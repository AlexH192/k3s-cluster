# K3s Cluster Setup
To turn the bare Ubuntu installation into the K3s master node, some installations steps must be taken.

## General setup after SSH

System packages and firmware updates:
```
sudo apt update && sudo apt dist-upgrade -y
fwupdmgr refresh
fwupdmgr get-updates
fwupdmgr update
```

Install homebrew:
```
* /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo >> /home/geriatricgoose/.bashrc
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"' >> /home/geriatricgoose/.bashrc
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"
```

Enable automatic security updates:
```
sudo apt install unattended-upgrades -y
sudo dpkg-reconfigure --priority=low unattended-upgrades
```

Set timezone to New York -- important for cron jobs & trading bot (runs on NY time):
```
sudo timedatectl set-timezone America/New_York
```

Enable Wake-on-LAN & make it persistent across reboots:
```
sudo ethtool -s enp2s0 wol g
sudo nano /etc/networkd-dispatcher/routable.d/wol
#!/bin/bash
ethtool -s enp2s0 wol g
sudo chmod +x /etc/networkd-dispatcher/routable.d/wol
```
Expand root partition storage from LVM's 50% to 100% in order to use all 128GB of the SSD drive:
```
sudo lvextend -l +100%FREE /dev/ubuntu-vg/ubuntu-lv
sudo resize2fs /dev/mapper/ubuntu--vg-ubuntu--lv
```

## Installation of Kubernetes K3s and Modules

Install K3s: `curl -sfL https://get.k3s.io | sh -`
Fix permissions so sudo isn't required each time a command is run:
```
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $USER:$USER ~/.kube/config
echo "export KUBECONFIG=~/.kube/config" >> ~/.bashrc
source ~/.bashrc
```

Save the node token that is returned for later.
<br>Install helm (package manager that helps installs run more cleanly):
```
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```
Install kubectl (command line tool for Kubernetes):
```
brew install kubectl
```
Install kubectl on the machine that is going to connect and control the cluster remotely using the same command.
<br>Verify the nodes are running correctly with `kubectl get pods -A`
<br>An example is shown below:
<br><img width="665" height="131" alt="kubectl get pods output" src="https://github.com/user-attachments/assets/06676286-0daf-4395-b848-766eb52ecad7" />

## Configuration of Web Dashboard Using Headlamp
A web dashboard was set up in order to monitor all nodes' tasks, temperature and activity.
'Headlamp' was the web dashboard of choice: https://github.com/kubernetes-sigs/headlamp

<br>Installation of Headlamp:
```
helm repo add headlamp https://kubernetes-sigs.github.io/headlamp/
helm install my-headlamp headlamp/headlamp --namespace kube-system
```

Get Headlamp token:
```
kubectl create token my-headlamp --namespace kube-system
```
Save this token for later use.

<br>To host the headlamp UI, port forward:
```
kubectl --namespace kube-system port-forward svc/my-headlamp 9191:80
```

Then open `http://127.0.0.1:9191/` and enter the Headlamp token.

<br>The Headlamp UI is shown in the images below.
<img width="1440" height="788" alt="• Hevolame" src="https://github.com/user-attachments/assets/a829d2c6-1fbc-4400-9e15-344b735d0f71" />
<img width="1440" height="782" alt="• Headlamp" src="https://github.com/user-attachments/assets/d62d9904-37f1-40fe-81d8-39f495e1a385" />
