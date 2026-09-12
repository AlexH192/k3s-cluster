# GitHub Actions CI/CD Pipeline Setup
Currently, if any change is made to the trading bot python files, the docker image must be rebuilt manually and the nodes restarted, which is both time consuming and inefficient. With the use of a CI/CD pipeline, any change to the trading bot's GitHub repository will automatically be reflected in the k3s deployment too. A Telegram notification is also sent after each deployment, indicating its status and success. The process will work as follows:
```
1. Changes pushed to GitHub repo's main branch
2. GitHub Actions builds a new Docker image
3. New image is pushed to Docker Hub (alex2938e2/trading-bot)
4. Rolling update on cluster is attempted
5. If cluster is asleep, update is queued for next wakeup
6. Wake.sh checks for pending update and applies it.
```
First, secrets must be added to the trading bot GitHub repo. This is done by navigating to `Settings > Secrets and Variables > Actions > New Repository Secret`.
<br>The secrets added are: `DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN`, `TAILSCALE_AUTHKEY`, `TELEGRAM_BOT_TOKEN`, `TELEGRAM_CHAT_ID` (a new Telegram bot should be created for this).
<br><br>Creating workflow directory and deployment:
```
mkdir -p ~/k3s-cluster/.github/workflows
nano ~/k3s-cluster/.github/workflows/deploy.yml
```
The contents of this file are in `/k3s/trading-bot/github-workflow-deployment.yaml`.
<br><br>Clone the trading bot GitHub repo onto the master node:
```
cd ~
git clone https://github.com/AlexH192/Python-trading-bot-Alpaca-Gemini-Currents.git
cd Python-trading-bot-Alpaca-Gemini-Currents
```
<br><br>Generate a SSH key for GitHub Actions to access the cluster:
```
ssh-keygen -t ed25519 -C "github-actions" -f ~/.ssh/github-actions -N ""
```
Add the public key to the authorized keys:
```
cat ~/.ssh/github-actions.pub >> ~/.ssh/authorized_keys
```
View and save the private key:
```
cat ~/.ssh/github-actions
```
Add the private key `SSH_PRIVATE_KEY` as a GitHub secret, as done with Docker Hub and Tailscale above.
<br>Add the Dockerfile and .dockerignore to the local repo:
```
cd ~/Python-trading-bot-Alpaca-Gemini-Currents
nano Dockerfile
nano .dockerignore
```
The contents of the Dockerfile and .dockerignore are in `/k3s/trading-bot`.
<br><br>Push the workflow:
```
cd ~/k3s-cluster
git add .github/workflows/deploy.yml
git commit -m "Add CI/CD pipeline with queued deployment support"
```
To create the CI/CD pipeline, a GitHub personal access token must be generated. To do this, navigate to `Profile > Settings > Developer Settings > Personal access tokens > Tokens (classic) > Generate new token (classic)`. Then, check the 'repo' and 'workflow' boxes. Generate and copy the token.
<br><br>On the master node, run the push command:
```
git push origin main
```
When prompted, enter the GitHub username and paste the token as the password.
<br><br>Have Git cache the token permanently:
```
git config --global credential.helper store
```
The success of the push can be monitored in the Actions tab of the GitHub repo. Once successful, it should look like the image below:
<img width="699" height="333" alt="image" src="https://github.com/user-attachments/assets/8505ee5a-0f8c-42d9-beea-c1efbf6439e9" />
<br>Every time the GitHub repo is updated now (whether that be locally with Git or from the web interface), the GitHub CI/CD pipeline builds a new docker image, pushes it to Docker Hub, and executes a rolling update on the cluster. A Telegram notification is sent via the GitHub status bot created on Telegram. A success notification is shown in the image below.
<br><img width="434" height="92" alt="image" src="https://github.com/user-attachments/assets/ea5b4a07-023a-4c35-9dcb-d6a8dd3c983c" />

<br><br>One of the advantages of using the GitHub Actions CI/CD pipeline is that uptime is guaranteed with rolling updates. Additionally, if the code for only one of the trading bots is updated (for example: commodities bot), then only that bot's pod/container needs to restart.
