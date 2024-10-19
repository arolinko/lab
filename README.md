# Dockerized Node.js Hello World Application

This project demonstrates a simple Node.js application that prints "Hello, World!" to the console. It includes a Dockerfile for containerization and a basic unit test using Mocha.

## Table of Contents

- [Dockerfile](#dockerfile)
- [Node.js Application](#nodejs-application-appjs)
- [Unit Test](#unit-test-for-the-application-testtestjs)
- [Package.json](#packagejson)
- [Building the Docker Image](#build-the-docker-image)
- [Running the Docker Container](#run-the-docker-container)

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
