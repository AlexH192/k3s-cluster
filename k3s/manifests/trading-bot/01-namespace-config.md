# Namespace Setup and Configuration

For all three nodes to work coherently in a k3s cluster, a namespace must be created.
This separates the workload (trading bot) from system resources and allows for a more organized setup and troubleshooting experience.

## Namespace Creation
The master node has the role `<control-plane>`. This means it is the access point for any configuration to the k3s cluster.
<br><br>On the master node, run the following command to create the 'trading' namespace:
```
kubectl create namespace trading
```
Verify the namespace exists and is empty with:
```
kubectl get namespaces
sudo k3s kubectl get all -n trading
```

## Hardware Label Assignment
In order to function correctly, hardware labels must be assigned to each of the nodes. Hardware labels point the system to the correct node.
<br><br>On the master node, run:
```
kubectl label nodes hp-t630 hardware=hp-t630
kubectl label nodes wyse-3040 hardware=wyse-3040
```
The two worker nodes are now configured to run on the k3s cluster.
