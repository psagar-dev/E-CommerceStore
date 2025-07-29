# E-Commerce Microservices Application

This is a full-stack **MERN** (MongoDB, Express.js, React, Node.js) e-commerce application built with a **microservices architecture**. It consists of four independent Node.js backend services and a React frontend, designed for scalability, modularity, and efficient deployment in an online shopping platform.

---

## 📑 Table of Contents
- Architecture Overview
- Technology Stack
- Project Structure
- Docker Network Setup
- Microservices
  - User Service
  - Product Service
  - Cart Service
  - Order Service
  - Frontend Service
- Terraform Infrastructure Provisioning
- Deployment Steps
- Screenshots of Production Modules

---

## 🏛 Architecture Overview

The application follows a **microservices architecture** where the React frontend communicates with an **API Gateway** that routes requests to individual services. This design ensures loose coupling, scalability, and independent deployment of components.

```plaintext
Frontend (React) → API Gateway → Microservices

├── 👤 User Service (Port: 3001)
├── 🛍 Product Service (Port: 3002)
├── 🛒 Cart Service (Port: 3003)
└── 📦 Order Service (Port: 3004)
```

---

## 🛠 Technology Stack

### Backend
- **Runtime**: Node.js with Express.js
- **Database**: MongoDB with Mongoose ODM
- **Authentication**: JWT (JSON Web Tokens)
- **Architecture**: RESTful APIs in a microservices setup

### Frontend
- **Framework**: React 18
- **Routing**: React Router
- **State Management**: React Query + Context API
- **HTTP Client**: Axios

---

## 📁 Project Structure

```plaintext
E-CommerceStore/
├── backend/
│   ├── user-service/
│   │   ├── models/                # Mongoose schemas
│   │   ├── routes/                # API routes
│   │   ├── middleware/            # Authentication & validation middleware
│   │   ├── server.js              # Service entry point
│   │   ├── .env                   # Environment variables
│   │   ├── .dockerignore          # Docker ignore file
│   │   ├── Dockerfile             # Docker configuration
│   │   └── package.json           # Node.js dependencies
│   ├── product-service/           # Similar structure as user-service
│   ├── cart-service/              # Similar structure as user-service
│   ├── order-service/             # Similar structure as user-service
├── frontend/
│   ├── public/                    # Static assets
│   ├── src/
│   │   ├── components/            # Reusable React components
│   │   ├── contexts/              # Context API for state management
│   │   ├── pages/                 # React page components
│   │   ├── services/              # API service calls
│   │   ├── App.js                 # Main React app
│   │   └── index.js               # React entry point
│   ├── .dockerignore              # Docker ignore file
│   ├── .env                       # Environment variables
│   ├── Dockerfile                 # Docker configuration
│   └── package.json               # Node.js dependencies
├── terraform/
│   ├── modules/
│   │   ├── vpc/                   # VPC module
│   │   ├── security_group/        # Security group module
│   │   ├── ec2/                   # EC2 instance module
│   ├── main.tf                    # Main Terraform configuration
│   ├── variables.tf               # Global variables
│   ├── outputs.tf                 # Output values
│   ├── terraform.tfvars           # Variable values
│   ├── backend.tf                 # Remote state configuration
│   ├── provider.tf                # AWS provider configuration
│   ├── user-data.sh               # EC2 user-data script
├── package.json                   # Root package file
└── README.md                      # Project documentation
```

---

## 🌉 Docker Network Setup

Create a Docker bridge network to enable communication between services:

```bash
docker network create --driver bridge e-commerce-network
```
![Docker network Create & List](images/docker-network-create-list.png)
---

## 🛠 Microservices

### 👤 User Service

Handles user authentication, registration, and profile management.

#### Environment Variables
File: `backend/user-service/.env`
```plaintext
PORT=3001
MONGODB_URI=mongodb://localhost:27017/ecommerce_users
JWT_SECRET=your-jwt-secret-key
```

#### 🐳 Dockerfile
File: `backend/user-service/Dockerfile`
```dockerfile
# Stage 1: Install Deps & build
FROM node:22-alpine AS builder

# Set the working directory in the container to /app
WORKDIR /app

# Copy package.json and package-lock.json to the working directory
COPY package*.json ./

# Install dependencies
RUN npm install --only=production

# Copy the rest of the application code to the working directory
COPY . .

# remove devDependencies
RUN npm prune --production

# Stage 2: Runtime: only prod artifacts on Alpine
#FROM node:lts-alpine as production
FROM node:22-alpine AS production

# Set the working directory in the container to /app
WORKDIR /app

# Install curl for healthchecks
RUN apk add --no-cache curl

# Copy only the necessary files from the builder stage
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app ./

# Build the application
EXPOSE 3001

# CMd to run the application
CMD ["node", "server.js"]
```

#### 🔍 Local Testing
1. **Build Image**:
   ```bash
   docker image build --no-cache -t securelooper/user-service:latest .
   ```
   ![Docker Build for User Service](images/docker-build-user-service.png)
2. **Push to Docker Hub**:
   ```bash
   docker image push securelooper/user-service:latest
   ```
3. **Run Container**:
   ```bash
   docker run -d -p 3001:3001 \
     --name user-service --network e-commerce-network \
     -e PORT=3001 \
     -e MONGODB_URI="mongodb://root:root@192.168.31.100:27017/ecommerce_users?authSource=admin" \
     -e JWT_SECRET="25010aae0c1c89937614b1e500628b9f944fd3dbf27a9ad8bb46b81c03944354" \
     securelooper/user-service:latest
   ```
4. **Health Check**: [http://localhost:3001/health](http://localhost:3001/health)

![Docker Container Run for User Service](images/docker-container-run-user-service.png)

#### Endpoints
- `POST /api/auth/register` - Register a new user
- `POST /api/auth/login` - User login
- `GET /api/auth/me` - Get current user
- `GET /api/users/profile` - Get user profile
- `PUT /api/users/profile` - Update user profile

#### Example: Register User
```bash
curl -X POST http://localhost:3001/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"firstName":"John","lastName":"Doe","email":"john@example.com","password":"password123"}'
```

---

### 🛍 Product Service

Manages product listings, categories.

#### Environment Variables
File: `backend/product-service/.env`
```plaintext
PORT=3002
MONGODB_URI=mongodb://localhost:27017/ecommerce_products
```

#### 🐳 Dockerfile
File: `backend/product-service/Dockerfile`
```dockerfile
# Stage 1: Install Deps & build
FROM node:22-alpine AS builder

# Set the working directory in the container to /app
WORKDIR /app

# Copy package.json and package-lock.json to the working directory
COPY package*.json ./

# Install dependencies
RUN npm install --only=production

# Copy the rest of the application code to the working directory
COPY . .

# remove devDependencies
RUN npm prune --production

# Stage 2: Runtime: only prod artifacts on Alpine
#FROM node:lts-alpine as production
FROM node:22-alpine AS production

# Set the working directory in the container to /app
WORKDIR /app

# Install curl for healthchecks
RUN apk add --no-cache curl

# Copy only the necessary files from the builder stage
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app ./

# Build the application
EXPOSE 3002

# CMd to run the application
CMD ["node", "server.js"]
```

#### 🔍 Local Testing
1. **Build Image**:
   ```bash
   docker image build --no-cache -t securelooper/product-service:latest .
   ```
   ![Docker Build for Product Service](images/docker-build-product-service.png)
2. **Push to Docker Hub**:
   ```bash
   docker image push securelooper/product-service:latest
   ```
3. **Run Container**:
   ```bash
   docker run -d -p 3002:3002 \
     --name product-service --network e-commerce-network \
     -e PORT=3002 \
     -e MONGODB_URI="mongodb://root:root@192.168.31.100:27017/ecommerce_products?authSource=admin" \
     securelooper/product-service:latest
   ```
4. **Health Check**: [http://localhost:3002/health](http://localhost:3002/health)

![Docker Container Run for Product Service](images/docker-container-run-product-service.png)

#### Endpoints
- `GET /api/products` - List products with filtering/pagination
- `GET /api/products/:id` - Get single product
- `POST /api/products` - Create product (admin)
- `PUT /api/products/:id` - Update product (admin)
- `DELETE /api/products/:id` - Soft delete product (admin)
- `GET /api/categories` - List all categories
- `POST /api/categories` - Create category (admin)

---

### 🛒 Cart Service

Manages user shopping carts and integrates with the Product Service.

#### Environment Variables
File: `backend/cart-service/.env`
```plaintext
PORT=3003
MONGODB_URI=mongodb://localhost:27017/ecommerce_carts
PRODUCT_SERVICE_URL=http://localhost:3002
```

#### 🐳 Dockerfile
File: `backend/cart-service/Dockerfile`
```dockerfile
# Stage 1: Install Deps & build
FROM node:22-alpine AS builder

# Set the working directory in the container to /app
WORKDIR /app

# Copy package.json and package-lock.json to the working directory
COPY package*.json ./

# Install dependencies
RUN npm install --only=production

# Copy the rest of the application code to the working directory
COPY . .

# remove devDependencies
RUN npm prune --production

# Stage 2: Runtime: only prod artifacts on Alpine
#FROM node:lts-alpine as production
FROM node:22-alpine AS production

# Set the working directory in the container to /app
WORKDIR /app

# Install curl for healthchecks
RUN apk add --no-cache curl

# Copy only the necessary files from the builder stage
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app ./

# Build the application
EXPOSE 3003

# CMd to run the application
CMD ["node", "server.js"]
```

#### 🔍 Local Testing
1. **Build Image**:
   ```bash
   docker image build --no-cache -t securelooper/cart-service:latest .
   ```
   ![Docker Build for Cart Service](images/docker-build-cart-service.png)
2. **Push to Docker Hub**:
   ```bash
   docker image push securelooper/cart-service:latest
   ```
3. **Run Container**:
   ```bash
   docker run -d -p 3003:3003 \
     --name cart-service --network e-commerce-network \
     -e PORT=3003 \
     -e MONGODB_URI="mongodb://root:root@192.168.31.100:27017/ecommerce_carts?authSource=admin" \
     -e PRODUCT_SERVICE_URL=http://192.168.31.100:3002 \
     securelooper/cart-service:latest
   ```
4. **Health Check**: [http://localhost:3003/health](http://localhost:3003/health)

![Docker Container Run for Cart Service](images/docker-container-run-cart-service.png)

#### Endpoints
- `GET /api/cart/:userId` - Get user's cart
- `POST /api/cart/:userId/items` - Add item to cart
- `PUT /api/cart/:userId/items/:productId` - Update cart item
- `DELETE /api/cart/:userId/items/:productId` - Remove cart item
- `DELETE /api/cart/:userId` - Clear entire cart
- `POST /api/cart/:userId/validate` - Validate cart items

---

### 📦 Order Service

Handles order creation, status updates, and payment processing.

#### Environment Variables
File: `backend/order-service/.env`
```plaintext
PORT=3004
MONGODB_URI=mongodb://localhost:27017/ecommerce_orders
CART_SERVICE_URL=http://localhost:3003
PRODUCT_SERVICE_URL=http://localhost:3002
USER_SERVICE_URL=http://localhost:3001
```

#### 🐳 Dockerfile
File: `backend/order-service/Dockerfile`
```dockerfile
# Stage 1: Install Deps & build
FROM node:22-alpine AS builder

# Set the working directory in the container to /app
WORKDIR /app

# Copy package.json and package-lock.json to the working directory
COPY package*.json ./

# Install dependencies
RUN npm install --only=production

# Copy the rest of the application code to the working directory
COPY . .

# remove devDependencies
RUN npm prune --production

# Stage 2: Runtime: only prod artifacts on Alpine
#FROM node:lts-alpine as production
FROM node:22-alpine AS production

# Set the working directory in the container to /app
WORKDIR /app

# Install curl for healthchecks
RUN apk add --no-cache curl

# Copy only the necessary files from the builder stage
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app ./

# Build the application
EXPOSE 3004

# CMd to run the application
CMD ["node", "server.js"]
```

#### 🔍 Local Testing
1. **Build Image**:
   ```bash
   docker image build --no-cache -t securelooper/order-service:latest .
   ```
   ![Docker Build for Order Service](images/docker-build-order-service.png)
2. **Push to Docker Hub**:
   ```bash
   docker image push securelooper/order-service:latest
   ```
3. **Run Container**:
   ```bash
   docker run -d -p 3004:3004 \
     --name order-service --network e-commerce-network \
     -e PORT=3004 \
     -e MONGODB_URI="mongodb://root:root@192.168.31.100:27017/ecommerce_orders?authSource=admin" \
     -e USER_SERVICE_URL=http://192.168.31.100:3001 \
     -e PRODUCT_SERVICE_URL=http://192.168.31.100:3002 \
     -e CART_SERVICE_URL=http://192.168.31.100:3003 \
     securelooper/order-service:latest
   ```
4. **Health Check**: [http://localhost:3004/health](http://localhost:3004/health)

![Docker Container Run for Order Service](images/docker-container-run-order-service.png)

#### Endpoints
- `GET /api/orders/user/:userId` - Get user's orders
- `GET /api/orders/:id` - Get single order
- `POST /api/orders` - Create new order
- `PUT /api/orders/:id/status` - Update order status
- `DELETE /api/orders/:id` - Cancel order
- `POST /api/payments/process` - Process payment
- `POST /api/payments/refund` - Process refund

---

### 🌐 Frontend Service

The React-based frontend for the e-commerce application.

#### Environment Variables
File: `frontend/.env`
```plaintext
REACT_APP_USER_SERVICE_URL=http://localhost:3001
REACT_APP_PRODUCT_SERVICE_URL=http://localhost:3002
REACT_APP_CART_SERVICE_URL=http://localhost:3003
REACT_APP_ORDER_SERVICE_URL=http://localhost:3004
```

#### 🐳 Dockerfile
File: `frontend/Dockerfile`
```dockerfile
# Single stage since the build happens on the server at runtime
FROM node:22-alpine

WORKDIR /app

COPY package*.json ./

# --- CHANGE IS HERE ---
# Install dependencies and immediately clean the npm cache in the same layer.
# This is the most effective way to reduce size in a single-stage build.
RUN npm install && npm cache clean --force

# Copy the rest of the application source code
COPY . .

# Environment variables to prevent file watcher errors with 'npm start'
ENV WATCHPACK_POLLING=true
ENV CHOKIDAR_USEPOLLING=true

# Expose the port the server will run on
EXPOSE 3000

# The CMD remains the same for your workflow
CMD ["npm", "start"]
```

#### 🔍 Local Testing
1. **Build Image**:
   ```bash
   docker image build --no-cache -t securelooper/frontend-service:latest .
   ```
   ![Docker Build for Frontend Service](images/docker-build-frontend-service.png)
2. **Push to Docker Hub**:
   ```bash
   docker image push securelooper/frontend-service:latest
   ```
3. **Run Container**:
   ```bash
   docker run -d -p 80:3000 \
     --name frontend-service --network e-commerce-network \
     -e REACT_APP_USER_SERVICE_URL=http://192.168.31.100:3001 \
     -e REACT_APP_PRODUCT_SERVICE_URL=http://192.168.31.100:3002 \
     -e REACT_APP_CART_SERVICE_URL=http://192.168.31.100:3003 \
     -e REACT_APP_ORDER_SERVICE_URL=http://192.168.31.100:3004 \
     securelooper/frontend-service:latest
   ```
4. **Access Frontend**: [http://localhost:80](http://localhost:80)
![Docker Container Run for Frontend Service](images/docker-container-run-frontend-service.png)
---

## 🛠 Terraform Infrastructure Provisioning

Terraform is used to provision AWS infrastructure for the application, including VPC, security groups, and EC2 instances.

### Project Directory Structure
```plaintext
E-CommerceStore/
├── terraform/
│   ├── modules/
│   │   ├── vpc/                   # VPC configuration
│   │   ├── security_group/        # Security group rules
│   │   ├── ec2/                   # EC2 instance setup
│   ├── main.tf                    # Main configuration
│   ├── variables.tf               # Global variables
│   ├── outputs.tf                 # Output values
│   ├── terraform.tfvars           # Variable values
│   ├── backend.tf                 # S3 backend for state
│   ├── provider.tf                # AWS provider
│   ├── user-data.sh               # EC2 user-data script
```

### Step 1: Configure Terraform Backend
File: `terraform/backend.tf`
```
terraform {
  backend "s3" {
    bucket         = "sagar-ecommerce-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "sagar-terraform-locks"
    encrypt        = true
  }
}
```

**Action**: Create S3 bucket and DynamoDB table:
```bash
# Create S3 bucket
aws s3api create-bucket \
  --bucket sagar-ecommerce-terraform-state \
  --region ap-south-1 \
  --create-bucket-configuration LocationConstraint=ap-south-1

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket sagar-ecommerce-terraform-state \
  --versioning-configuration Status=Enabled \
  --region ap-south-1

# Create DynamoDB table
aws dynamodb create-table \
  --table-name sagar-terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --region ap-south-1
```
- S3 & Dynamodb Create
![s3 & dynamodb](images/s3-dynamodb-create.png)

- S3 List
![s3 List](images/s3-list.png)

- Dynamodb List
![dynamodb List](images/dynamodb-list.png)

### Step 2: Define AWS Provider
File: `terraform/provider.tf`
```
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.5.0"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Environment = "production"
      Project     = var.project_name
      ManagedBy   = "Terraform"
    }
  }
}
```

### Step 3: Define Variables
File: `terraform/variables.tf`
```
variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "sagar-ecommerce"
}

variable "ami_ec2" {
  description = "Name of the ami"
  type        = string
  default     = "ami-0c55b159cbfafe1f0"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.medium"
}

variable "dockerhub_username" {
  description = "DockerHub username for pulling images"
  type        = string
  default     = "securelooper"
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
  default     = "sagar-b10"
}

variable "jwt_secret" {
  description = "JWT secret for user service"
  type        = string
  sensitive   = true
}
```

### Step 4: VPC Module
File: `terraform/modules/vpc/main.tf`
```
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = "${var.region}a"
  tags = {
    Name = "${var.project_name}-public-subnet"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project_name}-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
```

File: `terraform/modules/vpc/variables.tf`
```
variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}
```

File: `terraform/modules/vpc/outputs.tf`
```
output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}
```

### Step 5: Security Group Module
File: `terraform/modules/security_group/main.tf`
```
resource "aws_security_group" "ecommerce_sg" {
  vpc_id      = var.vpc_id
  name        = "${var.project_name}-sg"
  description = "Security group for e-commerce application"

  ingress {
    description = "HTTP for frontend"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Frontend port"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Service ports for internal communication"
    from_port   = 3001
    to_port     = 3004
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH for debugging"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict to your IP in production
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg"
  }
}
```

File: `terraform/modules/security_group/variables.tf`
```
variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC"
  type        = string
}
```

File: `terraform/modules/security_group/outputs.tf`
```
output "security_group_id" {
  value = aws_security_group.ecommerce_sg.id
}
```

### Step 6: EC2 Module
File: `terraform/modules/ec2/main.tf`
```
resource "aws_instance" "ecommerce_server" {
  ami                    = var.ami_ec2
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = var.key_name
  user_data              = templatefile("${path.module}/../../user-data.sh", {
    dockerhub_username   = var.dockerhub_username,
    jwt_secret           = var.jwt_secret
  })

  tags = {
    Name = "${var.project_name}-server"
  }

  associate_public_ip_address = true
}
```

File: `terraform/modules/ec2/variables.tf`
```
variable "ami_ec2" {
  description = "Name of the ami"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet"
  type        = string
}

variable "security_group_id" {
  description = "ID of the security group"
  type        = string
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
}

variable "dockerhub_username" {
  description = "DockerHub username for pulling images"
  type        = string
}

variable "jwt_secret" {
  description = "JWT secret for user service"
  type        = string
  sensitive   = true
}
```

File: `terraform/modules/ec2/outputs.tf`
```
output "instance_public_ip" {
  value = aws_instance.ecommerce_server.public_ip
}
```

### Step 7: User-Data Script
File: `terraform/user-data.sh`
```bash
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
```

### Step 8: Main Terraform Configuration
File: `terraform/main.tf`
```
module "vpc" {
  source             = "./modules/vpc"
  project_name       = var.project_name
  vpc_cidr           = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
  region             = var.region
}

module "security_group" {
  source       = "./modules/security_group"
  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
  vpc_cidr     = var.vpc_cidr
}

module "ec2" {
  source             = "./modules/ec2"
  project_name       = var.project_name
  ami_ec2            = var.ami_ec2
  instance_type      = var.instance_type
  subnet_id          = module.vpc.public_subnet_id
  security_group_id  = module.security_group.security_group_id
  key_name           = var.key_name
  dockerhub_username = var.dockerhub_username
  jwt_secret         = var.jwt_secret
}
```

File: `terraform/outputs.tf`
```
output "frontend_url" {
  value       = "http://${module.ec2.instance_public_ip}:3000"
  description = "Public URL for the frontend service"
}
```

### Step 9: Terraform Variables
File: `terraform/terraform.tfvars`
```
region            = "ap-south-1"
project_name      = "sagar-ecommerce"
vpc_cidr          = "10.0.0.0/16"
public_subnet_cidr= "10.0.1.0/24"
ami_ec2           = "ami-0f918f7e67a3323f0"
instance_type     = "t2.small"
dockerhub_username= "securelooper"
key_name          = "sagar-b10"
jwt_secret        = "25010aae0c1c89937614b1e500628b9f944fd3dbf27a9ad8bb46b81c03944354"
```

---

## 🚀 Deployment Steps

1. **Configure AWS Credentials**:
   Ensure AWS credentials are set in `~/.aws/credentials` or as environment variables.

2. **Initialize Terraform**:
   ```bash
   cd E-CommerceStore/terraform
   terraform init
   ```
   ![terraform init](images/terraform-init.png)

3. **Format and Validate**:
   ```bash
   terraform fmt
   terraform validate
   ```
   ![terraform fmt validate](images/terraform-fmt-validate.png)

4. **Preview Changes**:
   ```bash
   terraform plan -var-file="terraform.tfvars"
   ```
   ![terraform fmt validate](images/terraform-plan.png)

5. **Apply Configuration**:
   ```bash
   terraform apply -var-file="terraform.tfvars"
   ```
   ![terraform fmt validate](images/terraform-apply.png)
6. **Access Application**:
   - Use the `frontend_url` output from Terraform to access the application.
   - Example: [http://<EC2_PUBLIC_IP>:80](http://<EC2_PUBLIC_IP>:80)

7. **Destroy Infrastructure** (when needed):
   ```bash
   terraform destroy -var-file="terraform.tfvars"
   ```
   ![terraform fmt validate](images/terraform-destroy.png)
---

- 🌐 **VPC**

![terraform fmt validate](images/vpc-list.png)
![terraform fmt validate](images/vpc-detail.png)

- 🗄️ **DynamoDB**

![terraform fmt validate](images/DynamoDB-detail.png)
- 📦 **S3 Detail**

![terraform fmt validate](images/s3-details.png)

- 🛡️ **Security Groups**

![terraform fmt validate](images/security-group.png)

- 🐳 **Docker Running Production**

![terraform fmt validate](images/docker-running-production.png)

- 📊 **Production Live**
![terraform fmt validate](images/live-production-ui.png)

---
## 📜 Project Information

### 📄 License Details
This project is released under the MIT License, granting you the freedom to:
- 🔓 Use in commercial projects
- 🔄 Modify and redistribute
- 📚 Use as educational material

## 📞 Contact

📧 Email: [Email Me](securelooper@gmail.com
)
🔗 LinkedIn: [LinkedIn Profile](https://www.linkedin.com/in/sagar-93-patel)  
🐙 GitHub: [GitHub Profile](https://github.com/psagar-dev)  

---

<div align="center">
  <p>Built with ❤️ by Sagar Patel</p>
</div>