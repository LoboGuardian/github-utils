#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

SSH_DIR="$HOME/.ssh"

print_header() {
    clear
    echo -e "${BLUE}=================================================${NC}"
    echo -e "${BLUE}           SSH Key Management Script             ${NC}"
    echo -e "${BLUE}=================================================${NC}"
    echo ""
}

check_existing_keys() {
    echo -e "${YELLOW}Checking for existing SSH keys in $SSH_DIR...${NC}"
    
    if [ ! -d "$SSH_DIR" ]; then
        echo -e "${RED}Directory $SSH_DIR does not exist.${NC}"
        return
    fi

    # Find .pub files
    pub_keys=$(find "$SSH_DIR" -maxdepth 1 -name "*.pub")

    if [ -z "$pub_keys" ]; then
        echo -e "${YELLOW}No public keys found.${NC}"
    else
        echo -e "${GREEN}Found the following public keys:${NC}"
        echo "$pub_keys" | while read -r key_file; do
            echo -e "\n${BLUE}Key File:${NC} $key_file"
            echo -e "${BLUE}Content:${NC}"
            cat "$key_file"
            echo -e "${BLUE}-------------------------------------------------${NC}"
        done
    fi
    echo ""
    read -p "Press Enter to continue..."
}

generate_new_key() {
    echo -e "${YELLOW}Generating a new SSH key pair...${NC}"
    
    # Prompt for key type
    echo "Select key type:"
    echo "1) Ed25519 (Recommended - Faster and Secure)"
    echo "2) RSA (Legacy compatibility - 4096 bit)"
    read -p "Enter choice (1/2): " key_choice

    if [ "$key_choice" == "2" ]; then
        algo="rsa"
        bits="-b 4096"
        default_file="$SSH_DIR/id_rsa"
    else
        algo="ed25519"
        bits=""
        default_file="$SSH_DIR/id_ed25519"
    fi

    read -p "Enter your email for the key comment (e.g., user@example.com): " email
    if [ -z "$email" ]; then
        email="ssh-user@$(hostname)"
    fi

    echo -e "${YELLOW}You will now be asked for a file path and a passphrase.${NC}"
    echo -e "${YELLOW}Press Enter to accept defaults.${NC}"
    
    ssh-keygen -t "$algo" $bits -C "$email"

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Key generation complete!${NC}"
    else
        echo -e "${RED}Key generation failed.${NC}"
    fi
    echo ""
    read -p "Press Enter to continue..."
}

while true; do
    print_header
    echo "1) List and View Existing Public Keys"
    echo "2) Generate New SSH Key Pair"
    echo "3) Exit"
    echo ""
    read -p "Select an option: " option

    case $option in
        1)
            check_existing_keys
            ;;
        2)
            generate_new_key
            ;;
        3)
            echo -e "${GREEN}Exiting...${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option. Please try again.${NC}"
            sleep 1
            ;;
    esac
done
