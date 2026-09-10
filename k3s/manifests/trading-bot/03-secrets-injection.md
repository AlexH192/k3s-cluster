# Secrets Injection & Management

Some sensitive information, such as API keys and passwords, are required to run the trading bot on the cluster. Since it is unsafe to store these credentials locally, however, they must be injected via secrets.
<br><br>All secrets are managed in the `trading` namespace under the `bot-secrets` object.

