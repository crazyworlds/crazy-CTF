#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}  Starting the CTF Environment Setup     ${NC}"
echo -e "${GREEN}=========================================${NC}"

# --- 1. Build directory for SSH KEY ---
echo -e "\n${YELLOW}[+] Creating the directory for SSH keys: ctf-keys/${NC}"
mkdir -p ctf-keys
if [ $? -ne 0 ]; then
    echo -e "${RED}[-] Error creating ctf-keys directory. Exit.${NC}"
    exit 1
fi

# --- 2. Generation SSH  KEY---
KEY_PRIVATE="ctf-keys/ctf_key"
KEY_PUBLIC="ctf-keys/ctf_key.pub"

if [ -f "$KEY_PRIVATE" ]; then
    echo -e "${YELLOW}[!] Existing SSH Keys. Skipping Generation.${NC}"
else
    echo -e "${YELLOW}[+] Generate a new SSH key pair (4096 bit, no passphrase)...${NC}"
    ssh-keygen -t rsa -b 4096 -f "$KEY_PRIVATE" -N "" > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo -e "${RED}[-] Error generating SSH keys. Exit.${NC}"
        exit 1
    fi
    echo -e "${GREEN}[+] SSH keys successfully generated: $KEY_PRIVATE e $KEY_PUBLIC${NC}"
fi

# --- 3. Start  Docker Compose to build and start services ---
echo -e "\n${YELLOW}[+] Starting Docker Compose services (may take some time on first start))...${NC}"
docker compose up --build -d
if [ $? -ne 0 ]; then
    echo -e "${RED}[-] Error starting Docker Compose. Check logs for details.${NC}"
    exit 1
else
    echo -e "${GREEN}[+] Docker Compose services started successfully!${NC}"
fi

# --- 4. Informazioni per l'accesso ---
echo -e "\n${GREEN}=========================================${NC}"
echo -e "${GREEN}        CTF Ready for Action!         ${NC}"
echo -e "${GREEN}           Create By        ${NC}"
echo -e "${CYAN}           The\`{razy         ${NC}"
echo -e "${GREEN}=========================================${NC}"
echo -e "\n${YELLOW}Entrypoint :${NC} http://localhost:1080"

echo -e "\n${GREEN}Good luck with the CTF!${NC}\n"
