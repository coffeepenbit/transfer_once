#!/bin/bash

# Transfer Once
# Version 0.1.0

set -e

NEXPECTED_ARGS=2
TRANSFERRED_FILEPATH="./transferred"


function clean_up_transferred_list {
    echo "Cleaning up transferred file list"
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
    echo "Removing directories from list"
    filepath="$1"

    grep -v "\/$" "$filepath"                               \
        > "$filepath"_intermediate                          \
    || [ $? -eq 1 ] # Prevent error if no match found

    mv "${filepath}_intermediate" "$filepath"               
}


function remove_duplicates_from_list {
    echo "Removing duplicates from list"
    filepath="$1"

    sort -u "$filepath"                                     \
        > "$filepath"_intermediate                          

    mv "${filepath}_intermediate" "$filepath"               
}


if [ ! $# -eq $NEXPECTED_ARGS ]
    then
        echo "Number of arguments provided: $#"
        echo "Number of arguments expected: $NEXPECTED_ARGS"
        exit 1
fi

source_dir="$1"
destination_dir="$2"

echo "Running transfer_once"
echo "source_dir: \"$source_dir\""
echo "destination_dir: \"$destination_dir\""

lock_filepath="$HOME/.transfer_once.lock"
touch $TRANSFERRED_FILEPATH

flock --nonblock $lock_filepath                             \
    rsync                                                   \
        "$source_dir/"                                      \
        "$destination_dir/"                                 \
        --prune-empty-dirs                                  \
        --itemize-changes                                   \
        --archive                                           \
        --compress                                          \
        --human-readable                                    \
        --out-format="%n"                                   \
        --exclude-from="$TRANSFERRED_FILEPATH"              \
        | tee -a "$TRANSFERRED_FILEPATH"

rsync_exit_status=${PIPESTATUS[0]}
if [ "$rsync_exit_status" -ne "0" ]; then
    echo "rsync exited with $rsync_exit_status"
    exit $rsync_exit_status
fi

clean_up_transferred_list "$TRANSFERRED_FILEPATH"

echo "$0 done"