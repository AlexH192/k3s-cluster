# Bot Deployment

Similar to Redis, the trading bot itself also needs a deployment YAML file. This is done below.
<br><br>To create the file, run:
```
nano bot-deployment.yaml
```
The file is provided as `/k3s/manifests/trading-bot/bot-deployment.yaml`.
<br><br>Apply the file by running:
```
kubectl apply -f bot-deployment.yaml
```
The trading bot contains two sub-bots: one for trading equities, and another for trading commodities on a longer timeframe. To avoid causing a full crash if one of the bots crashes, they are separated into two separate docker containers, meaning two instances will run on the worker node, one with each bot.
<br><br>Docker and container management will be covered in `/k3s/manifests/trading-bot/05-docker-deployment.md`.
