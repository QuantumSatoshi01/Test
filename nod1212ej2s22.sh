#!/bin/bash

# Install NVM (Node Version Manager)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash

# Activate NVM in the current session
source ~/.bashrc

# Wait for 3 seconds (optional)
sleep 3

# Install the LTS version of Node.js
nvm install --lts

# Install the stable version of Node.js
nvm install stable
