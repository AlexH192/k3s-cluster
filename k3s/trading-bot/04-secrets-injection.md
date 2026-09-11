# Secrets Injection & Management

Some sensitive information, such as API keys and passwords, are required to run the trading bot on the cluster. Since it is unsafe to store these credentials locally, however, they must be injected via secrets using Secure Copy Protocol (scp).
<br><br>All secrets are managed in the `trading` namespace under the `bot-secrets` object.
<br>Using Secure Copy Protocol (scp), the .env file containing all API keys and other sensitive information is copied onto the master node’s home directory.
In a separate terminal in the folder containing the trading bot, run:
```
scp '/Users/alex/Desktop/stock api python/New/BOT/.env' admin@192.168.1.16:~/.env
```
On the master node, create the secret and delete the .env file:
```
kubectl create secret generic bot-secrets --from-env-file=~/.env --namespace trading
rm ~/.env
```
The secrets object containing the API keys now runs securely on k3s, separated from the code and processes.
