
# Hardware Configurations & Upgrades

**Upgrades Done:**
* +RAM
* +Storage
* -Wi-Fi card
* CMOS battery replacement

A stick of 4GB SO-DIMM RAM was installed in addition to the Dell Wyse 5070's existing 4GB stick, increasing the total memory capacity of this machine to 8GB. I decided to maximize the 5070's RAM because its role as the Kubernetes master node and main initial contact point for Tailscale/SSH has greater performance requirements. As the master node, it would also require a greater amount of storage than was present, so I installed an additional 128GB M.2 SSD in order to increase capacity.

Pictured below are the RAM and SSD components before installation, as well as the Dell Wyse 5070 after installation.

<img width="394" height="222" alt="4GB SO-DIMM RAM stick and 128GB SSD" src="https://github.com/user-attachments/assets/bc046d58-bebb-4be8-a0c5-19e5afbdc558" />
<img width="3294" height="3003" alt="IMG_5675" src="https://github.com/user-attachments/assets/303b3203-83f1-45c1-8e34-53646a1d2ca2" />





<img width="1182" height="666" alt="HP t630 before part swap" src="https://github.com/user-attachments/assets/0fe295a4-770b-43fd-9779-601f54cd3766" />



Mention swapping/upgrading parts, installing WiFi chip, with photos.

<img width="1182" height="666" alt="Intel 7265 Wi-Fi card" src="https://github.com/user-attachments/assets/10c917a5-44a0-4131-864d-bb95def6884b" />

Diagnosed and solved a dead CMOS battery issue that was halting boot sequences, largely due to the hardware's age. 
