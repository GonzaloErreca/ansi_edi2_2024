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
=======
        if [[ "true" == "${STOP_ON_FAILURE}" ]]; then
            exit 1
        fi
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
# --------------------------------------
# Test the creation of a species
#
# @param string $1 Species name (to create)
# --------------------------------------
function testCreateSpecies () {
    local name="${1}"
    local flag=''

    echo '========================================'
    msg 'Test species creation'

    elementCreate '/especie' '{"nombre":"'$name'"}'

    local remote_name=$(getValueFromJson "${CURL_RESPONSE_DATA}" 'nombre')
    flag=$([[ "${remote_name}" == "${name}" ]] && echo "s" || echo "f")
    msg "[new] Species name (${name}, ${remote_name})" "${flag}"

    NEW_ID="$(getValueFromJson "${CURL_RESPONSE_DATA}" "id")"
}

# --------------------------------------
# Test the list of species
#
# @param string $1 Expected amount of species (in the list)
# @param string $2 Expected species id (used if given)
# @param string $3 Expected species name (used if given)
# --------------------------------------
function testListSpecies () {
    local amount="${1}"
    local id="${2}"
    local name="${3}"

    echo '========================================'
    msg 'Test species listing'

    elementGet '/especie'

    local remote_amount=$(countItemsInJsonList "${CURL_RESPONSE_DATA}")
    flag=$( (($remote_amount == $amount)) && echo "s" || echo "f" )
    msg "[list] Amount of species (${amount}, ${remote_amount})" "${flag}"

    if [[ "${id}" ]]; then
        local json=$(searchByKeyValue "${CURL_RESPONSE_DATA}" 'id' "${id}")

        if [[ "${json}" ]]; then
            msg "[list] Species found (ID ${id})" "s"

            if [[ "${name}" ]]; then
                local remote_name=$(getValueFromJson "${json}" 'nombre')
                flag=$([[ "${remote_name}" == "${name}" ]] && echo "s" || echo "f")
                msg "[list] Species name (${name}, ${remote_name})" "${flag}"
            fi
        else
            msg "[list] Species not found (ID ${id})" "f"
        fi
    fi
}

# --------------------------------------
# Test the edition of a species
#
# @param string $1 Species ID (to edit)
# @param string $2 New species name
# --------------------------------------
function testEditSpecies () {
    local id="${1}"
    local name="${2}"

    echo '========================================'
    msg 'Test species edition'

    elementUpdate "/especie/${id}" '{"nombre":"'$name'"}'

    local remote_id=$(getValueFromJson "${CURL_RESPONSE_DATA}" 'id')
    flag=$([[ "${remote_id}" == "${id}" ]] && echo "s" || echo "f")
    msg "[edit] Species id (${id}, ${remote_id})" "${flag}"

    local remote_name=$(getValueFromJson "${CURL_RESPONSE_DATA}" 'nombre')
    flag=$([[ "${remote_name}" == "${name}" ]] && echo "s" || echo "f")
    msg "[edit] Species name (${name}, ${remote_name})" "${flag}"
}

# --------------------------------------
# Test the deletion of a species
#
# @param string $1 Species ID (to edit)
# @param string $2 Species name (used if given)
# --------------------------------------
function testDeleteSpecies () {
    local id="${1}"
    local name="${2}"

    echo '========================================'
    msg 'Test species deletion'

    elementDelete "/especie/${id}"

    local remote_id=$(getValueFromJson "${CURL_RESPONSE_DATA}" 'id')
    flag=$([[ "${remote_id}" == "${id}" ]] && echo "s" || echo "f")
    msg "[delete] Species id (${id}, ${remote_id})" "${flag}"

    if [[ "${name}" ]]; then
        local remote_name=$(getValueFromJson "${CURL_RESPONSE_DATA}" 'nombre')
        flag=$([[ "${remote_name}" == "${name}" ]] && echo "s" || echo "f")
        msg "[delete] Species name (${name}, ${remote_name})" "${flag}"
    fi
}

# ====================================================================

# --------------------------------------
# Test the creation of a pet
#
# @param string $1 Species ID
# @param string $2 pet name
# --------------------------------------
function testCreatePet () {
    local id="${1}"
    local pet_name="${2}"
    local flag=''

    echo '========================================'
    msg 'Test pets creation'

    elementCreate '/mascota' '{"especie_ID":"'$id'","nombre":"'$pet_name'"}'

    local remote_id=$(getValueFromJson "${CURL_RESPONSE_DATA}" 'id')
    flag=$([[ "${remote_id}" == "${id}" ]] && echo "s" || echo "f")
    msg "[post] Species id (${id}, ${remote_id})" "${flag}"

    NEW_ID_PET="$(getValueFromJson "${CURL_RESPONSE_DATA}" "id")"

    local remote_name=$(getValueFromJson "${CURL_RESPONSE_DATA}" 'nombre')
    flag=$([[ "${remote_name}" == "${pet_name}" ]] && echo "s" || echo "f")
    msg "[post] Pet name (${name}, ${remote_name})" "${flag}"
}

# ====================================================================
# --------------------------------------
# Test the listing of pets
#
# @param int $1 amount of pets
# @param string $2 Pet ID 
# @param string $3 Pet name 
# --------------------------------------
function testListPets () {
	local amount="${1}"
	local id="${2}"
	local pet_name="${3}"

	echo '========================================'
	msg 'Test pets listing'

	elementGet '/mascotas'
	local remote_amount=$(countItemsInJsonList "${CURL_RESPONSE_DATA}")
	flag=$([[ "${remote_amount}" -eq "${amount}" ]] && echo "s" || echo "f")
	msg "[list] Amount of pets (${amount}, ${remote_amount})" "${flag}"

	if [[ "${id}" ]]; then
		local json=$(searchByKeyValue "${CURL_RESPONSE_DATA}" 'id' "${id}")
	if [[ "${json}" ]]; then
	msg "[list] Pet found (ID ${id})" "s"

	if [[ "${pet_name}" ]]; then
	local remote_name=$(getValueFromJson "${json}" 'nombre')
	flag=$([[ "${remote_name}" == "${pet_name}" ]] && echo "s" || echo "f")
	msg "[list] Pet name (${pet_name}, ${remote_name})" "${flag}"
	fi		
		local species_id=$(getValueFromJson "${json}" 'id_specie')

		if [[ "${species_id}" ]]; then
		elementGet "/especie/${species_id}"
		local species_name=$(getValueFromJson "${CURL_RESPONSE_DATA}" 'name')
			
		if [[ "${species_name}" ]]; then
		msg "[list] Species name: ${species_name}" "s"
		else
		msg "[list] Species name not found" "f"
		fi
		else
		msg "[list] Species ID not found for pet (ID ${id})" "f"
		fi
		else 
		msg "[list] Pet not found (ID ${id})" "f"
	fi
fi
														
}



# ====================================================================

# --------------------------------------
# Test the deletion of a pet
#
# @param string $1 Pet ID (to edit)
# @param string $2 Pet name (used if given)
# --------------------------------------
function testDeletePet () {
	local id="${1}"
	local name="${2}"
	 echo '========================================'
	 msg 'Test pet deletion'

	 elementDelete "/mascota/${id}"

	local remote_id=$(getValueFromJson "${CURL_RESPONSE_DATA}" 'id')
	flag=$([[ "${remote_id}" == "${id}" ]] && echo "s" || echo "f")
	msg "[delete] Pet id (${id}, ${remote_id})" "${flag}"
	
	if [[ "${name}" ]]; then
		local remote_name=$(getValueFromJson "${CURL_RESPONSE_DATA}" 'nombre')
		flag=$([[ "${remote_name}" == "${name}" ]] && echo "s" || echo "f")	
		msg "[delete] Pet name (${name}, ${remote_name})" "${flag}"
	fi
									}
# ====================================================================

# --------------------------------------
# Test the edition of a Pet
#
#  @param string $1 Pet ID
#  @param string $2 New Pet name
# --------------------------------------
function testEditPet(){
	local id="${1}"
	local name="${2}"

	echo '======================================='
	msg 'Test pet edition'

	elementUpdate "/mascota/${id}" '{"nombre":"'$name'"}'

	local remote_id=$(getValueFromJson "${CURL_RESPONSE_DATA}" 'id')
	flag=$([[ "${remote_id}" == "{id}" ]] && echo "s" || echo "f")
	msg "[info] Pet id (${id}, ${remote_id})" "${flag}"

	local remote_name=$(getValueFromJson "${CURL_RESPONSE_DATA}" 'nombre')
	flag=$([[ "${remote_name}" == "${name}" ]] && echo "s" || echo "f")
	msg "[edit] Pet name (${name}, ${remote_name})" "${flag}"
}

#========================================
# --------------------------------------
# Test the creation of a vet
#
# @param string $1 Vet name (to create)
# --------------------------------------
function testCreateVet(){
	local name="${1}"
	local flag=''

	echo '========================================'
	msg 'Test vet creation'

	elementCreate '/veterinario' '{"nombre":"'$name'"}'
	local remote_name=$(getValueFromJson "${CURL_RESPONSE_DATA}" 'nombre')
	flag=$([[ "${remote_name}" == "${name}" ]] && echo "s" || echo "f")
	msg "[new] Vet name (${name}, ${remote_name})" "${flag}"
	NEW_ID_VET="$(getValueFromJson "${CURL_RESPONSE_DATA}" "id")"
}					

# --------------------------------------
# Test the list of vets
#
# @param string $1 Expected amount of vets (in the list)
# @param string $2 Expected vet id (used if given)
# @param string $3 Expected vet name (used if given)
# --------------------------------------
function testListVets(){
    local amount="${1}"
    local id="${2}"
    local vet_name="${3}"

    echo '========================================'
    msg 'Test vets listing'
    elementGet '/veterinario'
    local remote_amount=$(countItemsInJsonList "${CURL_RESPONSE_DATA}")
    flag=$([[ "${remote_amount}" -eq "${amount}" ]] && echo "s" || echo "f")
    msg "[list] Amount of vets (${amount}, ${remote_amount})" "${flag}"

    if [[ "${id}" ]]; then
        local json=$(searchByKeyValue "${CURL_RESPONSE_DATA}" 'id' "${id}")

        if [[ "${json}" ]]; then
            msg "[list] Vet found (ID ${id})" "s"

            if [[ "${vet_name}" ]]; then
                local remote_name=$(getValueFromJson "${json}" 'nombre')
                flag=$([[ "${remote_name}" == "${vet_name}" ]] && echo "s" || echo "f")
                msg "[list] Vet name (${vet_name}, ${remote_name})" "${flag}"
            fi
        else
            msg "[list] Vet not found (ID ${id})" "f"
        fi
    fi
}
# --------------------------------------
# Test the edition of a vet
#
# @param string $1 Vet ID (to edit)
# @param string $2 New vet name
# --------------------------------------
function testEditVet () {
    local id="${1}"
    local name="${2}"

    echo '========================================'
    msg 'Test vet edition'

    elementUpdate "/veterinario/${id}" '{"nombre":"'$name'"}'

    local remote_id=$(getValueFromJson "${CURL_RESPONSE_DATA}" 'id')
    flag=$([[ "${remote_id}" == "${id}" ]] && echo "s" || echo "f")
    msg "[edit] Vet id (${id}, ${remote_id})" "${flag}"

    local remote_name=$(getValueFromJson "${CURL_RESPONSE_DATA}" 'nombre')
    flag=$([[ "${remote_name}" == "${name}" ]] && echo "s" || echo "f")
    msg "[edit] Vet name (${name}, ${remote_name})" "${flag}"
}
# ====================================================================

# Species battery of tests
# ------------------------
	
testListSpecies 0

SPECIES_DOG_NAME='perroxxxx'
testCreateSpecies "${SPECIES_DOG_NAME}"
SPECIES_DOG_ID="${NEW_ID}"
testListSpecies 1 "${SPECIES_DOG_ID}" "${SPECIES_DOG_NAME}"
SPECIES_DOG_NAME='perro'
testEditSpecies "${SPECIES_DOG_ID}" "${SPECIES_DOG_NAME}"
testListSpecies 1 "${SPECIES_DOG_ID}" "${SPECIES_DOG_NAME}"

SPECIES_CAT_NAME='gatoxxxx'
testCreateSpecies "${SPECIES_CAT_NAME}"
SPECIES_CAT_ID="${NEW_ID}"
testListSpecies 2 "${SPECIES_CAT_ID}" "${SPECIES_CAT_NAME}"
SPECIES_CAT_NAME='gato'
testEditSpecies "${SPECIES_CAT_ID}" "${SPECIES_CAT_NAME}"
testListSpecies 2 "${SPECIES_CAT_ID}" "${SPECIES_CAT_NAME}"

SPECIES_TMP_NAME='conejoxxxx'
testCreateSpecies "${SPECIES_TMP_NAME}"
SPECIES_TMP_ID="${NEW_ID}"
testListSpecies 3 "${SPECIES_TMP_ID}" "${SPECIES_TMP_NAME}"
SPECIES_TMP_NAME='conejo'
testEditSpecies "${SPECIES_TMP_ID}" "${SPECIES_TMP_NAME}"
testListSpecies 3 "${SPECIES_TMP_ID}" "${SPECIES_TMP_NAME}"

testDeleteSpecies "${SPECIES_TMP_ID}" "${SPECIES_TMP_NAME}"
testListSpecies 2 "${SPECIES_DOG_ID}" "${SPECIES_DOG_NAME}"
testListSpecies 2 "${SPECIES_CAT_ID}" "${SPECIES_CAT_NAME}"

PET_NAME='bobby'
testCreatePet "${NEW_ID}" "${PET_NAME}"
NEW_ID_PET 1

