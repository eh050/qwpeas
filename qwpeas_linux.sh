#!/bin/bash

# Define color variables
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'       # No Color (Reset)

function new_line() {
    echo ""
}

function c_red() {
    echo -e "${RED}===[$1]===${NC}"
}

function c_yellow() {
    echo -e "${YELLOW}$1${NC}"
}

c_red "Worth Checking but Not Covered"
c_yellow "Check for sudo -l"
c_yellow "Check for NFS no_root_squash"
c_yellow "Check for TMUX session hijacking"
c_yellow "Check history for previous commands run by user"
c_yellow "Check memory and cache information (mimipenguin, LaZagne, FFoxDecrypt, etc"
new_line

c_red "General"
c_yellow "Kenerl Version"
uname -a 
new_line

c_red "User Permissions"
id
new_line

c_yello "Home Folder"
ls -al ~/
new_line

c_yellow "passwd, shadow, & opasswd"
ls -l /etc/passwd
ls -l /etc/shadow
ls -l /etc/security/opasswd
new_line

c_red "File System"
c_yellow "SUID & GUID bits"
find / -user root -perm -4000 -exec ls -ldb {} \; 2>/dev/null
find / -user root -perm -6000 -exec ls -ldb {} \; 2>/dev/null
new_line

c_yellow "History Files"
find / -type f \( -name *_hist -o -name *_history \) -exec ls -l {} \; 2>/dev/null
new_line

c_yellow "Database Files"
for l in $(echo ".sql .db .*db .db*");do echo -e "\nDB File extension: " $l; find / -name *$l 2>/dev/null | grep -v "doc\|lib\|headers\|share\|man";done
new_line

c_yellow "TXT Files"
find /home/* -type f -name "*.txt" -o ! -name "*.*"
new_line

c_yellow "Scripts"
for l in $(echo ".py .pyc .pl .go .jar .c .sh");do echo -e "\nFile extension: " $l; find / -name *$l 2>/dev/null | grep -v "doc\|lib\|headers\|share";done
new_line

c_yellow "Logs with Sensitive Information"
for i in $(ls /var/log/* 2>/dev/null);do GREP=$(grep "accepted\|session opened\|session closed\|failure\|failed\|ssh\|password changed\|new user\|delete user\|sudo\|COMMAND\=\|logs" $i 2>/dev/null); if [[ $GREP ]];then echo -e "\n#### Log file: " $i; grep "accepted\|session opened\|session closed\|failure\|failed\|ssh\|password changed\|new user\|delete user\|sudo\|COMMAND\=\|logs" $i 2>/dev/null;fi;done
new_line

c_yellow "Configuration Files"
find / ! -path "*/proc/*" -iname "*config*" -type f 2>/dev/null
for l in $(echo ".conf .config .cnf");do echo -e "\nFile extension: " $l; find / ! -path "*proc*" -name *$l 2>/dev/null | grep -v "lib\|fonts\|share\|core" ;done
new_line

c_yellow "Files we don't own but can write to"
find / -type f -writable ! -user $(whoami) 2>/dev/null
new_line

c_red "Running Services"
ss -nltu
