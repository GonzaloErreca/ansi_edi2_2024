#!/bin/bash

# @see https://stackoverflow.com/a/4774063
SCRIPTPATH="$( cd -- "$(dirname "$0")" > /dev/null 2>&1; pwd -P )"

# Move to script's upper directory
cd "${SCRIPTPATH}/.."

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
# Test the creation of a Pet
#
# @param string $1 Pet name (to create)
# @param int $2 Species ID (to asign)
# --------------------------------------
function testCreatePet () {
    local name="${1}"
    local species_id="${2}"
    local flag=''

    echo '========================================'
    msg 'Test pet creation'

    elementCreate '/mascota' '{"nombre":"'$name'","especie_id":"'$species_id'"}'

    local remote_name=$(getValueFromJson "${CURL_RESPONSE_DATA}" 'nombre')
    flag=$([[ "${remote_name}" == "${name}" ]] && echo "s" || echo "f")
    msg "[new] Pet name (${name}, ${remote_name})" "${flag}"

    local remote_pet_id=$(getValueFromJson "${CURL_RESPONSE_DATA}" 'especie_id')
    flag=$([[ "${remote_pet_id}" == "${species_id}" ]] && echo "s" || echo "f")
    msg "[new] Species ID (${remote_pet_id}, ${species_id})" "${flag}"

    NEW_ID="$(getValueFromJson "${CURL_RESPONSE_DATA}" "id")"
}

# --------------------------------------
# Test the list of pets
#
# @param string $1 Expected amount of pets (in the list)
# @param string $2 Expected pets id (used if given)
# @param string $3 Expected pets name (used if given)
# @param string $4 Expected species id (used if given)
# --------------------------------------
function testListPets () {
    local amount="${1}"
    local id="${2}"
    local name="${3}"
    local species_id="${4}"
    local flag=''

    echo '========================================'
    msg 'Test pets listing'

    elementGet '/mascota'

    local remote_amount=$(countItemsInJsonList "${CURL_RESPONSE_DATA}")
    flag=$( (($remote_amount == $amount)) && echo "s" || echo "f" )
    msg "[list] Amount of pets (${amount}, ${remote_amount})" "${flag}"

    if [[ "${id}" ]]; then
        local json=$(searchByKeyValue "${CURL_RESPONSE_DATA}" 'id' "${id}")

        if [[ "${json}" ]]; then
            msg "[list] Pet found (ID ${id})" "s"

            if [[ "${name}" ]]; then
                local remote_name=$(getValueFromJson "${json}" 'nombre')
                flag=$([[ "${remote_name}" == "${name}" ]] && echo "s" || echo "f")
                msg "[list] Pet name (${name}, ${remote_name})" "${flag}"
            fi

            if [[ "${species_id}" ]]; then
                local remote_species=$(getValueFromJson "${json}" 'especie_id')
                flag=$([[ "${remote_name}" == "${name}" ]] && echo "s" || echo "f")
                msg "[list] Species ID (${species_id}, ${remote_species})" "${flag}"
            fi
        else
            msg "[list] Pet not found (ID ${id})" "f"
        fi
    fi
}

# --------------------------------------
# Test the edition of a pet
#
# @param string $1 Pet ID
# @param string $2 Pet name (to edit)
# @param string $3 Species ID (to edit)
# --------------------------------------
function testEditPet () {
    local id="${1}"
    local name="${2}"
    local species_id="${3}"
    local flag=''

    echo '========================================'
    msg 'Test pet edition'

    elementUpdate "/mascota/${id}" '{"especie_id":"'$species_id'","nombre":"'$name'"}'

    local remote_id=$(getValueFromJson "${CURL_RESPONSE_DATA}" 'id')
    flag=$([[ "${remote_id}" == "${id}" ]] && echo "s" || echo "f")
    msg "[edit] Pet ID (${id}, ${remote_id})" "${flag}"

    local remote_name=$(getValueFromJson "${CURL_RESPONSE_DATA}" 'nombre')
    flag=$([[ "${remote_name}" == "${name}" ]] && echo "s" || echo "f")
    msg "[edit] Pet name (${name}, ${remote_name})" "${flag}"

    local remote_species_id=$(getValueFromJson "${CURL_RESPONSE_DATA}" 'especie_id')
    flag=$([[ "${remote_species_id}" == "${species_id}" ]] && echo "s" || echo "f")
    msg "[edit] Species ID (${species_id}, ${remote_species_id})" "${flag}"
}

# --------------------------------------
# Test the deletion of a pet
#
# @param string $1 Pet ID (to delete)
# @param string $2 Pet name (to delete)
# @param string $3 Species ID (to delete)
# --------------------------------------
function testDeletePet () {
    local id="${1}"
    local name="${2}"
    local species_id="${3}"
    local flag=''

    echo '========================================'
    msg 'Test pet deletion'

    elementDelete "/mascota/${id}"

    local remote_id=$(getValueFromJson "${CURL_RESPONSE_DATA}" 'id')
    flag=$([[ "${remote_id}" == "${id}" ]] && echo "s" || echo "f")
    msg "[delete] Pet ID (${id}, ${remote_id})" "${flag}"

    local remote_name=$(getValueFromJson "${CURL_RESPONSE_DATA}" 'nombre')
    flag=$([[ "${remote_name}" == "${name}" ]] && echo "s" || echo "f")
    msg "[delete] Pet name (${name}, ${remote_name})" "${flag}"

    local remote_species_id=$(getValueFromJson "${CURL_RESPONSE_DATA}" 'especie_id')
    flag=$([[ "${remote_species_id}" == "${species_id}" ]] && echo "s" || echo "f")
    msg "[delete] Species ID (${species_id}, ${remote_species_id})" "${flag}"
}

# ====================================================================

# --------------------------------------
# Test the creation of a vets
#
# @param string $1 Vets name (to create)
# --------------------------------------
function testCreateVets () {
    local name="${1}"
    local flag=''

    echo '========================================'
    msg 'Test vets creation'

    elementCreate '/veterinario' '{"nombre":"'$name'"}'

    local remote_name=$(getValueFromJson "${CURL_RESPONSE_DATA}" 'nombre')
    flag=$([[ "${remote_name}" == "${name}" ]] && echo "s" || echo "f")
    msg "[new] Vets name (${name}, ${remote_name})" "${flag}"

    NEW_ID="$(getValueFromJson "${CURL_RESPONSE_DATA}" "id")"
}

# --------------------------------------
# Test the list of vets
#
# @param string $1 Expected amount of vets (in the list)
# @param string $2 Expected vets id (used if given)
# @param string $3 Expected vets name (used if given)
# --------------------------------------
function testListVets () {
    local amount="${1}"
    local id="${2}"
    local name="${3}"

    echo '========================================'
    msg 'Test vets listing'

    elementGet '/veterinario'

    local remote_amount=$(countItemsInJsonList "${CURL_RESPONSE_DATA}")
    flag=$( (($remote_amount == $amount)) && echo "s" || echo "f" )
    msg "[list] Amount of vets (${amount}, ${remote_amount})" "${flag}"

    if [[ "${id}" ]]; then
        local json=$(searchByKeyValue "${CURL_RESPONSE_DATA}" 'id' "${id}")

        if [[ "${json}" ]]; then
            msg "[list] Vets found (ID ${id})" "s"

            if [[ "${name}" ]]; then
                local remote_name=$(getValueFromJson "${json}" 'nombre')
                flag=$([[ "${remote_name}" == "${name}" ]] && echo "s" || echo "f")
                msg "[list] Vets name (${name}, ${remote_name})" "${flag}"
            fi
        else
            msg "[list] Vets not found (ID ${id})" "f"
        fi
    fi
}

# --------------------------------------
# Test the edition of a vets
#
# @param string $1 Vets ID (to edit)
# @param string $2 New vets name
# --------------------------------------
function testEditVets () {
    local id="${1}"
    local name="${2}"

    echo '========================================'
    msg 'Test vets edition'

    elementUpdate "/veterinario/${id}" '{"nombre":"'$name'"}'

    local remote_id=$(getValueFromJson "${CURL_RESPONSE_DATA}" 'id')
    flag=$([[ "${remote_id}" == "${id}" ]] && echo "s" || echo "f")
    msg "[edit] Vets id (${id}, ${remote_id})" "${flag}"

    local remote_name=$(getValueFromJson "${CURL_RESPONSE_DATA}" 'nombre')
    flag=$([[ "${remote_name}" == "${name}" ]] && echo "s" || echo "f")
    msg "[edit] Vets name (${name}, ${remote_name})" "${flag}"
}

# --------------------------------------
# Test the deletion of a vets
#
# @param string $1 Vets ID (to edit)
# @param string $2 Vets name (used if given)
# --------------------------------------
function testDeleteVets () {
    local id="${1}"
    local name="${2}"

    echo '========================================'
    msg 'Test vets deletion'

    elementDelete "/veterinario/${id}"

    local remote_id=$(getValueFromJson "${CURL_RESPONSE_DATA}" 'id')
    flag=$([[ "${remote_id}" == "${id}" ]] && echo "s" || echo "f")
    msg "[delete] Vets id (${id}, ${remote_id})" "${flag}"

    if [[ "${name}" ]]; then
        local remote_name=$(getValueFromJson "${CURL_RESPONSE_DATA}" 'nombre')
        flag=$([[ "${remote_name}" == "${name}" ]] && echo "s" || echo "f")
        msg "[delete] Vets name (${name}, ${remote_name})" "${flag}"
    fi
}

# ====================================================================

# --------------------------------------
# Test the list of available appointments
#
# @param string $1 Expected amount of appointments (in the list)
# @param string $2 Index to get an appointment from (used if given)
# @param string $3 Expected appointment from the given index (used if given)
# --------------------------------------
function testAvailableAppointments () {
    local amount="${1}"
    local index="${2}"
    local to_check="${3}"
    local flag=''

    APPOINTMENT_FOUND=''

    echo '========================================'
    msg 'Test appointments listing'

    elementGet '/disponibles'

    local remote_amount=$(countItemsInJsonList "${CURL_RESPONSE_DATA}")
    flag=$( (($remote_amount == $amount)) && echo "s" || echo "f" )
    msg "[list] Amount of appointments (${amount}, ${remote_amount})" "${flag}"

    if [[ "${index}" ]]; then
        local item_found=$(getValueFromJson "${CURL_RESPONSE_DATA}" "${index}")

        if [[ "${item_found}" ]]; then
            APPOINTMENT_FOUND="${item_found}"

            msg "[list] Appointment found (${index}, ${item_found})" "s"

            if [[ "${to_check}" ]]; then
                flag=$([[ "${item_found}" == "${to_check}" ]] && echo "s" || echo "f")
                msg "[list] Appointment match (${to_check}, ${item_found})" "${flag}"
            fi
        else
            msg "[list] Appointment not found (${index})" "f"
        fi
    fi
}

# --------------------------------------
# Test the action of taking an appointment
#
# @param string $1 Hour of the appointment (to take)
# @param string $2 ID of the pet that will attend
# --------------------------------------
function testTakeAppointment () {
    local appointment="${1}"
    local pet_id="${2}"
    local flag=''

    echo '========================================'
    msg 'Test to take appointment'

    elementCreate '/turno' '{"turno":"'$appointment'","mascota_id":"'$pet_id'"}'

    local remote_appointment=$(getValueFromJson "${CURL_RESPONSE_DATA}" 'turno')
    flag=$([[ "${remote_appointment}" == "${appointment}" ]] && echo "s" || echo "f")
    msg "[new] Appointment date and hour (${appointment}, ${remote_appointment})" "${flag}"

    local remote_pet_id=$(getValueFromJson "${CURL_RESPONSE_DATA}" 'mascota_id')
    flag=$([[ "${remote_pet_id}" == "${pet_id}" ]] && echo "s" || echo "f")
    msg "[new] Pet ID (${pet_id}, ${remote_pet_id})" "${flag}"
}

# --------------------------------------
# Test the list of taken appointments
#
# @param string $1 Expected amount of taken appointments (in the list)
# @param string $2 Hour of the appointment (used if given)
# @param string $3 ID of the pet to check (used if given)
# @param string $4 ID of the veterinary (used if given)
# --------------------------------------
function testListAppointment () {
    local amount="${1}"
    local appointment="${2}"
    local pet_id="${3}"
    local vet_id="${4}"
    local flag=''

    echo '========================================'
    msg 'Test the list of taken appointments'

    elementGet '/turno'

    local remote_amount=$(countItemsInJsonList "${CURL_RESPONSE_DATA}")
    flag=$( (($remote_amount == $amount)) && echo "s" || echo "f" )
    msg "[list] Amount of taken appointments (${amount}, ${remote_amount})" "${flag}"

    if [[ "${appointment}" ]]; then
        local json=$(searchByKeyValue "${CURL_RESPONSE_DATA}" 'turno' "${appointment}")

        if [[ "${json}" ]]; then
            msg "[list] Appointment found ('${appointment}')" "s"

            if [[ "${pet_id}" ]]; then
                local remote_pet_id=$(getValueFromJson "${json}" 'mascota_id')
                flag=$([[ "${remote_pet_id}" == "${pet_id}" ]] && echo "s" || echo "f")
                msg "[list] Appointment pet ID (${pet_id}, ${remote_pet_id})" "${flag}"
            fi

            if [[ "${vet_id}" ]]; then
                local remote_vet_id=$(getValueFromJson "${json}" 'veterinario_id')
                flag=$([[ "${remote_vet_id}" == "${vet_id}" ]] && echo "s" || echo "f")
                msg "[list] Appointment veterinary ID (${vet_id}, ${remote_vet_id})" "${flag}"
            fi
        else
            msg "[list] Appointment not found ('${appointment}')" "f"
        fi
    fi
}

# --------------------------------------
# Test the deletion of an appointments
#
# @param string $1 Hour of the appointment
# @param string $2 ID of the pet to check
# @param string $3 ID of the veterinary
# --------------------------------------
function testDeleteAppointment () {
    local appointment="${1}"
    local pet_id="${2}"
    local flag=''

    echo '========================================'
    msg 'Test appointment deletion'

    elementDelete "/turno/${appointment}/${pet_id}"

    local remote_appointment=$(getValueFromJson "${CURL_RESPONSE_DATA}" 'turno')
    flag=$([[ "${remote_appointment}" == "${appointment}" ]] && echo "s" || echo "f")
    msg "[delete] Appointment date and hour (${appointment}, ${remote_appointment})" "${flag}"

    local remote_pet_id=$(getValueFromJson "${CURL_RESPONSE_DATA}" 'mascota_id')
    flag=$([[ "${remote_pet_id}" == "${pet_id}" ]] && echo "s" || echo "f")
    msg "[delete] Pet ID (${pet_id}, ${remote_pet_id})" "${flag}"
}

# ====================================================================

# Remove and create DDBB
# ----------------------

rm -f database.sqlite
sqlite3 database.sqlite < esquema-ddbb.sql

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

# ====================================================================

# Pets battery of tests
# ---------------------

testListPets 0

PET_01_NAME="Firulaixxx"
PET_01_SPECIES="${SPECIES_CAT_ID}"
testCreatePet "${PET_01_NAME}" "${PET_01_SPECIES}"
PET_01_ID="${NEW_ID}"
testListPets 1 "${PET_01_ID}" "${PET_01_NAME}" "${PET_01_SPECIES}"
PET_01_NAME="Firulai"
PET_01_SPECIES="${SPECIES_DOG_ID}"
testEditPet "${PET_01_ID}" "${PET_01_NAME}" "${PET_01_SPECIES}"
testListPets 1 "${PET_01_ID}" "${PET_01_NAME}" "${PET_01_SPECIES}"

PET_02_NAME="Bartoloxxx"
PET_02_SPECIES="${SPECIES_DOG_ID}"
testCreatePet "${PET_02_NAME}" "${PET_02_SPECIES}"
PET_02_ID="${NEW_ID}"
testListPets 2 "${PET_02_ID}" "${PET_02_NAME}" "${PET_02_SPECIES}"
PET_02_NAME="Bartolo"
PET_02_SPECIES="${SPECIES_CAT_ID}"
testEditPet "${PET_02_ID}" "${PET_02_NAME}" "${PET_02_SPECIES}"
testListPets 2 "${PET_02_ID}" "${PET_02_NAME}" "${PET_02_SPECIES}"

PET_TMP_NAME="Puchoxxx"
PET_TMP_SPECIES="${SPECIES_CAT_ID}"
testCreatePet "${PET_TMP_NAME}" "${PET_TMP_SPECIES}"
PET_TMP_ID="${NEW_ID}"
testListPets 3 "${PET_TMP_ID}" "${PET_TMP_NAME}" "${PET_TMP_SPECIES}"
PET_TMP_NAME="Pucho"
PET_TMP_SPECIES="${SPECIES_DOG_ID}"
testEditPet "${PET_TMP_ID}" "${PET_TMP_NAME}" "${PET_TMP_SPECIES}"
testListPets 3 "${PET_TMP_ID}" "${PET_TMP_NAME}" "${PET_TMP_SPECIES}"

testDeletePet "${PET_TMP_ID}" "${PET_TMP_NAME}" "${PET_TMP_SPECIES}"
testListPets 2 "${PET_01_ID}" "${PET_01_NAME}" "${PET_01_SPECIES}"
testListPets 2 "${PET_02_ID}" "${PET_02_NAME}" "${PET_02_SPECIES}"

# ====================================================================

# Vets battery of tests
# ---------------------

testListVets 0

VETS_01_NAME='Pepito'
testCreateVets "${VETS_01_NAME}"
VETS_01_ID="${NEW_ID}"
testListVets 1 "${VETS_01_ID}" "${VETS_01_NAME}"
VETS_01_NAME='Pepo'
testEditVets "${VETS_01_ID}" "${VETS_01_NAME}"
testListVets 1 "${VETS_01_ID}" "${VETS_01_NAME}"

VETS_02_NAME='Pepita'
testCreateVets "${VETS_02_NAME}"
VETS_02_ID="${NEW_ID}"
testListVets 2 "${VETS_02_ID}" "${VETS_02_NAME}"
VETS_02_NAME='Pepon'
testEditVets "${VETS_02_ID}" "${VETS_02_NAME}"
testListVets 2 "${VETS_02_ID}" "${VETS_02_NAME}"

VETS_TEMP_NAME='Pepin'
testCreateVets "${VETS_TEMP_NAME}"
VETS_TEMP_ID="${NEW_ID}"
testListVets 3 "${VETS_TEMP_ID}" "${VETS_TEMP_NAME}"
VETS_TEMP_NAME='Pepecito'
testEditVets "${VETS_TEMP_ID}" "${VETS_TEMP_NAME}"
testListVets 3 "${VETS_TEMP_ID}" "${VETS_TEMP_NAME}"

testDeleteVets "${VETS_TEMP_ID}" "${VETS_TEMP_NAME}"
testListVets 2 "${VETS_01_ID}" "${VETS_01_NAME}"
testListVets 2 "${VETS_02_ID}" "${VETS_02_NAME}"

# ====================================================================

# Appointments battery of tests
# -----------------------------

APPOINTMENTS_PER_DAY=8
DAYS_WITH_APPOINTMENTS=2
AMOUNT_OF_APPOINTMENTS=$(( $APPOINTMENTS_PER_DAY * $DAYS_WITH_APPOINTMENTS ))

testAvailableAppointments $AMOUNT_OF_APPOINTMENTS 0
FIRST_HOUR_APPOINTMENT="${APPOINTMENT_FOUND}"
testAvailableAppointments $AMOUNT_OF_APPOINTMENTS 1
SECOND_HOUR_APPOINTMENT="${APPOINTMENT_FOUND}"
testAvailableAppointments $AMOUNT_OF_APPOINTMENTS 2
THIRD_HOUR_APPOINTMENT="${APPOINTMENT_FOUND}"

testListAppointment 0

testTakeAppointment $FIRST_HOUR_APPOINTMENT $PET_01_ID
testAvailableAppointments $AMOUNT_OF_APPOINTMENTS 0 $FIRST_HOUR_APPOINTMENT
testListAppointment 1 $FIRST_HOUR_APPOINTMENT $PET_01_ID $VETS_01_ID

testTakeAppointment $SECOND_HOUR_APPOINTMENT $PET_02_ID
testAvailableAppointments $AMOUNT_OF_APPOINTMENTS 1 $SECOND_HOUR_APPOINTMENT
testListAppointment 2 $SECOND_HOUR_APPOINTMENT $PET_02_ID $VETS_01_ID

testTakeAppointment $SECOND_HOUR_APPOINTMENT $PET_01_ID
AMOUNT_OF_APPOINTMENTS=$(( $AMOUNT_OF_APPOINTMENTS - 1 ))
testAvailableAppointments $AMOUNT_OF_APPOINTMENTS 0 $FIRST_HOUR_APPOINTMENT
testAvailableAppointments $AMOUNT_OF_APPOINTMENTS 1 $THIRD_HOUR_APPOINTMENT
testListAppointment 3

testTakeAppointment $FIRST_HOUR_APPOINTMENT $PET_02_ID
AMOUNT_OF_APPOINTMENTS=$(( $AMOUNT_OF_APPOINTMENTS - 1 ))
testAvailableAppointments $AMOUNT_OF_APPOINTMENTS 0 $THIRD_HOUR_APPOINTMENT
testListAppointment 4

testDeleteAppointment $FIRST_HOUR_APPOINTMENT $PET_02_ID
AMOUNT_OF_APPOINTMENTS=$(( $AMOUNT_OF_APPOINTMENTS + 1 ))
testAvailableAppointments $AMOUNT_OF_APPOINTMENTS 0 $FIRST_HOUR_APPOINTMENT
testAvailableAppointments $AMOUNT_OF_APPOINTMENTS 1 $THIRD_HOUR_APPOINTMENT
testListAppointment 3

testDeleteAppointment $SECOND_HOUR_APPOINTMENT $PET_01_ID
AMOUNT_OF_APPOINTMENTS=$(( $AMOUNT_OF_APPOINTMENTS + 1 ))
testAvailableAppointments $AMOUNT_OF_APPOINTMENTS 0 $FIRST_HOUR_APPOINTMENT
testAvailableAppointments $AMOUNT_OF_APPOINTMENTS 1 $SECOND_HOUR_APPOINTMENT
testAvailableAppointments $AMOUNT_OF_APPOINTMENTS 2 $THIRD_HOUR_APPOINTMENT
testListAppointment 2

# ====================================================================
