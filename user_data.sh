#!/bin/bash
apt update -y
apt install -y nginx-core
cat > /var/www/html/index.html <<'EOF'  
<h1> Hello There</h1>
  <p>
    This webpage was created in Terraform!
  </p>
EOF
systemctl start nginx
systemctl enable nginx