#!/bin/bash

# Transfer Once
# Version: 0.2.0

set -e

NEXPECTED_ARGS=2
SED_ESCAPES=(
    '-e s/\[/\\[/g' # Escape left brackets
    '-e s/\*/\\*/g' # Escape asterisks
    '-e s/\?/\\?/g' # Escape question marks
)
TRANSFERRED_FILEPATH="./transferred"
USAGE="$(basename "$0") [-h] [-v] <source> <destination>

    -h  display this help and exit
    -v  verbose
    -t  specify transferred file

Transfer files, only once, even if the destination changes."


function clean_up_transferred_list {
    if [ "$verbose" = true ]; then
        echo "Cleaning up transferred file list"
    fi
    transferred_filepath="$1"

    if [ -f "$transferred_filepath" ]; then
        remove_directories_from_list "$1"
        remove_duplicates_from_list "$1"
    else
        echo "Transferred file path doesn't exist"
        exit 1
    fi 
}


function remove_directories_from_list {
    if [ "$verbose" = true ]; then
        echo "Removing directories from list"
    fi    
    filepath="$1"

    grep -v "\/$" "$filepath"                               \
        > "$filepath"_intermediate                          \
    || [ $? -eq 1 ] # Prevent error if no match found

    mv "${filepath}_intermediate" "$filepath"               
}


function remove_duplicates_from_list {
    if [ "$verbose" = true ]; then
        echo "Removing duplicates from list"
    fi        
    filepath="$1"

    sort -u "$filepath"                                     \
        > "$filepath"_intermediate                          

    mv "${filepath}_intermediate" "$filepath"               
}


verbose=false
while getopts 't:vh' OPTION; do
    case "$OPTION" in
        h) 
            echo "$USAGE"
            exit 0
            ;;
        t)
            TRANSFERRED_FILEPATH="$OPTARG"
            ;;
        v)
            verbose=true
            ;;
        ?) 
            echo "$USAGE"
            exit 1
            ;;
    esac
done
shift "$(($OPTIND -1))"
    

if [ ! $# -eq $NEXPECTED_ARGS ]; then
    echo "Expect $NEXPECTED_ARGS args, received $# args"
    echo "$USAGE"
    exit 1
fi


source_dir="$1"
destination_dir="$2"


echo "Running transfer_once"
if [ "$verbose" = true ]; then
    echo "source_dir: \"$source_dir\""
    echo "destination_dir: \"$destination_dir\""
    echo "transferred_filepath: \"$TRANSFERRED_FILEPATH\""
    echo "\n"
fi


lock_filepath="$HOME/.transfer_once.lock"
touch "$TRANSFERRED_FILEPATH"


echo "Running rsync"
flock --nonblock $lock_filepath                             \
    rsync                                                   \
        --prune-empty-dirs                                  \
        --itemize-changes                                   \
        --archive                                           \
        --compress                                          \
        --human-readable                                    \
        --out-format="%n"                                   \
        --exclude-from="$TRANSFERRED_FILEPATH"              \
        --                                                  \
        "$source_dir/"                                      \
        "$destination_dir/"                                 \
        | sed "${SED_ESCAPES[@]}"                           \
        | tee -a "$TRANSFERRED_FILEPATH"


rsync_exit_status=${PIPESTATUS[0]}
if [ "$rsync_exit_status" -ne "0" ]; then
    echo "rsync exited with $rsync_exit_status"
    exit $rsync_exit_status
fi


clean_up_transferred_list "$TRANSFERRED_FILEPATH"


if [ "$verbose" = true ]; then
    echo "$0 done"
fi
