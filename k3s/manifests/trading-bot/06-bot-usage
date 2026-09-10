# Bot Usage

Now that the k3s cluster, Redis and Docker have been set up successfully, the bot can be deployed and run on the cluster. The most important commands for its usage are as follows:
<br><br>To run the trading bots (and start Redis Cache):
```
kubectl scale deployment redis-cache equities-bot commodities-bot --replicas=1 -n trading
```
To scale down the trading bot pods and redis cache (such as for sleep after market close):
```
kubectl scale deployment equities-bot commodities-bot redis-cache --replicas=0 -n trading
```
