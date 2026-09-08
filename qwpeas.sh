#!/usr/bin/env bash
#
# linenum.sh — quick Linux local enumeration checklist runner.
# Prints findings to stdout; intended for interactive use on a foothold.
#
# Usage:
#   ./linenum.sh
#   ./linenum.sh | tee enum-$(hostname)-$(date +%Y%m%d).txt

set -u

# =============================================================================
# Output helpers
# =============================================================================
if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
  RED='\033[0;31m'
  YELLOW='\033[1;33m'
  NC='\033[0m'
else
  RED='' YELLOW='' NC=''
fi

section() { printf '\n%b===[%s]===%b\n' "$RED" "$1" "$NC"; }
item()    { printf '%b%s%b\n' "$YELLOW" "$1" "$NC"; }
nl()      { printf '\n'; }

# =============================================================================
# Worth checking (manual — not automated below)
# =============================================================================
section "Worth Checking but Not Covered"
item "Check for sudo -l"
item "Check for NFS no_root_squash"
item "Check for TMUX session hijacking"
item "Check history for previous commands run by user"
item "Check memory and cache (mimipenguin, LaZagne, firefox_decrypt, etc.)"
nl

# =============================================================================
# General
# =============================================================================
section "General"
item "Kernel version"
uname -a
nl

# =============================================================================
# User / home / auth files
# =============================================================================
section "User Permissions"
id
nl

section "Home Folder"
ls -al ~/
nl

section "passwd, shadow, & opasswd"
ls -l /etc/passwd /etc/shadow /etc/security/opasswd 2>/dev/null
nl

# =============================================================================
# File system
# =============================================================================
section "File System"

item "SUID bits (root-owned)"
find / -user root -perm -4000 -exec ls -ldb {} \; 2>/dev/null
nl

item "SGID bits (root-owned)"
find / -user root -perm -6000 -exec ls -ldb {} \; 2>/dev/null
nl

item "History files"
find / -type f \( -name '*_hist' -o -name '*_history' \) -exec ls -l {} \; 2>/dev/null
nl

item "Database files"
for ext in .sql .db '.*db' '.db*'; do
  printf '\nDB file pattern: %s\n' "$ext"
  find / -name "*${ext}" 2>/dev/null \
    | grep -Ev 'doc|lib|headers|share|man' || true
done
nl

item "TXT / extensionless files under /home"
find /home/* -type f \( -name '*.txt' -o ! -name '*.*' \) 2>/dev/null
nl

item "Scripts / source"
for ext in .py .pyc .pl .go .jar .c .sh; do
  printf '\nFile extension: %s\n' "$ext"
  find / -name "*${ext}" 2>/dev/null \
    | grep -Ev 'doc|lib|headers|share' || true
done
nl

item "Logs with sensitive information"
shopt -s nullglob
for log in /var/log/*; do
  [[ -f "$log" && -r "$log" ]] || continue
  if grep -Eq 'accepted|session opened|session closed|failure|failed|ssh|password changed|new user|delete user|sudo|COMMAND=|logs' "$log" 2>/dev/null; then
    printf '\n#### Log file: %s\n' "$log"
    grep -E 'accepted|session opened|session closed|failure|failed|ssh|password changed|new user|delete user|sudo|COMMAND=|logs' "$log" 2>/dev/null || true
  fi
done
shopt -u nullglob
nl

item "Configuration files"
find / ! -path '*/proc/*' -iname '*config*' -type f 2>/dev/null
for ext in .conf .config .cnf; do
  printf '\nFile extension: %s\n' "$ext"
  find / ! -path '*proc*' -name "*${ext}" 2>/dev/null \
    | grep -Ev 'lib|fonts|share|core' || true
done
nl

item "Files we don't own but can write to"
find / -type f -writable ! -user "$(whoami)" 2>/dev/null
nl

# =============================================================================
# Network / services
# =============================================================================
section "Running Services"
ss -nltu
nl
