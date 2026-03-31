# dotfiles

Thomas Anagrius's dotfiles for Arch Linux.

## Quick Start

```bash
# Install packages (yay, sops, age, trufflehog, etc.)
./install.sh

# Install dotfiles + decrypt secrets
make stow
```

## Structure

Each directory is a stow package that gets symlinked to `~`:

- `bash/` - Bash configuration
- `git/` - Global git hooks (trufflehog pre-push secret scanning)
- `hypr/` - Hyprland window manager
- `keyboard/` - Glove80 keyboard firmware tools
- `nvim/` - Custom neovim plugins (layered on top of Omarchy's LazyVim)
- `wireplumber/` - PipeWire/WirePlumber audio config

## Secrets

Secrets are stored encrypted with [sops](https://github.com/getsops/sops) + [age](https://github.com/FiloSottile/age) in `secrets.enc.env`.

```bash
# Decrypt secrets to ~/.secrets (also runs with make stow)
make secrets

# Edit secrets (decrypts, opens editor, re-encrypts on save)
make secrets-edit
```

Your `.bashrc` sources `~/.secrets` automatically. The age private key is backed up in Proton Pass under `sops/age-key`.

```bash
# On a fresh machine, after logging into Proton Pass:
pass-cli login
make secrets-restore-key  # restore age key from Proton Pass
make secrets              # decrypt secrets
```

A [trufflehog](https://github.com/trufflesecurity/trufflehog) pre-push hook is installed globally via `core.hooksPath` to catch leaked secrets before they reach a remote.

## Requirements

- Arch Linux
- GNU Stow (`pacman -S stow`)
