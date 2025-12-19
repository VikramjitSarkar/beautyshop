#!/bin/bash
# Quick Server Inspection Script
# Run this on your server: ssh root@69.62.72.155 < inspect.sh

echo "=== 1. FIND APPLICATION DIRECTORY ==="
find /var/www /opt /home /root -name "package.json" -type f 2>/dev/null | grep -v node_modules | head -10

echo -e "\n=== 2. RUNNING PROCESSES ==="
pm2 list 2>/dev/null || ps aux | grep -E "node|npm" | grep -v grep

echo -e "\n=== 3. NGINX CONFIG ==="
cat /etc/nginx/sites-enabled/default 2>/dev/null || cat /etc/nginx/nginx.conf

echo -e "\n=== 4. APPLICATION STRUCTURE ==="
APP_DIR=$(find /var/www /opt /home -name "package.json" -type f 2>/dev/null | grep -v node_modules | head -1 | xargs dirname)
if [ -n "$APP_DIR" ]; then
    echo "App found at: $APP_DIR"
    cd "$APP_DIR"
    pwd
    ls -la
    echo -e "\n=== PACKAGE.JSON ==="
    cat package.json 2>/dev/null
    echo -e "\n=== ENV FILE (first 20 lines, hiding sensitive values) ==="
    if [ -f .env ]; then
        cat .env | head -20
    fi
    echo -e "\n=== ROUTES/ENDPOINTS ==="
    find . -name "*.js" -type f | grep -E "route|router|app.js|server.js|index.js" | grep -v node_modules | head -10
fi

echo -e "\n=== 5. MONGODB STATUS ==="
systemctl status mongodb 2>/dev/null || systemctl status mongod 2>/dev/null
mongo --version 2>/dev/null || mongosh --version 2>/dev/null

echo -e "\n=== 6. DATABASE INFO ==="
mongo --quiet --eval "
    var dbs = db.adminCommand('listDatabases');
    print('Databases:');
    dbs.databases.forEach(function(db) { print('  - ' + db.name + ' (' + (db.sizeOnDisk/1024/1024).toFixed(2) + ' MB)'); });
" 2>/dev/null

echo -e "\n=== 7. RECENT LOGS ==="
pm2 logs --lines 30 --nostream 2>/dev/null || tail -30 /var/log/nginx/error.log 2>/dev/null

echo -e "\n=== 8. API ROUTES (from code) ==="
if [ -n "$APP_DIR" ]; then
    cd "$APP_DIR"
    grep -r "app\.get\|app\.post\|app\.put\|app\.delete\|router\." . --include="*.js" | grep -v node_modules | head -30
fi

echo -e "\n=== INSPECTION COMPLETE ==="
