#!/bin/bash

# Check if docker-compose is installed
if ! [ -x "$(command -v docker-compose)" ]; then
  # Install docker-compose if not present
  echo "Installing Docker Compose..."
  apt-get update
  apt-get install -y docker-compose
fi

# Check if site name argument was provided
if [ -z "$1" ]; then
  echo "Please provide a site name as an argument."
  exit 1
fi
# Entry in /etc/hosts
site_name="$1"
echo "127.0.0.1:8085 $site_name" >> /etc/hosts
#creating required files
mkdir wordpress-docker
cd wordpress-docker
# Creating  nginx
echo "Creating nginx configuration file"
mkdir conf.d
cd conf.d
cat > nginx.conf << EOF
server {
  listen 80;
  listen [::]:80;
  server_name localhost;

  root /var/www/html;

  access_log off;

  index index.php;

  server_tokens off;

  location / {
    try_files \$uri \$uri/ /index.php?\$args;
  }

  location ~ \\.php$ {
    fastcgi_split_path_info ^(.+\\.php)(/.+)$;
    fastcgi_pass wordpress:9000;
    fastcgi_index index.php;
    include fastcgi_params;
    fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    fastcgi_param SCRIPT_NAME \$fastcgi_script_name;
  }
}
EOF
echo "Done"
cd ..
echo "Creating docker-compose file ..."
cat > docker-compose.yml << EOF 
version: '3.7'
services:
  db:
    image: mariadb:10
    container_name: db
    environment:
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wordpress
      MYSQL_PASSWORD: wordpress
      MYSQL_ROOT_PASSWORD: password
    volumes: 
      - db_data:/var/lib/mysql
  wordpress:
    image: wordpress:php8.2-fpm
    container_name: wordpress
    depends_on:
      - db
    volumes:
      - wp_files:/var/www/html
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_NAME: wordpress
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_PASSWORD: wordpress

  nginx:
    image: nginx:alpine
    container_name: nginx
    depends_on: 
      - wordpress
    ports:
      - 8085:80
    volumes:
      - ./conf.d:/etc/nginx/conf.d
      - wp_files:/var/www/html

volumes:
  wp_files:
  db_data:
EOF
echo "Done"
fuser -k 8000/tcp 9000/tcp 8081/tcp 8080/tcp
echo "Creating LEMP stck in docker for wordpress"
docker-compose up -d
echo "Servers created"
echo "Site created successfully. Open http://localhost:8085 or $sitename in your browser."

# Additional subcommands

# Subcommand to enable/disable the site (stop/start containers)
if [ "$2" == "enable" ]; then
  docker-compose start
  echo "Site enabled."
elif [ "$2" == "disable" ]; then
  docker-compose stop
  echo "Site disabled."
fi

# Subcommand to delete the site (delete containers and local files)
if [ "$2" == "delete" ]; then
  docker-compose down
  echo "Site deleted."
  #removing hosts entry
  sudo sed -i "/127.0.0.1:8085 $site_name/d" /etc/hosts
  rm -rf ./*
  cd ..
  rm -rf wordpress-docker/
fi

