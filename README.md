# dotFiles

Small, safe dotfiles for AP Cybersecurity classroom VMs.
Supports Debian 13+, modern Fedora, and Arch Linux.

> New to dotfiles? [~/.dotfiles in 100 seconds – Fireship/YouTube](https://www.youtube.com/watch?v=r_MpUP6aKiQ)

## How it works

Clone into `~/dotfiles` — a single subfolder that holds everything.
The installer creates **symlinks** from your home directory into the repo:

```
~/.bashrc  →  ~/dotfiles/.bashrc
~/.vimrc   →  ~/dotfiles/.vimrc
...
```

Your home directory is never git-tracked. Any edit you make to `~/.bashrc`
is an edit inside the repo — commit and push with no extra steps.
This is the standard symlink-farm pattern used by the broader Linux community.

## Quick start

```bash
# 1. Clone into the canonical location
git clone https://github.com/RiceC-at-MasonHS/dotFiles.git ~/dotfiles
cd ~/dotfiles

# 2. Run the installer (creates symlinks by default)
./install.sh

# 3. Apply shell changes to the current session
source ~/.bashrc
```

The installer will:
- Symlink `.bashrc`, `.bash_aliases`, `.vimrc`, `.gitconfig` into `~/`
- Install `mason-cyber-*` scripts into `~/.local/bin/` (already on PATH)
- Create `~/.vim/tmp` and `~/.vim/backup` for vim swap/undo files
- Prompt you to enter your git name and email if `.gitconfig` still has placeholders

## Install options

```
./install.sh               symlink mode (default — recommended)
./install.sh --copy        copy files instead of symlinking
./install.sh --dry-run     preview all actions without making changes
./install.sh --backup      back up existing files before replacing
./install.sh --restore     restore backups created by a previous install
./install.sh --force       overwrite without prompting
```

## Package installer

```bash
./standard-apps.sh list      # show packages for your distro
./standard-apps.sh install   # install base development packages
./standard-apps.sh security  # install security/lab tools
./standard-apps.sh all       # install everything
```

Detects apt (Debian/Ubuntu), dnf (Fedora), and pacman (Arch) automatically.

## Helper scripts

After `./install.sh`, these are available anywhere in your terminal:

| Command | Purpose |
|---|---|
| `. mason-cyber-colors [preset]` | Restore lost terminal colors; presets: `school`, `night`, `high-contrast` |
| `mason-cyber-escape-root` | Return to your normal user from a root shell |
| `mason-cyber-netinfo` | Show IP addresses, gateway, and DNS servers |
| `mason-cyber-hashme <file>` | Hash a file with MD5 / SHA-1 / SHA-256 / SHA-512 |
| `mason-cyber-hashme -s "text"` | Hash an inline string |
| `mason-cyber-sysinfo` | Quick OS / CPU / memory / disk snapshot |

**Note:** `mason-cyber-colors` must be *sourced*, not executed:
```bash
. mason-cyber-colors          # reset colors
source mason-cyber-colors school   # reset + apply school color theme
```

## Prompt customization

See `docs/CONFIGURE.md` for color themes, verbose/short prompt toggle,
and CI details.

## License

MIT
