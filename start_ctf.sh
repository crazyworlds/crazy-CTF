#!/bin/bash

# --- Colori per output del terminale ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}  Avvio del Setup dell'Ambiente CTF     ${NC}"
echo -e "${GREEN}=========================================${NC}"

# --- 1. Creazione della directory per le chiavi SSH ---
echo -e "\n${YELLOW}[+] Creazione della directory per le chiavi SSH: ctf-keys/${NC}"
mkdir -p ctf-keys
if [ $? -ne 0 ]; then
    echo -e "${RED}[-] Errore nella creazione della directory ctf-keys. Uscita.${NC}"
    exit 1
fi

# --- 2. Generazione della coppia di chiavi SSH ---
KEY_PRIVATE="ctf-keys/ctf_key"
KEY_PUBLIC="ctf-keys/ctf_key.pub"

if [ -f "$KEY_PRIVATE" ]; then
    echo -e "${YELLOW}[!] Chiavi SSH esistenti. Saltando la generazione.${NC}"
else
    echo -e "${YELLOW}[+] Generazione di una nuova coppia di chiavi SSH (4096 bit, senza passphrase)...${NC}"
    ssh-keygen -t rsa -b 4096 -f "$KEY_PRIVATE" -N "" > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo -e "${RED}[-] Errore nella generazione delle chiavi SSH. Uscita.${NC}"
        exit 1
    fi
    echo -e "${GREEN}[+] Chiavi SSH generate con successo: $KEY_PRIVATE e $KEY_PUBLIC${NC}"
fi

# --- 3. Avvio di Docker Compose per costruire e avviare i servizi ---
echo -e "\n${YELLOW}[+] Avvio dei servizi Docker Compose (potrebbe richiedere tempo al primo avvio)...${NC}"
docker compose up --build -d
if [ $? -ne 0 ]; then
    echo -e "${RED}[-] Errore nell'avvio di Docker Compose. Controlla i log per dettagli.${NC}"
    exit 1
else
    echo -e "${GREEN}[+] Servizi Docker Compose avviati con successo!${NC}"
fi

# --- 4. Informazioni per l'accesso ---
echo -e "\n${GREEN}=========================================${NC}"
echo -e "${GREEN}        CTF Pronta per l'Azione!         ${NC}"
echo -e "${GREEN}=========================================${NC}"
echo -e "\n${YELLOW}Punto di Partenza Web:${NC} http://localhost:1080"
echo -e "${YELLOW}Server Interno Web (per debugging/recupero chiave):${NC} http://localhost:1081/int/manage/id_rsa"
echo -e "${YELLOW}Primo Server SSH (Metabase RCE):${NC} ssh ctfuser@localhost -p 2222"
echo -e "${YELLOW}Metabase Web Interface:${NC} http://localhost:3000"
echo -e "\n${YELLOW}Per fermare e rimuovere l'ambiente:${NC} docker compose down"
echo -e "${YELLOW}Ricorda: La chiave privata SSH si trova in ${NC}${GREEN}$KEY_PRIVATE${NC}"
echo -e "${YELLOW}Dovrai usarla con permessi 400: ${NC}${GREEN}chmod 400 $KEY_PRIVATE${NC}"

echo -e "\n${GREEN}Buona fortuna con la CTF!${NC}\n"