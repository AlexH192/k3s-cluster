# Bot Usage

Now that the k3s cluster, Redis and Docker have been set up successfully, the bot can be deployed and run on the cluster. The most important commands for its usage are as follows:
<br><br>To run the trading bots (and start Redis Cache):
```
kubectl scale deployment redis-cache equities-bot commodities-bot --replicas=1 -n trading
```
To scale down the trading bot pods and Redis Cache (such as for sleep after market close):
```
kubectl scale deployment equities-bot commodities-bot redis-cache --replicas=0 -n trading
```
To perform a rollout (no downtime) restart of the trading bot pods:
```
kubectl rollout restart deployment equities-bot commodities-bot -n trading
```
To restart the Redis Cache:
```
kubectl rollout restart deployment redis-cache -n trading
```
To manually update the Docker image after a change is made in the trading bot code:
```
docker build --platform linux/amd64 -t alex2938e2/trading-bot:latest .
docker push alex2938e2/trading-bot:latest
```
This action is also automated via GitHub Actions as per `/TBD`
<br><br>The trading bot pods and Redis Cache are now running on their preferred nodes (The HP t630 and Wyse 5070, respectively), as shown in the image below. Live pods, nodes and IPs can be inspected using `kubectl get pods -n trading -o wide`:
<img width="917" height="76" alt="Pasted Graphic" src="https://github.com/user-attachments/assets/1f192439-838b-4f87-9b41-b2e441bd5196" />
<br><br>Live bot logs for the equities and commodities bots can be monitored using the two commands below:
```
#Equities Bot
kubectl logs -f deployment/equities-bot -n trading --tail=100
```
<img width="923" height="370" alt="image" src="https://github.com/user-attachments/assets/767ca5b9-b09b-4f68-9dba-422d658facf2" />

```
# Commodities Bot
kubectl logs -f deployment/commodities-bot -n trading --tail=100
```
<img width="606" height="201" alt="image" src="https://github.com/user-attachments/assets/35ba79f7-a4ad-4470-9c91-0de06d7e5d83" />
