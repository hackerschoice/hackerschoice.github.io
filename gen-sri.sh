#!/usr/bin/env bash
# shellcheck disable=SC2034,SC2320

# Basic SRI hash generator script
# Made by Jiab77 - 2022
#
# Version 0.1.2

# Options
[[ -r $HOME/.debug ]] && set -o xtrace || set +o xtrace

# Colors
NC="\033[0m"
NL="\n"
BLUE="\033[1;34m"
YELLOW="\033[1;33m"
GREEN="\033[1;32m"
RED="\033[1;31m"
WHITE="\033[1;37m"
PURPLE="\033[1;35m"

# Config
USE_OPENSSL=false
USE_SHASUM=false
CREATE_FILE=false
BIN_OPENSSL=$(which openssl 2>/dev/null)
BIN_SHASUM=$(which shasum 2>/dev/null)
BIN_AWK=$(which awk 2>/dev/null)
BIN_XXD=$(which xxd 2>/dev/null)
BIN_BASE64=$(which base64 2>/dev/null)

# Functions
function get_version() {
    grep -i 'version' "$0" | awk '{ print $3 }' | head -n1
}
function gen_openssl_hash() {
    echo -en "${WHITE}Generating SRI hash with ${PURPLE}openssl${WHITE}...${NC}"
    GENERATED_HASH=$(openssl dgst -sha512 -binary < "$1" | openssl base64 -A)
    if [[ -n $GENERATED_HASH ]]; then
        echo -e " ${GREEN}done${NC}${NL}"
    else
        echo -e " ${RED}failed${NC}${NL}"
        exit 1
    fi
    echo -e "${WHITE}Generated hash: ${GREEN}${GENERATED_HASH}${NC}${NL}"
    if [[ $CREATE_FILE == true ]]; then
        echo -n "$GENERATED_HASH" > "${1}.sri"
        RET_CODE_SAVE=$?
        if [[ $RET_CODE_SAVE -eq 0 ]]; then
            echo -e "${WHITE}Saved to: ${YELLOW}${1}.sri${NC}${NL}"
        else
            echo -e "${RED}Error: ${YELLOW}Failed to create file ${PURPLE}${1}.sri${NC}${NL}"
            exit 1
        fi
    fi
}
function gen_sha_hash() {
    echo -en "${WHITE}Generating SRI hash with ${PURPLE}shasum${WHITE}...${NC}"
    GENERATED_HASH=$(shasum -b -a 512 "$1" | awk '{ print $1 }' | xxd -r -p | base64 -w0)
    if [[ -n $GENERATED_HASH ]]; then
        echo -e " ${GREEN}done${NC}${NL}"
    else
        echo -e " ${RED}failed${NC}${NL}"
        exit 1
    fi
    echo -e "${WHITE}Generated hash: ${GREEN}${GENERATED_HASH}${NC}${NL}"
    if [[ $CREATE_FILE == true ]]; then
        echo -n "$GENERATED_HASH" > "${1}.sri"
        RET_CODE_SAVE=$?
        if [[ $RET_CODE_SAVE -eq 0 ]]; then
            echo -e "${WHITE}Saved to: ${YELLOW}${1}.sri${NC}${NL}"
        else
            echo -e "${RED}Error: ${YELLOW}Failed to create file ${PURPLE}${1}.sri${NC}${NL}"
            exit 1
        fi
    fi
}

# Header
echo -e "${NL}${BLUE}Basic SRI hash ${PURPLE}generator${BLUE} script - ${GREEN}v$(get_version)${NC}${NL}"

# Usage
[[ $# -eq 0 || $1 == "-h" || $1 == "--help" ]] && echo -e "${NL}Usage: $(basename "$0") <file> [-s|--save]${NL}" && exit 1

# Checks
[[ $# -gt 2 ]] && echo -e "${RED}Error: ${YELLOW}Too many arguments.${NC}${NL}" && exit 1
if [[ -z $BIN_OPENSSL || -z $BIN_SHASUM ]]; then
    echo -e "${RED}Error: ${YELLOW}You must have at least 'openssl' or 'shasum' installed to run this script.${NC}${NL}"
    exit 1
elif [[ -z $BIN_OPENSSL && -n $BIN_SHASUM ]]; then
    USE_SHASUM=true

    if [[ -z $BIN_AWK && -z $BIN_XXD && -z $BIN_BASE64 ]]; then
        echo -e "${RED}Error: ${YELLOW}You must have 'awk', 'xxd' and 'base64' installed to run 'shasum' method.${NC}${NL}"
        exit 1
    fi
    if [[ -z $BIN_AWK || -z $BIN_XXD || -z $BIN_BASE64 ]]; then
        echo -e "${RED}Error: ${YELLOW}You must have 'awk', 'xxd' and 'base64' installed to run 'shasum' method.${NC}${NL}"
        exit 1
    fi
elif [[ -n $BIN_OPENSSL && -z $BIN_SHASUM ]]; then
    USE_OPENSSL=true
elif [[ -n $BIN_OPENSSL && -n $BIN_SHASUM ]]; then
    USE_OPENSSL=true
fi

# Arguments
[[ $2 == "-s" || $2 == "--save" ]] && CREATE_FILE=true

# Main
if [[ $USE_OPENSSL == true ]]; then
    gen_openssl_hash "$1"
elif [[ $USE_SHASUM == true ]]; then
    gen_sha_hash "$1"
else
    echo -e "${RED}Error: ${YELLOW}Count not find any encoding method.${NC}${NL}"
    exit 1
fi
