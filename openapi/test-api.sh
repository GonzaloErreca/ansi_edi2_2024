#!/bin/bash

# --------------------------------------
# Check `curl` availability
# --------------------------------------

which curl &> /dev/null

if (($? != 0)); then
    echo "> curl not found"
    exit 1
fi

# --------------------------------------
# Check `php` availability
# --------------------------------------

which php &> /dev/null

if (($? != 0)); then
    echo "> php not found"
    exit 1
fi

# --------------------------------------
# Get values from bash command-line parameters
# --------------------------------------

HOST="${1:-localhost}"
PORT="${2:-8000}"

# Colors:
# @see https://stackoverflow.com/a/5947802
#
# NO COLOR     0
# Black        0;30     Dark Gray     1;30
# Red          0;31     Light Red     1;31
# Green        0;32     Light Green   1;32
# Brown/Orange 0;33     Yellow        1;33
# Blue         0;34     Light Blue    1;34
# Purple       0;35     Light Purple  1;35
# Cyan         0;36     Light Cyan    1;36
# Light Gray   0;37     White         1;37
#
#      .---------- constant part!
#      vvvv vvvv-- the code from above
# RED='\033[0;31m'
# NC='\033[0m' # No Color
# printf "I ${RED}love${NC} Stack Overflow\n"

# --------------------------------------
# Display message
#
# Flags:
# - 'f': Failure message
# - 's': Success message
# - (empty): Normal message
#
# @param string $1 Message
# @param string $2 Flag
# --------------------------------------
function msg {
    local rd='\033[0;31m'
    local gr='\033[0;32m'
    local nc='\033[0m'

    local message="${1}"
    local flag="${2}"

    if [[ 's' == "${flag}" ]]; then
        echo -e "${gr}[✅ SUCCESS] ${message}${nc}"
    elif [[ 'f' == "${flag}" ]]; then
        echo -e "${rd}[❌ FAILURE] ${message}${nc}"
    else
        echo ">>>>>>>>>>>> ${message}"
    fi
}

# --------------------------------------
# Call cURL command
#
# Use following global variables to return/export values:
#
# - CURL_EXIT_CODE
# - CURL_RESPONSE_HEADER
# - CURL_RESPONSE_DATA
#
# @param string $1 Path
# @param string $2 Method
# @param string $3 Data
# --------------------------------------
function callRestApi {
    CURL_EXIT_CODE=1
    CURL_RESPONSE_HEADER=''
    CURL_RESPONSE_DATA=''

    local path="${1}"
    local method="${2:-GET}"
    local data="${3}"

    if [[ ! -z "${data}" ]]; then
        data="--data ${data}"
    fi

    curl "${HOST}:${PORT}${path}" \
        --request "${method}" \
        --header "Content-Type: application/json" \
        --header "Accept: application/json" \
        --dump-header curl_response_header.txt \
        --output curl_response_data.txt \
        $data &> /dev/null

    CURL_EXIT_CODE=$?

    if [ -f curl_response_header.txt ]; then
        CURL_RESPONSE_HEADER=$(cat curl_response_header.txt)
        rm curl_response_header.txt
    fi

    if [ -f curl_response_data.txt ]; then
        CURL_RESPONSE_DATA=$(cat curl_response_data.txt)
        rm curl_response_data.txt
    fi
}

# --------------------------------------
# Get the value from a response header
#
# @param string $1 Headers list
# @param string $2 Header name
# --------------------------------------
function getValueFromHeader {
    local list="${1}"
    local key="${2}"
    if [[ "code" == "${key}" ]]; then
        echo $(echo "${list}" | grep '^HTTP/' | cut -d' ' -f2 | xargs)
    else
        echo $(echo "${list}" | grep "^${key}:" | cut -d':' -f2 | xargs)
    fi
}

# --------------------------------------
# Count items in JSON list
#
# @param string $1 JSON
# --------------------------------------
function countItemsInJsonList {
    local json="${1}"
    local php=$(cat << PHP
\$list = json_decode('${json}', true);
echo count(\$list);
PHP
)
    echo $(php -r "${php}")
}

# --------------------------------------
# Find an item in a JSON list
#
# @param string $1 JSON
# @param string $2 KEY
# @param string $3 VALUE
# --------------------------------------
function searchByKeyValue {
    local json="${1}"
    local key="${2}"
    local value="${3}"
    local php=$(cat << PHP
\$list = json_decode('${json}', true);
\$value = null;
foreach (\$list as \$item) {
    if ('${value}' == \$item['${key}']) {
        \$value = json_encode(\$item);
        break;
    }
}
echo \$value;
PHP
)
    echo $(php -r "${php}")
}

# --------------------------------------
# Get a value from a JSON string
#
# @param string $1 JSON
# @param string $2 KEY
# --------------------------------------
function getValueFromJson {
    local json="${1}"
    local key="${2}"
    local php=$(cat << PHP
\$list = json_decode('${json}', true);
echo \$list['${key}'];
PHP
)
    echo $(php -r "${php}")
}

# ====================================================================

# --------------------------------------
# Helper to interact with an element
#
# @param string $1 HTTP Verb
# @param string $2 URL Path
# @param string $3 JSON
# --------------------------------------
function elementAction {
    local verb="${1}"
    local path="${2}"
    local json="${3}"

    msg "Call REST API (${verb}) '${path}'"

    callRestApi "${path}" "${verb}" "${json}"

    if (( 0 != "${CURL_EXIT_CODE}" )); then
        msg 'Failed curl call' f
    else
        local code="$(getValueFromHeader "${CURL_RESPONSE_HEADER}" "code")"

        if (( 200 != $code )); then
            msg "(${verb}) '${path}'" f
        fi
    fi
}

# --------------------------------------
# Helper to get an element (or a list)
#
# @param string $1 URL Path
# --------------------------------------
function elementGet {
    local path="${1}"

    elementAction 'GET' "${path}"
}

# --------------------------------------
# Helper to create an element
#
# @param string $1 URL Path
# @param string $2 JSON
# --------------------------------------
function elementCreate {
    local path="${1}"
    local json="${2}"

    elementAction 'POST' "${path}" "${json}"
}

# --------------------------------------
# Helper to update an element
#
# @param string $1 URL Path
# @param string $2 JSON
# --------------------------------------
function elementUpdate {
    local path="${1}"
    local json="${2}"

    elementAction 'PUT' "${path}" "${json}"
}

# --------------------------------------
# Helper to delete an element
#
# @param string $1 URL Path
# --------------------------------------
function elementDelete {
    local path="${1}"

    elementAction 'DELETE' "${path}"
}

# ====================================================================

elementGet '/especie'
elementCreate '/especie' '{"name":"perro"}'
elementGet '/especie/1'
elementUpdate '/especie/1' '{"name":"perro2"}'
elementDelete '/especie/1'
elementGet '/veterinario'
elementCreate '/veterinario' '{"name":"rocky"}'
elementGet '/veterinario/1'
elementUpdate '/veterinario/1' '{"name":"rocky"}'
elementDelete '/veterinario/1'
elementGet '/mascota'
elementCreate '/mascota' '{"name":"Puchi"}'
elementGet '/mascota/1'
elementUpdate '/mascota/1' '{"name":"Puchi2"}'
elementDelete '/mascota/1'
elementGet '/turno'
