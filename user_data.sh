#!/bin/bash
yum update -y
yum install -y nginx
cat > /var/www/html/index.html <<'EOF'  
<h1> Hello There</h1>
  <p>
    This webpage was created in Terraform!
  </p>
EOF
systemctl start nginx
systemctl enable nginx