#!/bin/bash

clear  # Clear the screen

# Header
echo -e "
  ██████▓██   ██▓  ██████  ██▓███   █    ██  ███▄    █  ██ ▄█▀
▒██    ▒ ▒██  ██▒▒██    ▒ ▓██░  ██▒ ██  ▓██▒ ██ ▀█   █  ██▄█▒ 
░ ▓██▄    ▒██ ██░░ ▓██▄   ▓██░ ██▓▒▓██  ▒██░▓██  ▀█ ██▒▓███▄░ 
  ▒   ██▒ ░ ▐██▓░  ▒   ██▒▒██▄█▓▒ ▒▓▓█  ░██░▓██▒  ▐▌██▒▓██ █▄ 
▒██████▒▒ ░ ██▒▓░▒██████▒▒▒██▒ ░  ░▒▒█████▓ ▒██░   ▓██░▒██▒ █▄
▒ ▒▓▒ ▒ ░  ██▒▒▒ ▒ ▒▓▒ ▒ ░▒▓▒░ ░  ░░▒▓▒ ▒ ▒ ░ ▒░   ▒ ▒ ▒ ▒▒ ▓▒
░ ░▒  ░ ░▓██ ░▒░ ░ ░▒  ░ ░░▒ ░     ░░▒░ ░ ░ ░ ░░   ░ ▒░░ ░▒ ▒░
░  ░  ░  ▒ ▒ ░░  ░  ░  ░  ░░        ░░░ ░ ░    ░   ░ ░ ░ ░░ ░ 
      ░  ░ ░           ░              ░              ░ ░  ░   
         ░ ░                                                  
"

function install_3proxy() {
    # Download 3proxy and install it
    wget https://github.com/3proxy/3proxy/releases/download/0.9.4/3proxy-0.9.4.x86_64.deb
    sudo dpkg -i 3proxy-0.9.4.x86_64.deb

    # Set the desired port (60000) in the 3proxy configuration file
    sudo sed -i 's/^nscache .*/nscache 65536/' /etc/3proxy/3proxy.cfg

    # Ask for username and password
    read -p "Enter username for 3proxy: " username
    read -p "Enter password for 3proxy: " password

    # Create a user file with username and password
    echo "${username}:${password}" | sudo tee -a /etc/3proxy/.proxyauth

    # Restart 3proxy to apply changes
    sudo systemctl restart 3proxy
}

function add_new_user() {
    # Prompt for the username
    read -p "Enter the username: " username

    # Prompt for the password (plaintext)
    read -p "Enter the password: " password

    # Path to the 3proxy configuration file
    config_file="/etc/3proxy/3proxy.cfg"

    # Path to the 3proxy password file
    passwd_file="/etc/3proxy/conf/passwd"

    # Add the user to the 3proxy configuration file
    echo "users $username:CL:$password" | sudo tee -a "$config_file"

    # Add the user to the 3proxy password file
    echo "$username:CL:$password" | sudo tee -a "$passwd_file"

    # Reload 3proxy to apply the changes
    sudo systemctl reload 3proxy

    echo "User $username added successfully."
    sudo systemctl restart 3proxy
}

function remove_3proxy() {
    # Stop 3proxy service if running
    sudo systemctl stop 3proxy

    # Remove 3proxy and its configuration files
    sudo apt-get purge 3proxy -y
    sudo rm -rf /etc/3proxy/
}

while true; do
    echo "Select an option:"
    echo "1) Install 3proxy"
    echo "2) Add New User"
    echo "3) Completely Remove 3proxy"
    echo "4) Exit"

    read -p "Enter your choice: " choice

    case $choice in
        1) install_3proxy ;;
        2) add_new_user ;;
        3) remove_3proxy ;;
        4) exit ;;
        *) echo "Invalid choice. Please select a valid option." ;;
    esac
done
