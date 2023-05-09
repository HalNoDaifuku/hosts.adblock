#!/usr/bin/env bash
set -eu
cd $(dirname $0)

export RED="\033[1;31m%s\033[m\n"
export CYAN="\033[1;36m%s\033[m\n"

export CONVERT_LIST="
StevenBlack/config/unified_hosts.json -> StevenBlack/adblock/unified_hosts.adblock
StevenBlack/config/unified_hosts_fakenews.json -> StevenBlack/adblock/unified_hosts_fakenews.adblock
StevenBlack/config/unified_hosts_gambling.json -> StevenBlack/adblock/unified_hosts_gambling.adblock
StevenBlack/config/unified_hosts_porn.json -> StevenBlack/adblock/unified_hosts_porn.adblock
StevenBlack/config/unified_hosts_social.json -> StevenBlack/adblock/unified_hosts_social.adblock
StevenBlack/config/unified_hosts_fakenews_gamling.json -> StevenBlack/adblock/unified_hosts_fakenews_gamling.adblock
StevenBlack/config/unified_hosts_fakenews_porn.json -> StevenBlack/adblock/unified_hosts_fakenews_porn.adblock
StevenBlack/config/unified_hosts_fakenews_social.json -> StevenBlack/adblock/unified_hosts_fakenews_social.adblock
StevenBlack/config/unified_hosts_gamling_porn.json -> StevenBlack/adblock/unified_hosts_gamling_porn.adblock
StevenBlack/config/unified_hosts_gamling_social.json -> StevenBlack/adblock/unified_hosts_gamling_social.adblock
StevenBlack/config/unified_hosts_porn_social.json -> StevenBlack/adblock/unified_hosts_porn_social.adblock
StevenBlack/config/unified_hosts_fakenews_gambling_porn.json -> StevenBlack/adblock/unified_hosts_fakenews_gambling_porn.adblock
StevenBlack/config/unified_hosts_fakenews_gamling_social.json -> StevenBlack/adblock/unified_hosts_fakenews_gamling_social.adblock
StevenBlack/config/unified_hosts_fakenews_porn_social.json -> StevenBlack/adblock/unified_hosts_fakenews_porn_social.adblock
StevenBlack/config/unified_hosts_gambling_porn_social.json -> StevenBlack/adblock/unified_hosts_gambling_porn_social.adblock
StevenBlack/config/unified_hosts_fakenews_gambling_porn_social.json -> StevenBlack/adblock/unified_hosts_fakenews_gambling_porn_social.adblock
"

# Check command
if ! (type hostlist-compiler > /dev/null 2>&1); then
    printf "${RED}" "Error: hostlist-compiler command not found!"
    exit 1
fi

# Convert
export IFS=$'\n'
for files in ${CONVERT_LIST}
do
    export IFS=$(printf " -> ")
    export FILES_IFS=(${files})

    # Run host-compiler command
    mkdir -p "$(dirname ${FILES_IFS[2]})"
    printf "${CYAN}" "Input config path: ${FILES_IFS[0]}"
    printf "${CYAN}" "Output adblock path: ${FILES_IFS[2]}"
    hostlist-compiler -c "${FILES_IFS[0]}" -o "${FILES_IFS[2]}"

    # Delete the first line
    sed -i.bak '1d' "${FILES_IFS[2]}"

    # Check '# Title:'
    if grep -Eq '# *Title:' "${FILES_IFS[2]}"; then
        sed -i.bak '/^\! Title:/d' "${FILES_IFS[2]}"
    fi

    # Convert comment '#' to '!'
    sed -i.bak 's/^\#/\!/' "${FILES_IFS[2]}"

    export IFS=$'\n'
done

# Delete *.bak files
find . -name '*.bak' -exec rm -f {} \;
