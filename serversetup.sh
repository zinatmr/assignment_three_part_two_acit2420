#!/bin/bash

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "Please run this script as root."
    exit 1
fi

##Task-1
## Setting up webgen server
# Define variables
USER="webgen"
HOME_DIR="/var/lib/webgen"
BIN_DIR="$HOME_DIR/bin"
HTML_DIR="$HOME_DIR/HTML"
GENERATE_INDEX_SCRIPT="generate_index"
DOC_DIR="$HOME_DIR/documents"
FILE_ONE="$HOME_DIR/documents/file-one"
FILE_TWO="$HOME_DIR/documents/file-two"

# Create the system user
echo "Creating system user: $USER..."
useradd -r -m -d "$HOME_DIR" -s /usr/sbin/nologin "$USER"

# Create necessary directories
echo "Creating directory structure..."
mkdir -p "$BIN_DIR" "$HTML_DIR" "$DOC_DIR"

# move generate_index to the desired location
echo "Copying files to directories..."
if [[ -f "./$GENERATE_INDEX_SCRIPT" ]]; then
    cp "./$GENERATE_INDEX_SCRIPT" "$BIN_DIR/"
else
    echo "Error: $GENERATE_INDEX_SCRIPT not found in the current directory."
    exit 1
fi

# Set ownership of the directories and files
echo "Setting ownership to $USER..."
chown -R "$USER:$USER" "$HOME_DIR"
#chmod +x $BIN_DIR/$GENERATE_INDEX_SCRIPT
#$BIN_DIR/$GENERATE_INDEX_SCRIPT
# Verify ownership and structure
echo "Verifying ownership and directory structure..."
ls -lR "$HOME_DIR"

# Create file-one
echo "Creating file-one here: $FILE_ONE"
cat <<EOF > "$FILE_ONE"
This is file one.
EOF

# Create file-two
echo "Creating file-two here: $FILE_TWO"
cat <<EOF > "$FILE_TWO"
This is file two.
EOF



## Task-2
## Creating the generate_index.service file and generate_index.timer and setting up the service and timer


# Variables
SERVICE_FILE="/etc/systemd/system/generate-index.service"
TIMER_FILE="/etc/systemd/system/generate-index.timer"
GENERATE_SCRIPT_PATH="/var/lib/webgen/bin/generate_index"

# To create the generate-index.service file
echo "Creation of service file: $SERVICE_FILE"
cat <<EOF > "$SERVICE_FILE"
[Unit]
Description=Generate Index HTML
After=network-online.target
Wants=network-online.target

[Service]
User=webgen
Group=webgen
ExecStart=$GENERATE_SCRIPT_PATH
WorkingDirectory=/var/lib/webgen
EOF

# To create the generate-index.timer file
echo "Creation of timer file: $TIMER_FILE"
cat <<EOF > "$TIMER_FILE"
[Unit]
Description=Run Generate Index HTML Service at 05:00 daily

[Timer]
OnCalendar=*-*-* 07:04:00
Persistent=true

[Install]
WantedBy=timers.target
EOF

# To reload systemd
echo "Reloading the systemd daemon......"
systemctl daemon-reload

# To enable and start the timer
echo "Enabling and starting the timer....."
systemctl enable --now generate-index.timer


##Task-3
## Installing and setting up nginx
# Define variables
NGINX_CONF_PATH="/etc/nginx/nginx.conf"
SERVER_BLOCK="/etc/nginx/sites-available/webgen_server_block.conf"
WEB_ROOT="/var/lib/webgen/HTML"
SERVER_IP=$(ip -4 a show dev eth0 | grep inet | awk '{print $2}' | cut -d/ -f1)
SITES_AVAILABLE="/etc/nginx/sites-available"
SITES_ENABLED="/etc/nginx/sites-enabled"

# Installing NGINX
echo "Installing NGINX..."
pacman -Syu --noconfirm nginx
echo "NGINX is installed successfully."

# Updating user in nginx.conf
echo "Updating nginx.conf to use the 'webgen' user..."
rm $NGINX_CONF_PATH

cat > "$NGINX_CONF_PATH" <<EOF
user webgen;
worker_processes  1;



events {
    worker_connections  1024;
}


http {
    include sites-enabled/*;
    include       mime.types;
    default_type  application/octet-stream;


    sendfile        on;

    keepalive_timeout  65;

}
EOF

# create the following directories for server block
echo "Creating sites-available and sites-enabled directory"
mkdir -p "$SITES_AVAILABLE" "$SITES_ENABLED"

# Creating separate server block
cat > "$SERVER_BLOCK" <<EOF
server {
    listen 80;
    server_name $SERVER_IP;

    root $WEB_ROOT;
    index index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF

# Includeing the server block to nginx.conf
sed -i '/http {/a \    include sites-enabled/*;' "$NGINX_CONF_PATH"


# Enabling the site
ln -s $SITES_AVAILABLE/webgen_server_block.conf $SITES_ENABLED/webgen_server_block.conf

# Starting NGINX
echo "Starting NGINX service..."
systemctl enable nginx
systemctl start nginx



## Task-4
## Installing and setting up a firewall

# Installing UFW
echo "Installing UFW..."
pacman -S --noconfirm ufw

# Enabling UFW
echo "Enabling UFW service..."
systemctl enable ufw
systemctl start ufw

# Allowing SSH and HTTP
echo "Allowing SSH (port 22) and HTTP (port 80) traffic..."
ufw allow ssh
ufw allow http

# Enabling SSH Rate Limiting
echo "Enabling SSH rate limiting..."
ufw limit ssh

# Enabling the Firewall
echo "Activating the firewall..."
ufw --force enable

# Checking UFW Status
echo "Checking UFW status..."
ufw status verbose



## Task-5 screenshot is given separately!!
## End 
