# dotFiles

Shell configuration, editor settings, and classroom helper scripts for
AP Cybersecurity students. Designed for **Debian 13+**, with full support
for modern **Fedora** and **Arch Linux** as well.

> New to dotfiles? [~/.dotfiles in 100 seconds – Fireship/YouTube](https://www.youtube.com/watch?v=r_MpUP6aKiQ)

---

## How it works — the symlink-farm pattern

The installer creates **symbolic links** from your home directory into this
repository. For example:

```
~/.bashrc       →  ~/dotfiles/.bashrc
~/.vimrc        →  ~/dotfiles/.vimrc
~/.gitconfig    →  ~/dotfiles/.gitconfig
~/.bash_aliases →  ~/dotfiles/.bash_aliases
```

Your `~` is never itself a git repository. Only the `~/dotfiles/` subfolder
is tracked by git, so you will never accidentally commit unrelated files.
Any edit you make to `~/.bashrc` is an edit inside the repo — no copying
or syncing required. This is the **standard community dotfile pattern**
used by the broader Linux world; search "dotfiles symlink" to find thousands
of examples.

---

## Quick start

```bash
# 1. Clone into ~/dotfiles — the canonical home for this repo
git clone https://github.com/RiceC-at-MasonHS/dotFiles.git ~/dotfiles
cd ~/dotfiles

# 2. Run the installer (creates symlinks by default)
./install.sh

# 3. Apply the new shell settings to the current session
source ~/.bashrc
```

The installer will:
- Symlink `.bashrc`, `.bash_aliases`, `.vimrc`, and `.gitconfig` into `~/`
- Install `mason-cyber-*` scripts into `~/.local/bin/` (already on your PATH)
- Create `~/.vim/tmp` and `~/.vim/backup` so vim swap/undo files work correctly
- Prompt for your git name and email if `.gitconfig` still has placeholder values

---

## Installer options

```
./install.sh               Symlink mode — recommended (default)
./install.sh --copy        Copy files instead of symlinking
./install.sh --dry-run     Preview all actions without making changes
./install.sh --backup      Back up existing files before replacing them
./install.sh --restore     Restore backups created by a previous install
./install.sh --force       Overwrite without prompting
```

You can combine flags:

```bash
./install.sh --backup --force    # overwrite everything, saving backups
./install.sh --copy --dry-run    # preview what copy mode would do
```

---

## Package installer

`standard-apps.sh` installs recommended packages using whatever package
manager your distro provides (`apt`, `dnf`, or `pacman`). Package names
differ by distro — the script handles translation automatically.

```bash
./standard-apps.sh list      # show packages that would be installed
./standard-apps.sh install   # install base development tools
./standard-apps.sh security  # install security and lab tools
./standard-apps.sh all       # install everything (base + security)
```

**Base packages** (cross-distro equivalents installed automatically):
`git`, `vim`, `curl`, `wget`, `python3`, `python3-pip`, `python3-flask`,
`python3-fastapi`, `bash-completion`, build toolchain, `net-tools`

**Security / lab tools:**
`nmap`, `tcpdump`, `netcat`, `wireshark`, `john`, `hydra`, `binutils`, `gdb`

---

## Helper scripts

After `./install.sh`, these commands are available anywhere in your terminal.
They live in `~/.local/bin/`, which `.bashrc` already adds to `$PATH`.

### `mason-cyber-colors` — restore lost terminal colors

WSL sessions sometimes lose color settings. This resets the terminal and
re-applies the dotfile color theme.

**Must be sourced** (not executed) to affect your current shell:

```bash
. mason-cyber-colors                      # reset to defaults
source mason-cyber-colors school          # reset + apply school theme
source mason-cyber-colors night           # dark theme
source mason-cyber-colors high-contrast   # accessibility theme
```

If you accidentally run it as a command, it will explain what to do.

### `mason-cyber-escape-root` — get back from a root shell

If you are stuck in a root shell (e.g. after `sudo su`), run:

```bash
mason-cyber-escape-root
```

It detects your real username from `$SUDO_USER`, `logname`, or `who`, then
`exec su -` back to that user. Prompts you if auto-detection fails.

### `mason-cyber-netinfo` — show network configuration

```bash
mason-cyber-netinfo
```

Prints your IPv4 addresses (all interfaces), default gateway, and DNS
servers. Useful at the start of any networking or reconnaissance lab.

### `mason-cyber-hashme` — hash files or strings

```bash
mason-cyber-hashme /path/to/file          # hash a file
mason-cyber-hashme -s "some text"         # hash an inline string
```

Outputs **MD5**, **SHA-1**, **SHA-256**, and **SHA-512** in one shot.
Useful for integrity checks, comparing downloads, and crypto unit exercises.

### `mason-cyber-sysinfo` — quick system snapshot

```bash
mason-cyber-sysinfo
```

Prints user, hostname, OS, kernel, CPU, memory, disk usage, and uptime.
Handy for confirming which machine you are on at the start of a lab.

---

## Prompt customization

The bash prompt is configurable without editing files.

**Switch styles at runtime:**

```bash
prompt_short    # compact: user:directory $
prompt_verbose  # full: user@host:directory branch[*] $
```

**Apply a color preset:**

```bash
dotfiles_prompt_preset school        # green/cyan/blue (default)
dotfiles_prompt_preset night         # magenta/blue/cyan
dotfiles_prompt_preset high-contrast # bright colors for accessibility
```

**Persist a style:** add to `~/.profile` before sourcing `.bashrc`:

```bash
export DOTFILES_PROMPT_STYLE=verbose
```

See `docs/CONFIGURE.md` for full details and environment variable reference.

---

## Running the tests

```bash
make test
```

The test suite runs four verification scripts without modifying your real
home directory:

| Script | What it checks |
|---|---|
| `verify_prompt.sh` | Functions defined, `PROMPT_COMMAND` wired, `short ≠ verbose`, all presets work |
| `verify_standard_apps.sh` | Syntax, `list` output content, unknown-arg rejection |
| `verify_install.sh` | Actual symlink install into a temp home; scripts are executable; vim dirs created |
| `verify_scripts.sh` | Syntax, SCRIPTS array coverage, hashme output, sysinfo/netinfo run, escape-root non-root path, colors exec-guard |

---

## License

MIT
