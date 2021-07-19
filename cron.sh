#!/usr/bin/env bash


BASE_DIR=""
PHP=""
OWNER=""
CLEAR_STORAGE=0
CLEAR_CACHE=0
RUN_QUEUE=0

usage() {
    printf "Usage: $0 [OPTS] -d SITE_DIR\n" 1>&2
    printf "Options:\n" 1>&2
    printf "\t-d SITE_DIR\tpath to CMS base directory\n" 1>&2
    printf "\t-p PHP_BIN\tpath to PHP executable\n" 1>&2
    printf "\t-o OWNER\tuser:group for writeable cms directories\n" 1>&2
    printf "\t-s\t\tclear storage\n" 1>&2
    printf "\t-c\t\tclear cache\n" 1>&2
    printf "\t-q\t\trun the queue\n" 1>&2
}

exit_abnormal() {
    usage
    exit 1
}

print_opts() {
    echo "BASE_DIR: ${BASE_DIR}"
    # echo "PHP_VERSION: ${PHP_VERSION}"
    echo "PHP: ${PHP}"
    ${PHP} -v
    echo "Clear Storage|Cache: ${CLEAR_STORAGE}|${CLEAR_CACHE}"
    echo "Owner: $OWNER"
}

while getopts ":d:p:o:hsqc" options; do
    case "${options}" in
        d)
            BASE_DIR=${OPTARG}
            ;;
        p)
            PHP=${OPTARG}
            ;;
        o)
            OWNER=${OPTARG}
            ;;
        h)
            usage
            exit 0
            ;;
        s)
            CLEAR_STORAGE=1
            ;;
        c)
            CLEAR_CACHE=1
            ;;
        q)
            RUN_QUEUE=1
            ;;
        :)
            echo "Error: -${OPTARG} requires an argument"
            exit_abnormal
            ;;
    esac
done

current_time=$(date +"%Y-%m-%d %H:%M:%S")
printf "\n============= Starting cleanup.sh [%s] =============\n" "$current_time"

if [ -z $BASE_DIR ]; then
    echo "Error: -d flag is required" >2
    exit_abnormal
fi

if [ -z $PHP ]; then
    PHP=$(which php)
fi

set -eux;

# Set permissions
if [ ! -z $OWNER ]; then
    sudo chown -R "${OWNER}" "${BASE_DIR}"
    sudo chmod a+w -R "${BASE_DIR}/storage"
fi

# Clear storage
if [ $CLEAR_STORAGE -eq 1 ]; then
    cd "${BASE_DIR}"
    sudo rm -rf storage/runtime/* || true
    mkdir -p storage/runtime
    sudo chmod -R 775 storage/runtime
    sudo rm -rf storage/logs/*.[0-9]* || true
fi

# Clear caches
if [ $CLEAR_CACHE -eq 1 ]; then
    cd "${BASE_DIR}"
    $PHP craft clear-caches/all
fi

# Run the queue
if [ $RUN_QUEUE -eq 1 ]; then
    echo "Running queue"
    cd "${BASE_DIR}"; $PHP craft queue/run &
fi

printf "\n============= Complete =============\n"
