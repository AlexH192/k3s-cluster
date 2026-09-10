# Bare-metal Kubernetes K3s Cluster & Trading Bot Infrastructure
This project is a three-node, bare-metal Kubernetes cluster built on repurposed enterprise thin clients, featuring automated PXE OS installation & configuration, Wake-on-LAN power management and high-availability architecture to ensure maximum uptime.

The cluster serves as the infrastructure for a custom algorithmic stock trading bot tracking equities and commodities, placing trades via an API connection.
<a href="https://github.com/AlexH192/Python-trading-bot-Alpaca-Gemini-Currents.git" target="_blank" rel="noopener noreferrer">Trading Bot Repository</a>

## Architecture and Topology
The physical cluster consists of three repurposed thin-client computers connected via an unmanaged 8-port gigabit switch. The most powerful computer, a Dell Wyse 5070, is used as the main access point and control plane (master node). It also serves as the PXE boot server that provisions the two other worker nodes over the network upon first setup.
When hosting the trading bot, the server also contacts external APIs to pull information, execute trades and send notifications.

<br>The general architecture diagram is depicted below.

```
                                  ┌─────────────────────────┐
                                  │   External Cloud APIs   │
                                  │ (Alpaca, Currents API)  │
                                  └────────────▲────────────┘
                                               │
┌──────────────┐     ┌──────────────┐          │
│ Local Router ├─────►Gigabit Switch├──────────┘
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
 │ PXE Server Host│ │ Headlamp UI    │ │ (by default).  |
 │ Prometheus     | |                | |                |
 └────────────────┘ └────────────────┘ └────────────────┘
```
**A more detailed architecture diagram can be found in `/docs/architecture.md`!**
<br><br>The fully connected and powered cluster is shown below:
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
 
* `/photos` contains pictures of the hardware and setup processes.
 
* `/setup` contains documentation on how each part of the system was set up, step-by-step.

* `/k3s/manifests` contains cluster data post-installation.
  * `/network-configs`: Contains netplan configurations and ingress rules
  * `/trading-bot`: Contains YAML files for bot deployment, along with documentation on the setup of Kubernetes, Docker and configuration of the trading bot.
  * `/monitoring`: Contains the YAML file for the deployment of Prometheus, along with documentation.
 
## Node Hardware Specifications
Each node is a different model of thin client with different specifications, meaning considerations regarding performance and workload had to be be made so as not to overload any of the systems.
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
## Cost Breakdown
Most parts were purchased second-hand from individuals who had previously used them in enterprise environments. The cost breakdown, in Singapore Dollars, is below.


```
 Component                                                                     | Cost   | Source
---------------------------------------------------------------------------------------------------------
Dell Wyse 5070 + Dell Wyse 3040                                                |  S$120  |  Carousell
---------------------------------------------------------------------------------------------------------
HP t630 + 4GB RAM upgrade + 128GB SSD upgrade                                  |  S$55   |  Carousell
---------------------------------------------------------------------------------------------------------
Cisco 8-port Gigabit switch                                                    |  S$10   |  Carousell
---------------------------------------------------------------------------------------------------------
CMOS battery replacement                                                       |  S$7    |  Local Store
---------------------------------------------------------------------------------------------------------
4x CAT6 Ethernet Cable                                                         |  S$4.48 |  Online Store
---------------------------------------------------------------------------------------------------------
Miscellaneous costs (6-plug 2-meter power strip, DisplayPort to HDMI adapter)  |  S$10.17|  Online Store
---------------------------------------------------------------------------------------------------------

Total                                                                             S$206.65
```

Equivalent cloud infrastructure (3 nodes with ~150GB storage, 12GB RAM and load balancing) can cost upwards of $120 per month, plus miscellaneous fees, on cloud providers like AWS. This cluster offers superior control while essentially paying for itself in under two months.

## Capabilities and Features
* **Fully remote/automatic OS installation and provisioning:** The worker nodes' operating systems are set up completely automatically via PXE boot and the injected network configuration settings. Once set up, they automatically request (and are assigned) an IP, connecting them to the rest of the network and, most importantly, the master node.
* **Trading bot run via K3s:** Containerizing the trading bot application allows for better management of computing power and gives access to advanced failover features. When a pod crashes, Kubernetes instantly detects and restarts it in order to maintain maximum uptime. When an update to the trading bot is pushed to the node, Kubernetes executes a rolling update in order to minimize downtime and verify the health of new scripts before deployment.
* **Node Failover:** If one of the nodes suffers a power failure or crashes in some way, the pods running on it are evicted automatically and moved to a healthy node, in turn further strengthening uptime even when encountering full system failures.
* **Outsourced Workload:** The trading bot runs in a Python script locally while trade executions, live market data and news headlines are pushed/pulled via external API calls.

## Architectural Decisions
* Since the trading bot relies on the Google Gemini API for part of its vital decisions and logic, I initially evaluated running a local quantized LLM (Gemma 2B) directly on the nodes in order to lessen dependency on external APIs. After evaluation of the hardware available to me, however, it was revealed that running a local LLM model would yield unacceptable latency of >20s. This is not exactly optimal for time-bound trading decisions, therefore I decided that API calls were still the best course of action.
* Tailscale and SSH are the main ways to access the cluster, as opposed to local video-based access. The benefits of this decision are twofold:
  * Due to the headless design of the cluster, physically connecting to the node for access defeats the whole purpose, and would not be viable in a large-scale enterprise environment.
  * Remote access is now possible from anywhere with an internet connection. Previously, one could only connect from the same network. With Tailscale, SSH is now available from anywhere, allowing for remote troubleshooting and modification.
 
## Troubleshooting and Lessons Learned
Six significant issues were encountered, solved and documented in total, the most significant of which were related to headless networking (as documented in `/docs/troubleshooting.md`):
* Headless network connection failed due to misconfigured netplan file
* Network interface perpetual low-power state due to misconfigured boot parameters


<br>During the long process of diagnosing and solving the issues, it was made clear that even one small mistake in the network configuration settings, YAML deployment files or trading bot code can cause a complete outage. Default configurations, both in UEFI and Linux, are likely to cause issues so special care must be taken in the initial configuration process.
<br><br>Another major hurdle was the correct identification of issues in the first place-- with the completely headless design, these issues often resulted in disconnects, making it difficult to diagnose. Some issues could only be resolved with access to a video output source. This may not be possible in many environments, therefore I learned that changes must be made carefully and incompatibilities resolved fully before applying anything.
