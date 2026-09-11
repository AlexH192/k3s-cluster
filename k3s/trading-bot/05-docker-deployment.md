# Docker Deployment

Docker is used in this project to containerize processes and simplify code deployments. The k3s cluster will pull files from the docker image instead of storing the bot locally, and be able to package processes into containers, which are then able to run on their designated nodes (and be moved around if necessary during load management/outages).

## Account & Setup
An Docker account is required in order to use the service. Upon creating an account, save the username. In my case, the username used is `alex2938e2`.
<br><br>Docker must be installed locally on the device containing the trading bot files. Using home-brew, install the Docker module:
```
brew install --cask docker
```
The desktop app is required; launch it to start the daemon.
<br>The terminal located in the folder containing the trading bot must now be connected to docker:
```
docker login
```
Upon being prompted, log into Docker via browser.

# Deployment
In the trading bot folder terminal, create the .dockerignore file to ignore sensitive/unnecessary files:
```
nano .dockerignore
```
The contents are as follows:
```
.env
.git
.gitignore
__pycache__/
*.pyc
*.pyo
*.pyd
.DS_Store
venv/
.venv/
```
Create the Dockerfile:
```
nano Dockerfile
```
The contents are as follows:
```
FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["python", "bot_intraday_etfs.py"]
```
When building docker images linux/amd64 builds must be targeted specifically, especially on Mac devices. Since MacOS builds docker images for arm64 and not linux/amd64, crashes may be caused if images are built with default settings.
<br><br>Build the docker image using buildx and targeting linux/amd64:
```
docker build --platform linux/amd64 -t alex2938e2/trading-bot:latest .
```
^^where alex2938e2 is the Docker username.
<br><br>Push the image:
```
docker push alex2938e2/trading-bot:latest
```
