# Cron Setup

Cron jobs are used to wake the cluster up before market open and put it to sleep after market close. They allow for complete automation and power-saving.
<br><br>First, check that the timezone in use is correct:
```
timedatectl
```
This should return `Time zone: America/New_York (EDT, -0400)`.
<br><br>Set up cron jobs:
```
sudo crontab -e
```
When prompted, select nano as the editor. Add these lines to the document:
```
# Wake cluster at 9:25 AM Monday-Friday (before market open)
25 9 * * 1-5 /home/admin/k3s-cluster/k3s/scripts/wake.sh >> /var/log/k3s-wake.log 2>&1

# Sleep cluster at 4:05 PM Monday-Friday (after market close)
5 16 * * 1-5 /home/admin/k3s-cluster/k3s/scripts/sleep.sh >> /var/log/k3s-sleep.log 2>&1
```
The wake and sleep scripts from `k3s/scripts/` are used.
