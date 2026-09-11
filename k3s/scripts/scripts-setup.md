# Scripts Setup
The scripts located in this folder serve to streamline the sleep, start and health check processes; they eliminate the need to run every command separately.
<br><br>A new directory was created for scripts:
```
mkdir -p ~/k3s-cluster/k3s/scripts
```
After creating the scripts, they must be made executable:
```
chmod +x ~/k3s-cluster/k3s/scripts/*.sh
```
To test, run the `health-check.sh` script:
```
bash ~/k3s-cluster/k3s/scripts/health-check.sh
```
It should return a full health check, as shown below:
<img width="645" height="349" alt="image" src="https://github.com/user-attachments/assets/220c69fc-5892-446b-bcae-b5dc55285ce4" />
<img width="758" height="318" alt="image" src="https://github.com/user-attachments/assets/d248d298-0421-495c-ba97-53cbbfa7c1d8" />
<img width="532" height="186" alt="image" src="https://github.com/user-attachments/assets/979d4fc1-0581-4ce0-83ee-13c2427c72b6" />

