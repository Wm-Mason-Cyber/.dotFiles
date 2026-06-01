.dotfiles docs
==============

This folder contains a small machine-readable manifest and human-readable notes about the repository's goals and how to use it in classroom automation.

Files
- `manifest.json` - JSON manifest listing project metadata, goals, platforms, entrypoints, and recommended packages.

Purpose
- Make the repository easier to discover and integrate into classroom provisioning scripts.
- Provide a single source of truth for what the dotfiles install and the packages recommended for students.

Usage
- Automation tools can read `docs/manifest.json` to learn what to install or link.
- Instructors can use `install.sh` to copy or symlink the files into student accounts.
- Use `standard-apps.sh list` to see recommended packages; `standard-apps.sh install` attempts to install them with the detected package manager.

Notes
- The scripts are intentionally conservative and prompt before overwriting existing files unless `--force` is passed.
- The repo does not configure a global gitignore by default to avoid hiding files from students.

Prompt color configuration
--
This dotfiles set provides a colorful, informative PS1 prompt by default. The following environment variables can be set (by instructors or students) before sourcing `~/.bashrc` to customize colors. Values may be either the raw `tput` sequence (e.g. the output of `tput setaf 2`) or an ANSI escape sequence.

- `DOTFILES_PS_USER_COLOR`   - color for the username (default: green)
- `DOTFILES_PS_HOST_COLOR`   - color for the hostname (default: cyan)
- `DOTFILES_PS_CWD_COLOR`    - color for the working directory (default: blue)
- `DOTFILES_PS_GIT_COLOR`    - color for the git branch indicator (default: yellow)
- `DOTFILES_PS_ROOT_COLOR`   - color for the prompt symbol when root (default: red)

If `tput` is available and supports colors, sensible defaults are chosen. To override, set the variables in your environment or in `~/.profile` before sourcing `~/.bashrc`:

```bash
# Example: prefer bright magenta username and dim cwd
export DOTFILES_PS_USER_COLOR="$(tput setaf 5)"
export DOTFILES_PS_CWD_COLOR="$(tput setaf 8)"
```

Notes:
- The prompt includes a lightweight git branch indicator when inside a repository.
- The prompt shows `#` for root and `$` for normal users; the symbol is colored using `DOTFILES_PS_ROOT_COLOR` for root and `DOTFILES_PS_USER_COLOR` for normal users.

Prompt styles
--
You can change the prompt style using `DOTFILES_PROMPT_STYLE` (defaults to `short`). Available values:

- `short` (default): shows `user:cwd $` — compact and easy for beginners
- `verbose`: shows `user@host:cwd branch[*] $` — includes git branch and dirty indicator

Runtime helpers:

- `prompt_short` — switch to the short prompt immediately
- `prompt_verbose` — switch to the verbose prompt immediately

Examples:

```bash
# set verbose by default in ~/.profile
export DOTFILES_PROMPT_STYLE=verbose

# or switch on the fly
prompt_verbose
```

Presets
--
Three named color presets are provided via the helper `dotfiles_prompt_preset`:

- `dotfiles_prompt_preset school` — the default classroom-friendly palette (green/cyan/blue/yellow)
- `dotfiles_prompt_preset night` — comfortable darker palette (magenta/blue/cyan)
- `dotfiles_prompt_preset high-contrast` — bright/high-contrast colors for accessibility

Usage example:

```bash
# choose a preset and use verbose prompt
dotfiles_prompt_preset school
prompt_verbose
```

