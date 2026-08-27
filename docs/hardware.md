# Hardware Configurations & Upgrades

**Upgrades Done:**
* +RAM
* +Storage
* -Wi-Fi card
* CMOS battery replacement

A stick of 4GB SO-DIMM RAM was installed in addition to the Dell Wyse 5070's existing 4GB stick, increasing the total memory capacity of this machine to 8GB. I decided to maximize the 5070's RAM because its role as the Kubernetes master node and main initial contact point for Tailscale/SSH has greater performance requirements. As the master node, it would also require a greater amount of storage than was present, so I installed an additional 128GB M.2 SSD in order to increase capacity.

Pictured below are the RAM and SSD components before installation, as well as the Dell Wyse 5070 after installation.

<img width="366" height="333" alt="SO-DIMM stick and SSD before installation" src="https://github.com/user-attachments/assets/c55aeca1-7d4d-43c0-a43e-c5b7b723f6b3" />
<img width="366" height="333" alt="Dell Wyse 5070 after installation" src="https://github.com/user-attachments/assets/303b3203-83f1-45c1-8e34-53646a1d2ca2" />


Another point of concern was the faulty Wi-Fi card the Dell Wyse 5070 came with. Due to header mismatch between the Wi-Fi card and the device, the machine would return the error message:

iwlwifi unable to change power state from d3cold to
hw_rev=0xFFFFFFFF, PCI issues?

As such, wireless internet was out of the option and I proceeded with uninstalling the Wi-Fi card in order to avoid future conflicts or error messages. The uninstalled Intel 7265 card is pictured below.

<img width="295" height="166" alt="Intel 7265 Wi-Fi card" src="https://github.com/user-attachments/assets/10c917a5-44a0-4131-864d-bb95def6884b" />

Diagnosed and solved a dead CMOS battery issue that was halting boot sequences, largely due to the hardware's age. 
