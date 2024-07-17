#!/usr/bin/bash
# Bash script for 64bit Linux to download and install/update Proton.me applications.
# IMPORTANT: adjust "sudo dpkg..." installation commands in case you are not on a Debian based Linux distribution.
# IMPORTANT: adjust following variables DOWNLOAD_DIR and PACKAGE_FILE_EXTENSION

set -oue pipefail

## Global variables
DOWNLOAD_DIR="/data/software-packages" # full path where to store downloaded packages
PACKAGE_FILE_EXTENSION=".deb" # .rpm or .deb according to your Linux distribution
JQ_PARSE_RELEASE=".Releases | sort_by(.ReleaseDate) | last"
JQ_PARSE_PACKAGE=".File[] | select(.Identifier | contains(\"$PACKAGE_FILE_EXTENSION\")) | .Url"
JQ_PARSE_SHA512=".File[] | select(.Identifier | contains(\"$PACKAGE_FILE_EXTENSION\")) | .Sha512CheckSum"

## Install/update Proton VPN
# Not included, VPN is in a Proton repository, so it can be updated using package manager: https://protonvpn.com/support/linux-vpn-setup/

## Install/update Proton Mail
echo -e "\nProtonMail:"
PROTON_MAIL_VERSION_FILE="https://proton.me/download/mail/linux/version.json"
PROTON_MAIL_RELEASE_LATEST=$(curl -s "${PROTON_MAIL_VERSION_FILE}" | jq -r "${JQ_PARSE_RELEASE}")
PROTON_MAIL_PACKAGE_URL=$(echo "${PROTON_MAIL_RELEASE_LATEST}" | jq -r "${JQ_PARSE_PACKAGE}")
PROTON_MAIL_PACKAGE_NAME=$(basename "${PROTON_MAIL_PACKAGE_URL}")
PROTON_MAIL_PACKAGE_SHA512=$(echo "${PROTON_MAIL_RELEASE_LATEST}" | jq -r "${JQ_PARSE_SHA512}")
wget --no-verbose --show-progres --continue -O "${DOWNLOAD_DIR}/${PROTON_MAIL_PACKAGE_NAME}" "${PROTON_MAIL_PACKAGE_URL}"
if echo "${PROTON_MAIL_PACKAGE_SHA512} ${DOWNLOAD_DIR}/${PROTON_MAIL_PACKAGE_NAME}" | sha512sum --check; then
  echo "SHA512 checksum verification successful."
  sudo dpkg -i --skip-same-version "${DOWNLOAD_DIR}/${PROTON_MAIL_PACKAGE_NAME}";
else
  echo "SHA512 checksum verification failed. Aborting installation."
  exit 1
fi

## Install/update Proton Pass
echo -e "\nProtonPass:"
PROTON_PASS_VERSION_FILE="https://proton.me/download/PassDesktop/linux/x64/version.json"
PROTON_PASS_RELEASE_LATEST=$(curl -s "${PROTON_PASS_VERSION_FILE}" | jq -r "${JQ_PARSE_RELEASE}")
PROTON_PASS_PACKAGE_URL=$(echo "${PROTON_PASS_RELEASE_LATEST}" | jq -r "${JQ_PARSE_PACKAGE}")
PROTON_PASS_PACKAGE_NAME=$(basename "${PROTON_PASS_PACKAGE_URL}")
PROTON_PASS_PACKAGE_SHA512=$(echo "${PROTON_PASS_RELEASE_LATEST}" | jq -r "${JQ_PARSE_SHA512}")
#wget --no-verbose --show-progres --continue -O "${DOWNLOAD_DIR}/${PROTON_PASS_PACKAGE_NAME}" "${PROTON_PASS_PACKAGE_URL}"
if echo "${PROTON_PASS_PACKAGE_SHA512} ${DOWNLOAD_DIR}/${PROTON_PASS_PACKAGE_NAME}" | sha512sum --check; then
  echo "SHA512 checksum verification successful."
  sudo dpkg -i --skip-same-version "${DOWNLOAD_DIR}/${PROTON_PASS_PACKAGE_NAME}";
else
  echo "SHA512 checksum verification failed. Aborting installation."
  exit 1
fi
