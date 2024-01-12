#!/bin/bash

# ANSI escape codes for text formatting
RED='\033[0;31m'
RESET='\033[0m'
BOLD='\033[1m'
CYAN='\033[0;36m'

# Function to display ASCII art for the main menu
display_main_menu_ascii_art() {
    cat << "EOF"
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
EOF
}

# Function to display ASCII art for asking the password
display_password_ascii_art() {
    cat << "EOF"
 ___________  
|           | 
| Enter     | 
| Password  | 
|___________| 
(\__/)||      
(•ㅅ•) ||      
/    づ      
EOF
}


uninstall_ascii_art() {
    cat << "EOF"
 ___________  
|           | 
| Uninstall | 
|           | 
|___________| 
(\__/)||      
(•ㅅ•) ||      
/    づ      
EOF
}

# Function to get a password securely with feedback
get_password() {
    local password=""
    local password_confirm=""
    local max_length=256  # Set the maximum length here

    clear
    printf "${RED}${BOLD}\n"
    display_password_ascii_art
    printf "${RESET}\n"

    printf "${YELLOW}Warning: truncating password to $max_length characters.${RESET}\n"

    while true; do
        printf "${CYAN}${BOLD}Enter your password (max $max_length characters):${RESET}\n"
        read -s -p "Password: " password
        password=${password:0:$max_length}  # Truncate to max_length
        printf "\n"

        printf "${CYAN}${BOLD}Confirm Password:${RESET}\n"
        read -s -p "Confirm Password: " password_confirm
        password_confirm=${password_confirm:0:$max_length}  # Truncate to max_length
        printf "\n"

        if [ "$password" == "$password_confirm" ]; then
            printf "\n${CYAN}${BOLD}Password Match!${RESET}\n"
            break
        else
            printf "\n${RED}Passwords do not match. Please try again.${RESET}\n"
        fi
    done

    echo "$password"
}



# Function to display a colored box with text
display_box() {
    local text="$1"
    local box_width=${#text}
    local box_padding=$(( (50 - box_width) / 2 ))
    local left_padding=""
    local right_padding=""
    
    for ((i = 0; i < box_padding; i++)); do
        left_padding="${left_padding} "
        right_padding="${right_padding} "
    done

    echo -e "${RED}${BOLD}╔════════════════════════════════════════════════╗${RESET}"
    echo -e "${RED}${BOLD}║${RESET}${BOLD}${RED}${left_padding}${text}${right_padding}${RESET}${RED}${BOLD}║${RESET}"
    echo -e "${RED}${BOLD}╚════════════════════════════════════════════════╝${RESET}"
}

# Main menu
while true; do
    clear
    echo -e "${RED}${BOLD}"
    display_main_menu_ascii_art
    display_box "Select an option:"
    display_box "1) Install From Scratch"
    display_box "2) Add New User"
    display_box "3) Complete Uninstall"
    display_box "4) Exit"
    echo -e "${RESET}"
    read -p "Enter your choice (1/2/3/4): " choice

    case $choice in
        1)
            # Install From Scratch
            clear
            echo -e "${RED}${BOLD}Installing 3proxy from scratch...${RESET}"

            # Display ASCII art
            display_main_menu_ascii_art

            # Check if 3proxy is already installed
            if dpkg -l | grep -q "3proxy"; then
                echo -e "${RED}3proxy is already installed. Aborting installation.${RESET}"
                exit 1
            fi

            # Download 3proxy .deb package
            wget https://github.com/3proxy/3proxy/releases/download/0.9.4/3proxy-0.9.4.x86_64.deb -O 3proxy.deb

            # Install the package
            sudo dpkg -i 3proxy.deb

            # Create 3proxy configuration directory if it doesn't exist
            sudo mkdir -p /etc/3proxy/

            # Ask for username
            clear
            echo -e "${RED}${BOLD}"
            display_password_ascii_art
            echo -e "${RESET}"
            read -p "Enter username for new user: " username

            # Get password securely
            password=$(get_password)

            # Securely hash the password
            hashed_password=$(openssl passwd -1 "$password")

            # Create initial configuration file with user credentials
            echo "Creating configuration..."
            cat <<EOT | sudo tee /etc/3proxy/3proxy.cfg
nserver 1.1.1.1
nserver 8.8.8.8
nscache 65536
timeouts 1 5 30 60 180 1800 15 60
log /var/log/3proxy/3proxy.log D
logformat "L%d-%m-%Y %H:%M:%S %N.%p %E %U %C:%c %R:%r %O %I %h %T"
rotate 30
auth strong
users $username:$hashed_password
allow $username
socks -p60000
EOT

            # Create log directory
            sudo mkdir -p /var/log/3proxy/

            # Start and enable 3proxy service
            sudo systemctl start 3proxy
            sudo systemctl enable 3proxy
            echo -e "${RED}${BOLD}Installation complete.${RESET}"
            ;;
        2)
            # Add New User
            if [ ! -f /etc/3proxy/3proxy.cfg ]; then
                echo -e "${RED}3proxy is not installed. Please install it first.${RESET}"
                exit 1
            fi
            clear
            echo -e "${RED}${BOLD}"
            display_password_ascii_art
            echo -e "${RESET}"
            read -p "Enter username for new user: " new_username
            password=$(get_password)
            hashed_password=$(openssl passwd -1 "$password")
            sudo sed -i "/auth strong/a users $new_username:$hashed_password\nallow $new_username" /etc/3proxy/3proxy.cfg
            sudo systemctl restart 3proxy
            echo -e "${RED}${BOLD}New user added.${RESET}"
            ;;
        3)
            # Complete Uninstall
            clear
			uninstall_ascii_art
            echo -e "${RED}${BOLD}"            
            echo -e "${RESET}"
            echo -e "${RED}${BOLD}UNINSTALL:${RESET}"

            # Stop and disable 3proxy service
            sudo systemctl stop 3proxy
            sudo systemctl disable 3proxy

            # Remove 3proxy package along with configuration files
            sudo dpkg --purge 3proxy

            # Delete 3proxy configuration directory and log directory
            sudo rm -rf /etc/3proxy/ /var/log/3proxy/

            echo -e "${RED}${BOLD}3proxy uninstalled.${RESET}"
            ;;
        4)
            # Exit
            clear
            echo -e "${RED}${BOLD}Exiting...${RESET}"
            exit 0
            ;;
        *)
            echo -e "${RED}${BOLD}Invalid choice. Please enter 1, 2, 3, or 4.${RESET}"
            ;;
    esac
    read -n 1 -s -r -p "Press any key to continue..."
done
