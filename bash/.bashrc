# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source ~/.local/share/omarchy/default/bash/rc

# Add your own exports, aliases, and functions here.
#
# Make an alias for invoking commands you use constantly
# alias p='python'

# Editor (omarchy sets this in uwsm/default but that only applies to UWSM session, not shells)
source ~/.config/uwsm/default

# Claude Code
alias c='npx "@anthropic-ai/claude-code"'
alias cc='npx "@anthropic-ai/claude-code" resume'

# opencode
export PATH=/home/thomas/.opencode/bin:$PATH

# mise activation
eval "$(mise activate bash)"
