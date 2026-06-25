# Minecraft Server Opener For Linux

Minecraft Server Opener is a simple bash script that automates setting up and managing Minecraft servers. It checks for required dependencies, installs Java versions if needed, and provides an interactive `fzf` menu to download and launch different server types such as Vanilla, Forge, Paper, Fabric, and Sponge.

Two variants are provided so you can pick the one that matches your distribution's package manager:

| Script | Distribution | Package manager |
|--------|--------------|-----------------|
| `server.sh` | Debian / Ubuntu / Mint | `apt` |
| `server_arch.sh` | Arch / Manjaro / CachyOS | `pacman` |

Both behave identically — they only differ in how they install packages and where they expect Java to live.

## Features

- **Dependency Check:** Verifies that `fzf`, `curl`, and `wget` are installed, and offers to install any that are missing.
- **Java Installation:** Installs Java 8, 17, or 21 if it is not already present.
- **Minecraft Server Downloads:** Download a specific Minecraft version for Vanilla, Forge, Paper, Fabric, or Sponge.
- **Central Server Folder:** Every server lives under `~/MinecraftServers`, so the menu lists your servers no matter which directory you run the command from.
- **Turkish Character Warning:** Warns if the server path contains Turkish characters (Forge and similar tools can fail on such paths).
- **Interactive Menu:** Every action is chosen through an `fzf` menu.

## Requirements

- A Linux distribution (Debian/Ubuntu based or Arch based).
- `fzf`, `curl`, and `wget` — the script can install them for you.
- Java 8, 17, and/or 21 — the script can install the one you select.

## Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/KaanAlper/Minecraft-Server-Opener.git
   cd Minecraft-Server-Opener
   ```

2. Make the script for your distribution executable:

   ```bash
   chmod +x server.sh        # Debian / Ubuntu
   chmod +x server_arch.sh   # Arch
   ```

3. Run it:

   ```bash
   ./server.sh        # Debian / Ubuntu
   ./server_arch.sh   # Arch
   ```

## Run it as a `server` command (optional)

Install it as a global `server` command so you can launch the menu from any folder.

**Without sudo (recommended)** — symlink it into `~/.local/bin` (make sure that directory is in your `PATH`):

```bash
ln -sf "$(pwd)/server_arch.sh" ~/.local/bin/server   # Arch
ln -sf "$(pwd)/server.sh"      ~/.local/bin/server   # Debian / Ubuntu
```

**System-wide** — copy it into `/usr/local/bin`:

```bash
sudo cp server_arch.sh /usr/local/bin/server   # or server.sh on Debian / Ubuntu
sudo chmod +x /usr/local/bin/server
```

Using a symlink keeps the `server` command up to date automatically whenever you `git pull`.

## Where are my servers stored?

All downloaded servers are created under a single central folder:

```
~/MinecraftServers/
├── Vanilla_1.21.4/
├── Paper_1.21.4/
└── Forge_1.20.1/
```

Because the script always scans this folder, the `server` command lists your existing servers regardless of the directory you launch it from.

## 📌 License

This project is licensed under the Kaan Alper Karaaslan Personal & Academic Use License (v1.1).

🔹 Summary of the License:

✅ You are free to use, modify, and distribute this software for personal and academic purposes.

❌ Commercial use is strictly prohibited. You may not sell, license, or integrate this software into any commercial product or service.

✅ If you modify and share this software, you must provide proper attribution and retain this license.

📧 If you wish to use this software for commercial purposes, you must obtain explicit permission from the author by contacting: kaanalperkaraaslan@gmail.com.

For full details, please refer to the complete license text included in this repository.
