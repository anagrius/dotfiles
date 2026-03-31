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

# opencode
export PATH=/home/thomas/.opencode/bin:$PATH
export PATH="$HOME/.local/bin:$PATH"

# Private credentials (API keys, tokens, etc)
[[ -f ~/.secrets ]] && source ~/.secrets

# Git worktree switcher (sorted by creation time)
gw() {
  local worktrees
  worktrees=$(git worktree list --porcelain 2>/dev/null | grep '^worktree ' | sed 's/^worktree //')
  if [[ -z "$worktrees" ]]; then
    echo "Not in a git repository or no worktrees found" >&2
    return 1
  fi

  local selected
  selected=$(
    while IFS= read -r wt; do
      local btime
      btime=$(stat -c '%W' "$wt" 2>/dev/null)
      [[ "$btime" == "0" || -z "$btime" ]] && btime=$(stat -c '%Y' "$wt" 2>/dev/null)
      local date
      date=$(date -d "@$btime" '+%Y-%m-%d %H:%M' 2>/dev/null)
      local branch
      branch=$(git -C "$wt" branch --show-current 2>/dev/null)
      [[ -z "$branch" ]] && branch="(detached)"
      printf '%s\t%s\t%s\t%s\n' "$btime" "$date" "$branch" "$wt"
    done <<< "$worktrees" | sort -rn -k1,1 | awk -F'\t' '{printf "%-18s  %-30s  %s\n", $2, $3, $4}' |
    fzf --prompt="worktree> " --height=40% --reverse
  )

  [[ -z "$selected" ]] && return 0
  local dir
  dir=$(echo "$selected" | awk '{print $NF}')
  cd "$dir" || return 1
}

gwd() {
  local worktrees
  worktrees=$(git worktree list --porcelain 2>/dev/null | grep '^worktree ' | sed 's/^worktree //')
  if [[ -z "$worktrees" ]]; then
    echo "Not in a git repository or no worktrees found" >&2
    return 1
  fi

  # Exclude the main worktree (first one listed)
  local main_wt
  main_wt=$(echo "$worktrees" | head -1)
  worktrees=$(echo "$worktrees" | tail -n +2)
  if [[ -z "$worktrees" ]]; then
    echo "No secondary worktrees to delete" >&2
    return 1
  fi

  local selected
  selected=$(
    while IFS= read -r wt; do
      local btime
      btime=$(stat -c '%W' "$wt" 2>/dev/null)
      [[ "$btime" == "0" || -z "$btime" ]] && btime=$(stat -c '%Y' "$wt" 2>/dev/null)
      local date
      date=$(date -d "@$btime" '+%Y-%m-%d %H:%M' 2>/dev/null)
      local branch
      branch=$(git -C "$wt" branch --show-current 2>/dev/null)
      [[ -z "$branch" ]] && branch="(detached)"
      printf '%s\t%s\t%s\t%s\n' "$btime" "$date" "$branch" "$wt"
    done <<< "$worktrees" | sort -rn -k1,1 | awk -F'\t' '{printf "%-18s  %-30s  %s\n", $2, $3, $4}' |
    fzf --prompt="delete worktree> " --height=40% --reverse
  )

  [[ -z "$selected" ]] && return 0
  local dir
  dir=$(echo "$selected" | awk '{print $NF}')

  echo "Delete worktree: $dir"
  read -rp "Confirm? [y/N] " confirm
  [[ "$confirm" != [yY] ]] && echo "Cancelled." && return 0

  git worktree remove "$dir" && echo "Removed worktree: $dir"
}

# peon-ping quick controls
alias peon="bash /home/thomas/.claude/hooks/peon-ping/peon.sh"
[ -f /home/thomas/.claude/hooks/peon-ping/completions.bash ] && source /home/thomas/.claude/hooks/peon-ping/completions.bash
