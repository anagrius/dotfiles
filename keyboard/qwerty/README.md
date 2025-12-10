# Nordic Keyboard Layout

Custom keyboard layout for Danish and Swedish characters on a US QWERTY layout, designed to work with Omarchy (Arch Linux + Hyprland + fcitx5).

## Character Mappings

All Nordic characters are accessed via **Right-Alt** (AltGr):

**Danish characters:**
- `Right-Alt + ;` → æ (Right-Alt + Shift + ; → Æ)
- `Right-Alt + '` → ø (Right-Alt + Shift + ' → Ø)
- `Right-Alt + [` → å (Right-Alt + Shift + [ → Å)

**Swedish characters:**
- `Right-Alt + ]` → ä (Right-Alt + Shift + ] → Ä)
- `Right-Alt + \` → ö (Right-Alt + Shift + \ → Ö)
- `Right-Alt + [` → å (Right-Alt + Shift + [ → Å) (same as Danish)

## Installation

This setup works with Omarchy's default configuration (Hyprland + fcitx5).

### 1. Install the XKB Nordic variant

The Nordic variant needs to be added to the system's US keyboard layout file:

```bash
# Backup current us symbols file
sudo cp /usr/share/X11/xkb/symbols/us /usr/share/X11/xkb/symbols/us.backup

# Append Nordic variant to us symbols file
sudo bash -c 'cat us-nordic-variant >> /usr/share/X11/xkb/symbols/us'
```

### 2. Configure Hyprland input

Your Hyprland input configuration should be set to use the Nordic variant.

In `~/.config/hypr/input.conf`:

```
input {
  kb_layout = us
  kb_variant = nordic
  kb_options = compose:caps

  # ... other input settings ...
}
```

Then reload Hyprland:

```bash
hyprctl reload
```

### 3. Verify fcitx5 is configured correctly

Ensure fcitx5 doesn't override XKB settings. In `~/.config/fcitx5/config`:

```ini
[Behavior]
# Override XKB Option
OverrideXkbOption=False
```

### 4. Ensure fcitx5 environment variables are set

In `~/.config/environment.d/fcitx.conf`:

```
INPUT_METHOD=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
SDL_IM_MODULE=fcitx
```

### 5. Restart your session

Logout and login again, or restart Hyprland for all changes to take effect.

## Files in this directory

- `us-nordic-variant` - The working XKB variant definition (append to `/usr/share/X11/xkb/symbols/us`)
- `install.sh` - Interactive installation script (legacy, may need updates)
- `keyd.conf` - Alternative keyd configuration for native Wayland
- `XCompose` - Compose key sequences (alternative method)
- `us-nordic` - Standalone layout file (not used in current setup)
- `nordic` - Legacy layout file (not used)

## Troubleshooting

**Double quotes and other Shift keys not working:**
- This means the XKB variant has incorrect key level definitions
- Ensure you're using `us-nordic-variant` which has proper `FOUR_LEVEL_ALPHABETIC` types
- Revert to standard US layout: Set `kb_variant =` (empty) in `~/.config/hypr/input.conf`

**Nordic characters not working:**
- Check the layout is active: `hyprctl devices | grep -A8 "your-keyboard-name"`
- Should show: `v "nordic"` and `active keymap: English (US) with Nordic`
- If fcitx5 is interfering, ensure `OverrideXkbOption=False` in fcitx5 config

**fcitx5 breaking input:**
- fcitx5 should run in the background with Omarchy defaults
- Don't kill fcitx5 in autostart
- Environment variables should be set in `~/.config/environment.d/fcitx.conf`
- fcitx5 must not override XKB settings (check config file)

**Layout doesn't persist after reboot:**
- The Hyprland config is symlinked from dotfiles, so it should persist
- The XKB variant in `/usr/share/X11/xkb/symbols/us` will be overwritten on `xkeyboard-config` package updates
- After package updates, re-run step 1 to append the Nordic variant again

## After xkeyboard-config Package Updates

The `xkeyboard-config` package contains the system keyboard layouts. When this package updates, it overwrites `/usr/share/X11/xkb/symbols/us`, which removes your Nordic variant.

### Check if update is available

```bash
pacman -Qu | grep xkeyboard-config
```

### Update the package

```bash
# Update single package
sudo pacman -S xkeyboard-config

# Or update all packages (recommended)
sudo pacman -Syu
```

### Re-apply the Nordic variant

After updating `xkeyboard-config`, you must re-append the Nordic variant:

```bash
cd ~/code/dotfiles/keyboard/qwerty
sudo bash -c 'cat us-nordic-variant >> /usr/share/X11/xkb/symbols/us'
hyprctl reload
```

**Note:** Your Hyprland config already has `kb_variant = nordic` set, so you don't need to change that. You only need to re-append the variant definition to the system file.

## How it works

This setup uses Hyprland's native XKB configuration to set the keyboard layout. fcitx5 runs in the background for input method support (emoji, compose sequences, etc.) but doesn't override the XKB keyboard layout because `OverrideXkbOption=False` is set in its configuration.

The Nordic variant is defined as a standard XKB variant that extends the US layout with 4-level keys (normal, Shift, Right-Alt, Right-Alt+Shift) for Nordic characters.
