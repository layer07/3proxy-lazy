 ## 3Proxy Installation Script

 This script automates the installation of 3proxy on your system. 3proxy is a lightweight and versatile proxy server that can be used for various purposes.

 ## Installation

 To install 3proxy using this script, follow these steps:

 1. Download the installation script:

    ```
    wget https://github.com/layer07/3proxy-lazy/releases/download/Release/3proxy_install.sh
    ```

 2. Make the script executable:

    ```
    chmod +x 3proxy_install.sh
    ```

 3. Execute the script:

    ```
    ./3proxy_install.sh
    ```


## All in one for the ultra-lazy (concatenate all lines in a single command)
```bash
wget https://github.com/layer07/3proxy-lazy/releases/download/Release/3proxy_install.sh \
&& chmod +x 3proxy_install.sh \
&& ./3proxy_install.sh
```
## Default Socks5 Server Port
The default port is **`TCP: 60000`**, change the script before executing if you need a different port. 

 Usage

 Upon executing the script, you will be presented with a menu that allows you to perform the following actions:

 1. **Install From Scratch**: This option installs 3proxy from scratch, configuring it with a default user. If 3proxy is already installed, the installation will be aborted.

 2. **Add New User**: Use this option to add a new user to an existing 3proxy installation. You will be prompted to enter the username and password for the new user.

 3. **Complete Uninstall**: This option completely uninstalls 3proxy from your system. All configuration files and logs will be removed.

 4. **Exit**: Select this option to exit the script.

 Follow the on-screen prompts to complete the desired action. 

 **Disclaimer:** This script is provided as-is and is not associated with the official 3proxy project. Use it at your own risk.