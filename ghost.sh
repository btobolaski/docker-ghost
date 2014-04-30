#!/bin/bash
cd /ghost
chown -R node .
/sbin/setuser node npm install --prod
exec /sbin/setuser node /usr/bin/npm start --prod >> /var/log/ghost.log 2>&1
