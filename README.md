# Minecraft Server Opener For Linux

Minecraft Server Opener is a simple bash script designed to automate the setup and management of Minecraft servers. The script checks for necessary dependencies, installs Java versions if required, and provides an interactive menu to manage different types of Minecraft servers, such as Vanilla, Forge, Paper, Fabric, and Sponge.

## Features

- **Dependency Check:** Verifies if tools like `fzf` and `curl` are installed.
- **Java Installation:** Installs Java 8, 17, or 21 if not already installed.
- **Minecraft Server Downloads:** Allows downloading specific Minecraft versions.
- **Turkish Character Warning:** Warns about directories containing Turkish characters.
- **Interactive Menu:** Lets you choose actions using `fzf`.

## Requirements

- A Linux-based operating system (Ubuntu, Linux Mint, etc.)
- `fzf` and `curl` must be installed.
- Java 8, 17, or 21 should be installed, or the script can install them for you.
- Minecraft server files (server.jar) should be downloaded.

## Installation

1. Clone the repository or download the script:

   ```bash
   git clone https://github.com/KaanAlper/Minecraft-Server-Opener.git
   cd Minecraft-Server-Opener
2. Make the script executable:

   ```bash
   chmod +x server.sh
3. Run the script:

   ```bash
   ./server.sh
4. Add to bin (Optional):

   ```bash
   sudo cp server.sh /usr/local/bin/server.sh
