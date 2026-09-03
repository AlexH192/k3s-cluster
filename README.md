# Bare-metal K3s Cluster & Trading Bot Infrastructure

This project is a three-node, bare-metal Kubernetes cluster built on repurposed enterprise thin clients, featuring automated PXE OS installation & configuration, Wake-on-LAN power management and high-availability architecture to ensure maximum uptime.

The cluster serves as the infrastructure for a custom algorithmic stock trading bot tracking equities and placing trades via API connections.
<a href="https://github.com/AlexH192/Python-trading-bot-Alpaca-Gemini-Currents.git" target="_blank" rel="noopener noreferrer">Trading Bot Repository</a>

## Architecture & Topology
The physical cluster consists of three repurposed thin-client computers connected via an unmanaged 8-port gigabit switch. The most powerful computer, a Dell Wyse 5070, is used as the main access point and control plane (master node). It also serves as the PXE boot server that provisions the two other worker nodes over the network.
When hosting the trading bot, the server also contacts external APIs to pull information, execute trades and send notifications.

<br>The general architecture diagram is depicted below.

```
                                  ┌─────────────────────────┐
                                  │   External Cloud APIs   │
                                  │ (Alpaca, Currents API)  │
                                  └────────────▲────────────┘
                                               │
┌──────────────┐     ┌──────────────┐          │
│ Local Router ├─────► Gigabit Switch ├────────┘
└──────────────┘     └──────┬───────┘
                            │
          ┌─────────────────┼─────────────────┐
          │                 │                 │
 ┌────────▼───────┐ ┌───────▼────────┐ ┌──────▼─────────┐
 │ Master Node    │ │ Worker Node 1  │ │ Worker Node 2  │
 │ Dell Wyse 5070 │ │ Dell Wyse 3040 │ │ HP t630        │
 │ 192.168.1.16   │ │ 192.168.1.17   │ │ 192.168.1.18   │
 ├────────────────┤ ├────────────────┤ ├────────────────┤
 │ K3s Server     │ │ K3s Agent      │ │ K3s Agent      │
 │ Nginx & dnsmasq│ │ Traefik Router │ │ Trading Bot    │
 │ PXE Server Host│ │ Headlamp UI    │ │ xxxxxxxxxxx.   |
 │                | |                | | Prometheus     |
 └────────────────┘ └────────────────┘ └────────────────┘
```
<br>The fully connected and powered cluster is shown below:
<br><br><img width="350" height="630" alt="IMG_6842 (1)" src="https://github.com/user-attachments/assets/b9831bb4-49cd-4fa5-a63f-64dee60c89a5" />
<img width="350" height="630" alt="IMG_6845" src="https://github.com/user-attachments/assets/c96282d4-322d-4f43-bf1d-46033729d786" />

## Repository Structure
This repository separates OS-level setup and hardware configuration documents from the Kubernetes configurations.

* `/autoinstall` contains the files required for the headless installation of Linux Server:
  * `grub.cfg`: Boot menu configuration
  * `user-data` and `meta-data`: Cloud-init files for automatic disk formatting, OS installation, user setup and network settings
 
* `/docs` contains general documentation about the physical cluster and troubleshooting steps.
  * `architecture.md`: Exact representation of the cluster's hardware and software architecture.
  * `hardware-upgrades.md`: List of hardware upgrades made to each machine in the cluster.
  * `troubleshooting.md`: Documentation on every issue encountered and how these issues were solved.
 
* `/photos` contains pictures of the design and setup processes.
 
* `/setup` contains documentation on how each part of the system was set up, step-by-step.

* `/k3s/manifests` contains cluster data post-installation.
  * `/networking`: Contains netplan configurations and ingress rules
  * `/monitoring`: Contains YAML files for Headlamp, Prometheus, etc.
 
## Node Hardware Specifications
```
Node Role  |  Hardware Model  |  CPU          |  RAM    |  Storage
--------------------------------------------------------------------
Master     |  Dell Wyse 5070  | Intel Pentium | 8GB DDR4| 128GB SSD
Node       |                  | Silver J5005  |         |      
--------------------------------------------------------------------
Worker     |  Dell Wyse 3040  | Intel Atom    | 2GB DDR3| 8GB eMMC
Node 1     |                  | x5-Z8350      |         |
--------------------------------------------------------------------
Worker     |  HP t630         | AMD GX-420GI  | 4GB DDR4| 16GB eMMC
Node 2     |                  |               |         |

```
