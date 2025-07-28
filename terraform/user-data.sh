#!/bin/bash
# Install Docker
apt-get update -y
apt-get install -y curl
sudo curl -fsSL https://get.docker.com | sudo sh
sudo usermod -aG docker $USER
newgrp docker
systemctl start docker
systemctl enable docker

# Fetch EC2 instance public IP dynamically
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

PUBLIC_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/public-ipv4)

MONGODB_URI="your_mongodb_uri_here"  # Replace with your MongoDB URI

docker network create e-commerce-network

# Run containers with environment variables
docker run -d -p 3001:3001 --name user-service --network e-commerce-network \
  -e PORT=3001 \
  -e MONGODB_URI=$MONGODB_URI \
  -e JWT_SECRET=${jwt_secret} \
  ${dockerhub_username}/user-service:latest

sleep 5

docker run -d -p 3002:3002 --name product-service --network e-commerce-network \
  -e PORT=3002 \
  -e MONGODB_URI=$MONGODB_URI \
  ${dockerhub_username}/product-service:latest

sleep 5

docker run -d -p 3003:3003 --name cart-service --network e-commerce-network \
  -e PORT=3003 \
  -e MONGODB_URI=$MONGODB_URI \
  -e PRODUCT_SERVICE_URL=http://$PUBLIC_IP:3002 \
  ${dockerhub_username}/cart-service:latest

sleep 5

docker run -d -p 3004:3004 --name order-service --network e-commerce-network \
  -e PORT=3004 \
  -e MONGODB_URI=$MONGODB_URI \
  -e CART_SERVICE_URL=http://$PUBLIC_IP:3003 \
  -e PRODUCT_SERVICE_URL=http://$PUBLIC_IP:3002 \
  -e USER_SERVICE_URL=http://$PUBLIC_IP:3001 \
  ${dockerhub_username}/order-service:latest

sleep 5

docker run -d -p 80:3000 --name frontend-service --network e-commerce-network \
  -e REACT_APP_USER_SERVICE_URL=http://$PUBLIC_IP:3001 \
  -e REACT_APP_PRODUCT_SERVICE_URL=http://$PUBLIC_IP:3002 \
  -e REACT_APP_CART_SERVICE_URL=http://$PUBLIC_IP:3003 \
  -e REACT_APP_ORDER_SERVICE_URL=http://$PUBLIC_IP:3004 \
  ${dockerhub_username}/frontend-service:latest