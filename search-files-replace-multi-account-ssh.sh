#!/usr/bin/bash
# Linux bash script to help/assist with a file search, file content search (and replacement) in a remote account(s) via SSH.
# Part of the code is created by AI Lumo. I have tested it and it works, but you are using it on your risk. Make backups and suggest improvements.

set -euo # -e (exit on error), -u (fail on unset variables), -o pipefail (catch failures inside pipes). Without them the script continues after failed commands.

SERVER='RemoteSSHAccessibleComputerHostnameOrIPHere'
PORT='RemoteSSHPortHere'
c="" # n = disable promp whether to continue to a next users/accounts (it will just continue)

#USERS=(remoteusername)
USERS=(
remoteusername1 remoteusername2
remoteusername3 remoteusername4 remoteusernam5
)

replaced_string_file="/dev/shm/ssh_searched.txt" # does not need to exist
replacement_string_file="/dev/shm/ssh_replace.txt" # does not need to exist

select ITEM in "Search in file names" "Search in files content" "Search&replace a string in ONE file content" "Search&replace a string in MULTIPLE files content (folder recursively)" "Exit"

do
    case "$ITEM" in
        "Search in file names")
		echo "find DIR -iname *\"FNAME\"*"
		echo "find DIR | xargs grep FNAME -ls;"
		read -r -p "Enter account to search: " user
		read -r -p "Enter full or partial file name to search for at '$SERVER': " fname && 
		echo "Searching account '$user' for file names containing '$fname' ..." && ssh "$user"@"$SERVER" -p "$PORT" "find . -iname *\"$fname\"*"
            ;;
        "Search in files content")
        echo "grep -Rial \"STRING\" DIR # R recursive, i case insensitive, a binary files, l list file names (not content)"
		read -r -p "Enter account to search: " user
		read -r -p "Enter phrase to search: " phrase
		echo "Searching account '$user' for files containing '$phrase' ..." && ssh "$user"@"$SERVER" -p "$PORT" "grep -Rial \"$phrase\" ."
            ;;
        "Search&replace a string in ONE file content")
	echo "A) WHOLE LINE REPLACE: sed -i \"s|.*GRUB_TIMEOUT_STYLE=.*|GRUB_TIMEOUT_STYLE=menu|g; s|.*GRUB_TIMEOUT=.*|GRUB_TIMEOUT=7|g\" file"
	echo "B) REPLACE: sed -i \"s|search|replace|g\" file"
	read -r -p "1/3 B) Which file should be modified? (enter remote full path or absolute: ./public_html/file)" path
	read -r -p "2/3 B) Which phrase should be searched and replaced? " searched
	read -r -p "3/3 B) Which phrase should be the replacement? " replacement
	for user in "${USERS[@]}"; do
		echo "=== $user: ==="
		ssh "$user"@"$SERVER" -p "$PORT" "cp -p '$path' /dev/shm/" && echo 'Original file has been backed up to remote /dev/shm/' || echo 'Error backing up the file'
		ssh "$user"@"$SERVER" -p "$PORT" "find '$path' -type f -print0 | xargs -0 sed -e 's/$searched/$replacement/g'"
		if [[ "$c" != n ]]; then read -r -p "Hit enter to continue with next user account | type \"n\" and hit enter to continue without asking | hit Ctrl+C to cancel the script." c; fi
	done
            ;;
        "Search&replace a string in MULTIPLE files content (folder recursively)")
	read -r -p "1/6 Which remote user account to search (hit enter to search all): " ua && if [[ "$ua" != "" ]]; then user="$ua"; fi
	read -r -p "2/6 Which file name to search? (For example enter *.html or *): " fname
	read -r -p "3/6 Which path to search (recursively)? (d0 NOT use variable like \$HOME but rather . for a default remote directory or ./public_html) " path
	read -r -p "4/6 Hit enter to open editor and save (Ctrl+S) in it a string to be REPLACED (multiple lines are OK)" c && kate "$replaced_string_file"
	read -r -p "5/6 Hit enter to open editor and save (Ctrl+S) in it a string to be REPLACEMENT (multiple lines are OK)" c && kate "$replacement_string_file"
	read -r -p "Hit enter to search and replace" c
	for user in "${USERS[@]}"; do
		echo "=== $user: ==="
	# shellcheck disable=SC2087
	ssh "$user"@"$SERVER" -p "$PORT" bash -s <<-EOF
	s=\$(echo $(base64 -w0 "$replaced_string_file") | base64 -d)
	r=\$(echo $(base64 -w0 "$replacement_string_file") | base64 -d)
	grep -rlF "\$s" --include='$fname' '$path' 2>/dev/null > /tmp/hl
	: > /tmp/hm
	while IFS= read -r f; do
	stat -c '%a %n' "\${f%/*}" "\$f" >> /tmp/hm
	chmod u+w "\${f%/*}" "\$f"
	done < /tmp/hl
	while IFS= read -r f; do
	c=\$(<"\$f"); n=\${c//"\$s"/\$r}
	if [ "\$n" != "\$c" ]; then
		printf '%s\n' "\$n" > "\$f"
		echo "Modified: \$(readlink -f "\$f")"
	fi
	done < /tmp/hl
	while read -r m p; do chmod "\$m" "\$p"; done < /tmp/hm
	EOF
		if [[ "$c" != n ]] && [[ "$ua" == "" ]]; then read -r -p "Hit enter to continue with next user account | type \"n\" and hit enter to continue without asking | hit Ctrl+C to cancel the script." c; fi
		if [[ "$ua" != "" ]]; then break; fi # Task was defined for just one account, no more iterations
	done
            ;;
        "Exit")
	exit
            ;;
    esac
    break;
done

rm -f "$replaced_string_file" "$replacement_string_file" /tmp/{hm,hl}
