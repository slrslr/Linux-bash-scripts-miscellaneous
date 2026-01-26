#!/usr/bin/env bash
shopt -s nullglob
#set -exu

read -r -p "Paste path to a folder containing audio or video files, which should be checked for errors (hit enter to use current folder):" dir
if [[ "$dir" == "" ]]; then dir="$(pwd)"; fi; if [[ ! -d "$dir" ]]; then echo "No such directory." && exit; fi

read -r -p "If possible, play erroneous/incomplete/corrupt files 3 second before error to check? (y/n)" play

dir=$(realpath -- "$dir");
logname="Corrupt_media_files_in_this_folder.txt"
logfullpath="${dir}/${logname}"; rm "$logfullpath" 2>/dev/null

for f in "$dir"/*.{mp3,flac,m4a,wma,ogg,wav,ape,avi,flv,mov,mp4,mkv,webm,wmv}; do
    err=$(ffmpeg -v error -hide_banner -i "$f" -f null - 2>&1 | tee >(sed "s|$dir/||g" >>"$logfullpath"))
    if [[ -n $err ]]; then
        echo -e "❌ $f  –  corrupted." | tee >(sed "s|$dir/||g" >>"$logfullpath")
        # Try to pull a time stamp (HH:MM:SS.xxx) from the error line
        ts=$(echo "$err" | grep -oE '[0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]+' | head -n1)
        if [[ -n $ts ]]; then
            if [[ "$play" == "y" ]]; then
            # Play a few seconds *before* the error (if possible)
            echo "Q to stop playback"
            start=$(date -u -d "$ts -3 seconds" +"%H:%M:%S.%N")
            mpv --start="$start" "$f"
            fi
        fi
    else
        echo "✅ $f  –  OK"
    fi
done

echo -e "\n=====================\nListing content of the file $logname:"; cat "$logfullpath";
read -r -p "Delete the log? (y=yes, hit enter = no)" dellog; if [[ "$dellog" == y ]]; then rm -f "$logfullpath"; fi
