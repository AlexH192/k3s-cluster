# Bare-metal K3s Cluster & Trading Bot Infrastructure
## TODO: IMPLEMENT NODE FAILOVER W/ HEARTBEAT, TESTING NODE DEATHS WITH CHAOSMONKEY***
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
## Capabilities and Features
* **No-touch OS installation and provisioning:** The worker nodes' operating systems are set up completely automatically via PXE boot and the injected network configuration settings. Once set up, they automatically request (and are assigned) an IP, connecting them to the rest of the network and, most importantly, the master node.
* **Trading bot run via K3s:** Containerizing the trading bot application allows for better management of computing power and gives access to advanced failover features. When a pod crashes, Kubernetes instantly detects and restarts it in order to maintain maximum uptime. When an update to the trading bot is pushed to the node, Kubernetes executes a rolling update in order to minimize downtime and verify the health of new scripts before deployment.
* **Node Failover:** If one of the nodes suffers a power failure or crashes in some way, the pods running on it are evicted automatically and moved to a healthy node, in turn further strengthening uptime even when encountering full system failures.
* **Outsourced Workload:** The trading bot runs in a Python script locally while trade executions, live market data and news headlines are pushed/pulled via external API calls.

## Architectural Decisions
* Since the trading bot relies on the Google Gemini API for part of its vital decisions and logic, I initially evaluated running a local quantized LLM (Gemma 2B) directly on the nodes in order to lessen dependency on external APIs. After evaluation of the hardware available to me, however, it was revealed that running a local LLM model would yield unacceptable latency of >20s. This is not exactly optimal for time-bound trading decisions, therefore I decided that API calls were still the best course of action.
* Tailscale and SSH are the main ways to access the cluster, as opposed to local video-based access. The benefits of this decision are twofold:
  * Due to the headless design of the cluster, physically connecting to the node for access defeats the whole purpose, and would not be viable in a large-scale enterprise environment.
  * Remote access is now possible from anywhere with an internet connection. Previously, one could only connect from the same network. With Tailscale, SSH is now available from anywhere, allowing for remote troubleshooting and modification.
 
