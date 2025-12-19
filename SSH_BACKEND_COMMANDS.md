# Backend Server Inspection Commands
**Server:** 69.62.72.155  
**Access:** `ssh root@69.62.72.155`  
**Password:** Angelraz@980

---

## 🔐 Connect to Server

```bash
ssh root@69.62.72.155
# Password: Angelraz@980
```

---

## 📊 System Information

### Check Server Resources
```bash
# CPU and Memory usage
htop
# or
top

# Disk usage
df -h

# Memory info
free -h

# Uptime
uptime

# System info
uname -a
lsb_release -a
```

---

## 🚀 Application Status

### Find Node.js/PM2 Processes
```bash
# Check if PM2 is running
pm2 status
pm2 list
pm2 logs --lines 100

# Or check Node processes
ps aux | grep node

# Check all running services
systemctl list-units --type=service --state=running | grep -E 'node|api|app'
```

### Application Location
```bash
# Common locations for Node apps
ls -la /var/www/
ls -la /home/
ls -la /opt/
ls -la /root/

# Find app directory
find / -name "package.json" -type f 2>/dev/null | head -20
```

---

## 🌐 Nginx Configuration

### Check Nginx Status
```bash
systemctl status nginx
nginx -t  # Test configuration
nginx -v  # Version

# View nginx config
cat /etc/nginx/nginx.conf

# Check sites configuration
ls -la /etc/nginx/sites-enabled/
cat /etc/nginx/sites-enabled/default

# Check logs
tail -f /var/log/nginx/access.log
tail -f /var/log/nginx/error.log
```

---

## 🗄️ Database Check

### MongoDB
```bash
# Check if MongoDB is running
systemctl status mongodb
# or
systemctl status mongod

# Connect to MongoDB
mongo
# or
mongosh

# Inside MongoDB shell:
show dbs
use beautician
show collections
db.users.countDocuments()
db.vendors.countDocuments()
db.bookings.countDocuments()
```

### PostgreSQL (if using)
```bash
systemctl status postgresql
sudo -u postgres psql
\l  # List databases
\c beautician  # Connect to database
\dt  # List tables
```

---

## 📁 File Storage

### Check Upload Directory
```bash
# Find uploads folder
find /var/www -type d -name "*upload*" 2>/dev/null
find /opt -type d -name "*upload*" 2>/dev/null
find /home -type d -name "*upload*" 2>/dev/null

# Check size of upload directories
du -sh /var/www/*/uploads/ 2>/dev/null
du -sh /opt/*/uploads/ 2>/dev/null

# List recent uploads
find /var/www -type f -name "*.jpg" -o -name "*.png" -o -name "*.mp4" | head -20
```

---

## 🔒 SSL Certificate

### Check SSL Status
```bash
# If using Let's Encrypt
certbot certificates

# Check certificate expiry
openssl s_client -connect api.thebeautyshop.io:443 -servername api.thebeautyshop.io 2>/dev/null | openssl x509 -noout -dates

# Check certificate details
openssl s_client -connect api.thebeautyshop.io:443 -servername api.thebeautyshop.io 2>/dev/null | openssl x509 -noout -text
```

---

## 📝 Application Logs

### View Application Logs
```bash
# PM2 logs
pm2 logs --lines 200

# System logs
journalctl -u your-app-name -n 100 -f

# Find log files
find /var/log -name "*api*" -o -name "*app*" -o -name "*node*" 2>/dev/null

# Nginx logs
tail -100 /var/log/nginx/access.log
tail -100 /var/log/nginx/error.log
```

---

## 🔍 Application Details

### Check Package.json
```bash
# Find and view package.json
find / -name "package.json" -path "*/node_modules" -prune -o -type f -name "package.json" -print 2>/dev/null

# View package.json content
cat /path/to/your/app/package.json
```

### Check Environment Variables
```bash
# Look for .env file
find /var/www -name ".env" 2>/dev/null
find /opt -name ".env" 2>/dev/null
find /home -name ".env" 2>/dev/null

# View .env (be careful - contains secrets!)
cat /path/to/app/.env
```

### Check Node Version
```bash
node -v
npm -v
```

---

## 🔥 Firebase Admin SDK

### Check Firebase Configuration
```bash
# Find Firebase service account key
find / -name "*firebase*" -name "*.json" 2>/dev/null | grep -v node_modules

# Check if Firebase Admin is initialized
grep -r "firebase-admin" /path/to/app/
```

---

## 🔌 Port Usage

### Check What's Running on Ports
```bash
# All listening ports
netstat -tulpn | grep LISTEN

# Specific ports
netstat -tulpn | grep :443   # HTTPS
netstat -tulpn | grep :80    # HTTP
netstat -tulpn | grep :3000  # Common Node port
netstat -tulpn | grep :4000  # Another common port
netstat -tulpn | grep :27017 # MongoDB
```

---

## 🔐 Security Check

### Check Firewall
```bash
# UFW firewall
ufw status verbose

# iptables
iptables -L -n -v
```

### Check Failed Login Attempts
```bash
# Check auth logs
tail -100 /var/log/auth.log | grep Failed

# Last logins
last | head -20
```

---

## 📦 Dependencies & Updates

### Check Node Modules
```bash
cd /path/to/your/app
npm list --depth=0
npm outdated
```

### System Updates
```bash
apt update
apt list --upgradable
```

---

## 🔄 Socket.IO Check

### Check Socket.IO Server
```bash
# Find socket.io in code
grep -r "socket.io" /path/to/app/ | grep -v node_modules

# Check if socket port is open
netstat -tulpn | grep node
```

---

## 💾 Backup Status

### Check Backup Scripts
```bash
# Find backup scripts
find / -name "*backup*" -type f 2>/dev/null | grep -E ".sh$|.js$"

# Check cron jobs
crontab -l
cat /etc/crontab
ls -la /etc/cron.daily/
```

---

## 🎯 Quick Full System Check Script

Run this comprehensive check:

```bash
#!/bin/bash
echo "=== SYSTEM STATUS ==="
uptime
free -h
df -h

echo -e "\n=== NGINX STATUS ==="
systemctl status nginx --no-pager

echo -e "\n=== NODE/PM2 PROCESSES ==="
pm2 status || ps aux | grep node

echo -e "\n=== DATABASE ==="
systemctl status mongodb --no-pager || systemctl status mongod --no-pager

echo -e "\n=== PORTS ==="
netstat -tulpn | grep LISTEN

echo -e "\n=== SSL CERT ==="
certbot certificates 2>/dev/null || echo "Certbot not found"

echo -e "\n=== RECENT LOGS ==="
tail -50 /var/log/nginx/error.log

echo -e "\n=== DISK USAGE ==="
du -sh /var/www/* 2>/dev/null
du -sh /opt/* 2>/dev/null
```

Save this as `check_server.sh`, make it executable with `chmod +x check_server.sh`, and run it with `./check_server.sh`

---

## 🚨 Common Issues to Check

### 1. App Not Running
```bash
pm2 restart all
# or
systemctl restart your-app-service
```

### 2. Out of Disk Space
```bash
df -h
du -sh /* | sort -h
# Clean logs
journalctl --vacuum-time=7d
```

### 3. High Memory Usage
```bash
free -h
ps aux --sort=-%mem | head -10
```

### 4. Database Connection Issues
```bash
systemctl status mongodb
mongo --eval "db.runCommand({ connectionStatus: 1 })"
```

---

## 📞 Get Specific Information

### Application Root Directory
```bash
# Once you find your app directory, go there
cd /var/www/your-app-name
pwd
ls -la
```

### Get Full Configuration
```bash
# From app directory
cat package.json
cat .env  # (Be careful - sensitive data!)
ls -la
```

---

**After running these commands, share the output you'd like me to analyze!**
