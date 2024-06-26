#!/bin/sh
set -eux -o pipefail

ambariRepoPath=$1
ambariNginxConfPath=$2
#set db default env 
ambariRepoPath=${ambariRepoPath:-/var/www/html/hadoop}
ambariNginxConfPath=${ambariNginxConfPath:-/etc/nginx/nginx.conf}

function configAmbariNginx() {
  cat > ${ambariNginxConfPath} << 'EOF'
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;
include /usr/share/nginx/modules/*.conf;
events {
    worker_connections 1024;
}
http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';
    access_log  /var/log/nginx/access.log  main;
    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 4096;
    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;
    include  /etc/nginx/conf.d/*.conf;
EOF
    cat >> ${ambariNginxConfPath} << EOF
    server {
        listen       80;
        listen       [::]:80;
        server_name  _;
        location  / {
                root        ${ambariRepoPath};
                autoindex on;
        }
        index index.html index.htm;
        include /etc/nginx/default.d/*.conf;
        error_page 404 /404.html;
        location = /404.html {
        }
        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }
    }
}
EOF
}

which nginx || yum install -y nginx
configAmbariNginx
nginx 
curl -I -m 10 -o /dev/null -s -w %{http_code} 127.0.0.1 &>/dev/null && echo "install nginx successfully" 