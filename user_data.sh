#!/bin/bash
apt update -y
apt install -y nginx-core
systemctl stop nginx
cat << 'EOF' > 1  
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
</head>
<body>
<h1> Hello There </h1>
<p>Oh, look! This webpage was created in Terraform!</p>
</body>
</html>
EOF
systemctl start nginx