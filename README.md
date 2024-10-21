# Dockerized Node.js Hello World Application

This project demonstrates a simple Node.js application that prints "Hello, World!" to the console. It includes a Dockerfile for containerization and a basic unit test using Mocha.

## Table of Contents

- [Dockerfile](#dockerfile)
- [Node.js Application](#nodejs-application-appjs)
- [Unit Test](#unit-test-for-the-application-testtestjs)
- [Package.json](#packagejson)
- [Building the Docker Image](#build-the-docker-image)
- [Running the Docker Container](#run-the-docker-container)
- [GitHub Actions YAML](#github-actions-yaml)
- [Steps to Deploy Terraform ](#steps-to-deploy-terraform)
- [Install Nginx INgress Controller](#install-nginx-iNgress-controller)

---

## Dockerfile

Here is a simple Dockerfile for the Node.js application, which includes a step for running unit tests.

```Dockerfile
# Use an official Node.js runtime as a parent image
FROM node:18

# Set the working directory in the container
WORKDIR /usr/src/app

# Copy package.json and package-lock.json files to the container
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the current directory contents into the container
COPY . .

# Run unit tests
RUN npm test

# Expose the port the app runs on
EXPOSE 3000

# Command to run the application
CMD ["node", "app.js"]
```
## Node.js Application (app.js)
The Node.js application is a simple script that prints “Hello, World!” to the console.
```javascript
// app.js
console.log("Hello, World!");
```

## Unit Test for the Application (test/test.js)
The project uses Mocha as the testing framework. Ensure Mocha is installed as a development dependency:
```bash
npm install mocha --save-dev
```

Here’s the test file:
```javascript
// test/test.js
const assert = require('assert');

describe('Hello World Test', () => {
  it('should print Hello, World!', () => {
    assert.strictEqual('Hello, World!', 'Hello, World!');
  });
});
```

## package.json

Ensure your package.json includes the following test script for running the tests with Mocha:
```json
{
  "name": "hello-world-app",
  "version": "1.0.0",
  "description": "A simple Node.js app that prints Hello, World!",
  "main": "app.js",
  "scripts": {
    "test": "mocha"
  },
  "dependencies": {},
  "devDependencies": {
    "mocha": "^10.0.0"
  }
}
```

## Build the Docker Image
To build the Docker image, run the following command:
```bash
docker build -t node-hello-world .
```

## Run the Docker Container
To run the Docker container and map port 3000 on your host to port 3000 in the container, execute:
```bash
docker run -p 3000:3000 node-hello-world
```

## GitHub Actions YAML
```
name: Docker Image CI/CD

on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      # Step 1: Check out the repository
      - name: Checkout repository
        uses: actions/checkout@v3

      # Step 2: Set up Node.js (version 18)
      - name: Set up Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'

      # Step 3: Install NPM dependencies
      - name: Install dependencies
        run: npm install

      # Step 4: Run tests
      - name: Run tests
        run: npm test

      # Step 5: Log in to Docker Hub (after tests pass)
      - name: Log in to Docker Hub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}

      # Step 6: Build Docker image
      - name: Build Docker image
        run: docker build -t ${{ secrets.DOCKER_USERNAME }}/node-hello-world:latest .

      # Step 7: Push Docker image to Docker Hub
      - name: Push Docker image
        run: docker push ${{ secrets.DOCKER_USERNAME }}/node-hello-world:latest
```        

# Steps to Deploy: Terraform

1. Create a Service Principal (If not already created):
```bash
az ad sp create-for-rbac --name "TFSPN" --role="Contributor" --scopes="/subscriptions/<your-subscription-id>"
```
This will give you a client_id and client_secret to use in the terraform.tfvars file.

2. Assign to SPN "Network Contributor" 
```bash
az role assignment create \
  --assignee <client_id_or_object_id> \
  --role "Network Contributor" \
  --scope /subscriptions/<subscription_id>/resourceGroups/<resource_group_name>
  ```

3. Initialize Terraform:
Navigate to the root folder where your main.tf is and initialize Terraform.
```bash
terraform init
```

4. Validate and Plan:
Ensure everything is configured correctly by validating and planning the execution.
```bash
terraform plan
```

5. Apply the Configuration:
Apply the configuration to provision the resources.
```bash
terraform apply
```


## Install Nginx INgress Controller
```
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

kubectl create namespace ingress-basic

helm install ingress-nginx ingress-nginx/ingress-nginx \
    --namespace ingress-basic \
    --set controller.replicaCount=1 \
    --set controller.service.loadBalancerIP=20.10.165.170 \
    --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-resource-group"=aks-resource-group \
    --set controller.nodeSelector."kubernetes\.io/os"=linux \
    --set controller.admissionWebhooks.patch.nodeSelector."kubernetes\.io/os"=linux \
    --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-health-probe-request-path"=/healthz \
    --set defaultBackend.nodeSelector."kubernetes\.io/os"=linux
```    

On local machine add "node-app.local" ito hosts file and point to IP: 20.10.165.170
Open browser and navigate to node-app.local, you'll see "Hello, World!"
