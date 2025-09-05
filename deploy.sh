#!/bin/bash

# =======================================================
# One-Click Deployment Script: Hugging Face Space Local Deployer
# -------------------------------------------------------
# Supports Debian/Ubuntu systems
# Automatically installs dependencies, clones the repo, and builds/runs the Docker container.
# =======================================================

# Script name and color highlights
SCRIPT_NAME="Hugging Face Space Local Deployer"
BLUE_HIGHLIGHT="\e[34m"
RED_ERROR="\e[31m"
RESET_COLOR="\e[0m"

echo -e "${BLUE_HIGHLIGHT}--- Starting the $SCRIPT_NAME --- ${RESET_COLOR}"

# --- Step 1/5: Check and install Docker ---
if ! command -v docker &> /dev/null
then
    echo -e "${BLUE_HIGHLIGHT}--- Step 1/5: Docker not found, starting installation --- ${RESET_COLOR}"
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl gnupg
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo usermod -aG docker "$USER"
    echo -e "${BLUE_HIGHLIGHT}--- Docker installation complete. Restarting shell session to apply changes... ---${RESET_COLOR}"
    newgrp docker << EOF
    bash
EOF
fi

echo -e "${BLUE_HIGHLIGHT}--- Step 1/5: Docker is installed, continuing --- ${RESET_COLOR}"

# --- Step 2/5: Check and install Git ---
if ! command -v git &> /dev/null
then
    echo -e "${BLUE_HIGHLIGHT}--- Step 2/5: Git not found, starting installation --- ${RESET_COLOR}"
    sudo apt-get update
    sudo apt-get install -y git
fi

echo -e "${BLUE_HIGHLIGHT}--- Step 2/5: Git is installed, continuing --- ${RESET_COLOR}"

# --- Step 3/5: Interactive repo info retrieval ---
read -p $'\e[34m--- Step 3/5: Please enter the Hugging Face Space ID (e.g., openai/whisper): \e[0m' REPO_ID
REPO_URL="https://huggingface.co/spaces/$REPO_ID"
REPO_NAME=$(basename "$REPO_ID")

if [ -d "$REPO_NAME" ]; then
    echo -e "${BLUE_HIGHLIGHT}--- Repository already exists. Pulling latest code... --- ${RESET_COLOR}"
    cd "$REPO_NAME" || exit
    git pull
    cd ..
else
    echo -e "${BLUE_HIGHLIGHT}--- Cloning Hugging Face Space repository --- ${RESET_COLOR}"
    git clone "$REPO_URL"
fi

if [ ! -d "$REPO_NAME" ]; then
    echo -e "${RED_ERROR}Error: Repository cloning failed. Please ensure the Space ID is correct.${RESET_COLOR}"
    echo -e "${RED_ERROR}Please correct the ID and run this script again.${RESET_COLOR}"
    exit 1
fi

echo -e "${BLUE_HIGHLIGHT}--- Repository cloned/updated successfully --- ${RESET_COLOR}"

# --- Step 4/5: Build the Docker image ---
echo -e "${BLUE_HIGHLIGHT}--- Step 4/5: Building the Docker image (this may take a while) --- ${RESET_COLOR}"
cd "$REPO_NAME" || exit
docker build -t "$REPO_NAME"-app .

if [ $? -ne 0 ]; then
    echo -e "${RED_ERROR}Error: Docker image build failed.${RESET_COLOR}"
    exit 1
fi

echo -e "${BLUE_HIGHLIGHT}--- Image built successfully --- ${RESET_COLOR}"

# --- Step 5/5: Run the Docker container ---
DEFAULT_PORT=7860
read -p $'\e[34m--- Step 5/5: Enter a port for the service mapping (default is 7860): \e[0m' USER_PORT
USER_PORT=${USER_PORT:-$DEFAULT_PORT}

echo -e "${BLUE_HIGHLIGHT}--- Starting the container. You can access the app at http://localhost:${USER_PORT} --- ${RESET_COLOR}"
echo -e "${BLUE_HIGHLIGHT}--- Press Ctrl+C to stop the container --- ${RESET_COLOR}"
docker run -p "$USER_PORT":$DEFAULT_PORT "$REPO_NAME"-app
