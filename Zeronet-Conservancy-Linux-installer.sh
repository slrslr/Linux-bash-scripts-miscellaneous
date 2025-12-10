#!/bin/bash

read -r -p "Install (i), or update (u): " todo

if [[ "$todo" == "i" ]]; then

echo -e "\nSelect your package manager to install Python and VENV, if it is not installed already:"
select ITEM in "APT" "YUM" "DNF" "PACMAN" "ZYPPER" "Other/Not needed"
do
    case $ITEM in
        "APT")
            sudo apt install git python3-pip python3-venv -y
            sudo apt-get install cron --no-install-recommends -y
            ;;
        "YUM")
            yum install epel-release -y 2>/dev/null
            yum install git python3 python3-wheel virtualenv -y
            yum install cronie --setopt=install_weak_deps=False
            ;;
        "DNF")
            sudo dnf install git python3-pip python3-wheel python-virtualenv -y
            sudo dnf install cronie -y --setopt=install_weak_deps=False
            ;;
        "PACMAN")
            sudo pacman -S git python-pip python3-venv -v --no-confirm
            sudo pacman -S cronie --noconfirm
            ;;
        "ZYPPER")
            sudo zypper install python3-pip python3-setuptools python3-wheel python3-venv
            sudo zypper install cronite --no-recommends
            ;;
        "Other/Not needed")
            ;;
    esac
    break;
done

fi

echo ""; read -er -p "Enter full path where is (or will be) Zeronet Conservancy (ZNC). (default: $HOME/zeronetc - hit enter to confirm) " zndir

if [ -z "$zndir" ] || [[ "$zndir" =~ \$ ]] ||! pathchk -p "$zndir" &> /dev/null; then
    zndir="$HOME/zeronetc"
fi

if [[ ! -d "$zndir" ]]; then
        # If ZNC directory does not exist already, it will be initialized using git:
        git clone --recursive "https://github.com/zeronet-conservancy/zeronet-conservancy.git" "$zndir"
        cd "$zndir" || exit
else
        # Otherwise update ZNC:
        cd "$zndir" || exit
        git pull origin main || exit
fi

# Activate Python environment:
/usr/bin/python3 -m venv venv && source venv/bin/activate || exit

# Install ZNC Python modules
python3 -m pip install -r requirements.txt || exit

# Setup easier access to ZNC:
echo -e "$zndir/venv/bin/python3 $zndir/zeronet.py \"\$@\"" > zeronet.sh && chmod +x zeronet.sh
ln -s "$HOME/.local/share/zeronet-conservancy/"{znc.conf,data,log} "$zndir"/ 2>/dev/null

# Ask whether to start ZeroNet and keep it running
if [[ "$todo" == "i" ]]; then
        if [[ ! "$(crontab -l | grep "zeronet")" ]]; then
                if [ -z "$DISPLAY" ]; then
                        echo -e "\nThis computer does not use display, it may be a server, if that is so, enter port number, under which the ZNC WebUI will be publicly available (http://yourServerIP:port)" 
                        read -r -p "Otherwise hit enter to listen only at localhost and default port 43110:" uiport
                        if [[ "$uiport" =~ ^[0-9]+$ ]]; then
                                uiipport=" --ui-ip \"*\" --ui-port $uiport"
                        fi
                        if [[ "$uiport" == "" ]]; then
                                uiport="43110"
                        fi
                fi
                echo ""; read -r -p "Setup a cronjob to start Zeronet in case it is not running? (y/n) " cron
                if [[ "$cron" == "y" ]]; then
                        echo -e "$(crontab -l 2>/dev/null)\n* * * * * $(whoami) pgrep -if 'eronet\.(py|sh)' || $zndir/zeronet.sh$uiipport --no-migrate &" | crontab - && echo "Cronjob was setup. For modification, run: \"crontab -e\""
                else
                        echo "You can uninstall package cron or cronie using your package manager."
                fi
        fi
fi

# Show usage tips:
echo "Crontab currently uses desktop PC command below, so if you are on a headless computer, copy and use following headless command instead in \"crontab -e\""
echo ""
echo "Run ZNC on a desktop PC: $(pwd)/zeronet.sh --no-migrate"
echo "Run ZNC on a headless http://server:$uiport : $(pwd)/zeronet.sh --ui-ip \"*\" --ui-port $uiport --no-migrate"
echo "Run ZNC with --help parameter for help."
