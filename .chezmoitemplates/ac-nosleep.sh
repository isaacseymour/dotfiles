#!/bin/sh
# Follow the power source and disable sleep entirely while on AC.
#
# `pmset disablesleep` is the only setting that stops clamshell (lid-close)
# sleep, but it's system-wide rather than per power source — left on
# permanently a laptop in a bag would stay awake until the battery was flat.
# So we flip it as the power source changes: never sleep on AC (so a locked or
# lid-shut machine keeps its network and remote sessions alive), stock
# behaviour on battery.
#
# Installed root-owned to /usr/local/sbin/ac-nosleep and run as a LaunchDaemon
# by .chezmoiscripts/run_onchange_after_macos-power.sh.tmpl.

set -u

state=""

apply() {
  want="$1"
  if [ "$want" != "$state" ]; then
    /usr/bin/pmset -a disablesleep "$want"
    state="$want"
    echo "$(date '+%Y-%m-%d %H:%M:%S') disablesleep=$want"
  fi
}

# `pmset -g pslog` blocks and prints a "Now drawing from '...'" line on every
# power-source change, plus once on startup — so we react to events instead of
# polling. launchd's KeepAlive restarts us (and re-reads the current state) if
# pmset ever dies.
/usr/bin/pmset -g pslog | while IFS= read -r line; do
  case "$line" in
    *"Now drawing from 'AC Power'"*)      apply 1 ;;
    *"Now drawing from 'Battery Power'"*) apply 0 ;;
  esac
done
