#!/bin/bash

# Export locally all kibana dashboards

# -E Set error traps to be inherited by function
# -e Exits immediatly if a command exits with non-zero
# -u Treat unset variables as an error when substituting(null is a valid value)
# -o pipefail The return value of a pipeline is the status of the last command to exit with a non-zero status
set -Eeuo pipefail

## Helpers

function log { echo "[`date`] [$1] $2"; }
function logInfo { log INFO "$1"; }
function logWarn { log WARN "$1"; }
function logError { log ERROR "$1"; }

## Arguments parsing & validation

while [[ $# -gt 0 ]]; do
    case $1 in
        -o|--output)
            OUTPUT="$2"
            shift
            shift
            ;;
        -c|--cookie)
            COOKIE="$2"
            shift
            shift
            ;;
        -u|--url)
            KIBANA_URL="$2"
            shift
            shift
            ;;
        -*|--*)
            logError "Unknown option $1"
            exit 1
            ;;
    esac
done

if [ -z "${COOKIE+x}" ];
then
    logError "-c/--cookie must be set"
    exit 1
fi

if [ -z "${OUTPUT+x}" ];
then
    logError "-o/--output must be set"
    exit 1
fi

if [ -d "${OUTPUT}" ]; then
    logError "${OUTPUT} already exists, exiting"
    exit 1
fi

if [ -z "${KIBANA_URL+x}" ];
then
    logError "-u/--url must be set"
    exit 1
fi

## Functions

function removeTrailingSlash {
    param=$1

    echo ${param} | sed "s/\/$//g"
}

## Main

SANITIZED_KIBANA_URL=$(removeTrailingSlash ${KIBANA_URL})
KIBANA_API=${SANITIZED_KIBANA_URL}/_dashboards/api

logInfo "Creating backup in ${OUTPUT}"

mkdir -p ${OUTPUT}

dashboards=$(curl -s -X GET "${KIBANA_API}/opensearch-dashboards/management/saved_objects/_find?perPage=50&page=1&fields=id&type=dashboard" -H "Cookie: ${COOKIE}" | jq '.saved_objects[] | {id, title: .meta.title}' | jq -s '.')

echo ${dashboards} | jq -c '.[]' | while read line; do
    id=$(echo $line | jq -rc '.id')
    title=$(echo $line | jq -rc '.title')

    logInfo "Processing ${title}..."

    curl -X POST ${KIBANA_API}/saved_objects/_export \
        -s \
        -H "Cookie: ${COOKIE}" \
        -H "Content-Type: application/json" \
        -H 'osd-xsrf: true' \
        -d "{\"objects\":[{\"id\":\"${id}\",\"type\":\"dashboard\"}],\"includeReferencesDeep\":true}" \
        > "${OUTPUT}/${title}.ndjson"
done

exit 0
