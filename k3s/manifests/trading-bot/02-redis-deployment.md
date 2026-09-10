# Redis Deployment

Redis Cache is a protocol that allows frequently requested data to be stored in RAM -- speeding up processes because the SSD does not have to be accessed as often for this type of data.
<br>In this project, Redis was included as a python library in the trading bot's code. In the cluster, the Redis Cache runs and manages the cache locally.

## Modification of Trading Bot
In order for Redis to work locally, the program being run (in this case, the trading bot) must include the `redis` python library and include the following lines:
```
import redis

host = os.getenv("REDIS_HOST", "redis")
port = int(os.getenv("REDIS_PORT", 6379))

r = redis.Redis(host=host, port=port)
```
The .env file must also include the redis host and port:
```
REDIS_HOST=redis
REDIS_PORT=6379
```
REDIS_HOST points to the redis container running locally on the cluster, while REDIS_PORT is the default port used by Redis.
<br><br>

## Redis Configuration and Deployment
A Redis Persistent Volume Claim (PVC) must be created in order for the module to function. In the current setup, 2gi (2048MB) are allocated to the Redis Cache.
<br><br>To create the YAML file, run, on the master node:
```
nano redis-pvc.yaml
```
The file is provided as `/k3s/manifests/trading-bot/redis-pvc.yaml`.
<br><br>Apply the claim to the cluster:
```
kubectl apply -f redis-pvc.yaml
```
To deploy Redis, another YAML file must be created:
```
nano redis-deployment.yaml
```
The file is provided as `/k3s/manifests/trading-bot/redis-deployment.yaml`.
<br><br>Apply the file:
```
kubectl apply -f redis-deployment.yaml
```
