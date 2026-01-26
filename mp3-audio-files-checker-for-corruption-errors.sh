#!/usr/bin/env bash
shopt -s nullglob

read -r -p "Paste path to a folder containing .mp3 files, which should be checked for errors (hit enter to use current folder):" dir && if [[ "$dir" == "" ]]; then dir="$(pwd)"; fi
read -r -p "If possible, play erroneous/incomplete/corrupt files 3 second before error to check? (y/n)" play

for f in "$dir"/*.mp3; do
    filename=$(basename -- "$f");extension="${filename##*.}";filename="${filename%.*}";directory=$(dirname -- "$f");
    err=$(ffmpeg -v error -hide_banner -i "$f" -f null - 2>&1 | sed -e "s|$directory||g" | tee -a corrupt_mp3_files.log)
    if [[ -n $err ]]; then
        echo -e "❌ $f  –  corrupted.\n" | sed -e "s|$directory||g" | tee -a corrupt_mp3_files.log
        # Try to pull a time stamp (HH:MM:SS.xxx) from the error line
        ts=$(echo "$err" | grep -oE '[0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]+' | head -n1)
        #ts=$(echo "$err" | grep -oP 'time=\K[0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]+' | head -n1)
        if [[ -n $ts ]]; then
            if [[ "$play" == "y" ]]; then
            # Play a few seconds *before* the error (if possible)
            echo "Q to stop playback"
            start=$(date -u -d "$ts -3 seconds" +"%H:%M:%S.%N")
            mpv --start=$start "$f"
            fi
        fi
    else
        echo "✅ $f  –  OK"
    fi
done

echo -e "\nListing content of the file corrupt_mp3_files.log:"; cat corrupt_mp3_files.log;
read -r -p "Delete the log? (y=yes, hit enter = no)" dellog; if [[ "$dellog" == y ]]; then rm -f "$dir"/corrupt_mp3_files.log; fi
