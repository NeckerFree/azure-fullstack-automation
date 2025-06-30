#!/bin/bash

# Install dependencies
sudo apt-get update
sudo apt-get install -y git nodejs npm mysql-client

# Clone repo
git clone ${repo_url} /tmp/devops-rampup
cd /tmp/devops-rampup/movie-analyst-api

# Install app
npm install

# Configure DB connection (using Private Endpoint DNS)
cat > config.js <<EOF
module.exports = {
  db: {
    host: '${mysql_flexible_server_fqdn}',
    user: 'movie_analyst',
    password: 'AnalystPassword123!',
    database: 'movie_analyst'
  },
  app: {
    port: 8080
  }
};
EOF

# Start service (use PM2 for process management)
sudo npm install -g pm2
pm2 start server.js --name "movie-api"
pm2 save
pm2 startup