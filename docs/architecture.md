# Cluster Architecture & Design

This document details the physical, network, and software layers of the cluster.

## Hardware & Topology
Since this cluster pairs low-power thin clients with higher performance ones, workload is split amongs them based on their respective capacities.

* **Master Node (Dell Wyse 5070):** Acts as the K3s server and local infrastructure host (dnsmasq, Nginx, Prometheus). Also hosts the PXE server during setup.
* **Worker Node 1 (Dell Wyse 3040):** Limited to 2GB RAM and 8GB eMMC storage. Dedicated to lightweight Traefik routing and the Headlamp UI dashboard.
* **Worker Node 2 (HP t630):** Limited to 4GB RAM and a 16GB eMMC storage. Wholly dedicated to running the trading bot script by default.

```mermaid
graph TD
    %% External APIs
    subgraph External APIs
        A[Alpaca WebSocket]
        B[Currents API]
        C[Gemini API]
    end

    %% Network Layer
    subgraph Local Network 192.168.1.0/24
        R[Local Router] --> S[Gigabit Switch]
    end

    %% K3s Cluster
    subgraph K3s Cluster
        S -->|192.168.1.16| M(Dell Wyse 5070<br/>Master Node)
        S -->|192.168.1.17| W1(Dell Wyse 3040<br/>Worker 1)
        S -->|192.168.1.18| W2(HP t630<br/>Worker 2)

        %% Node Specs & Workloads
        subgraph 128GB SSD / 8GB RAM
            M -.- M1[K3s Control Plane]
            M -.- M2[PXE, dnsmasq, Nginx]
            M -.- M4[(Prometheus Data)]
        end

        subgraph 8GB eMMC / 2GB RAM
            W1 -.- W1_1[Traefik Routing]
            W1 -.- W1_2[Headlamp UI]
        end

        subgraph 16GB eMMC / 4GB RAM
            W2 -.- W2_1[Trading Bot Pod]
        end
    end

    %% Data Flow
    W2_1 -->|Subscribes| A
    W2_1 -->|Polls| B
    W2_1 -->|Executes Trades| A
    W2_1 -->|Sends Prompt, Receives Response| C
```



## Network Port Allocation
abc
## Headless OS installation
New nodes are provisioned completely automatically via a PXE server/Cloud-init method:
1. **POST & DHCP:** Node powers on, UEFI program broadcasts on `192.168.1.0/24`, looking for a PXE boot file (since PXE boot is enabled).
2. **Proxy-DHCP:** Master node (`dnsmasq`) offers the PXE boot file and points to the TFTP (file) server.
3. **HTTP Fetch:** GRUB loads the Ubuntu kernel over HTTP, taken from the master node's nginx.
4. **Cloud-init:** The `user-data` file executes disk partitioning, sets Netplan static IP, injects SSH credentials and reboots the now fully installed OS.

## 3. High Availability & Failover Mechanics
To ensure the automated trading bot does not drop its Alpaca WebSocket connection during market hours:
* **Pod Eviction:** The K3s controller monitors worker node health. If a node suffers a failure, its workloads are evicted and rescheduled onto another node.
* **State Resilience:** No trading state is kept in the pod's local memory; all order histories are stored in external JSON files on the master node's storage.

## 4. External Integrations
* **Alpaca API:** Real-time market data WebSocket and trade execution.
* **Currents API:** REST polling for financial news sentiment analysis on tech equities. Mainly used to generate pre- and post-market summaries.
* **Gemini API:** Controls logic and final decision-making on trades. Ingests live data and strict parameters from the python script.
* **Telegram Bot:** Sends pre- and post-market briefings, as well as daily summaries and trade execution alerts to user via push-notification.
