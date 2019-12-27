set -e

NEXPECTED_ARGS=2


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

    mv "$transferred_filepath"_intermediate                 \
      "$transferred_filepath"
}


function remove_duplicates_from_list {
    echo "Removing duplicates from list"
    filepath="$1"

    sort -u "$filepath"                                     \
        > "$filepath"_intermediate                          

    mv "$transferred_filepath"_intermediate                 \
      "$transferred_filepath"
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
echo "lock_filepath \"$lock_filepath\""

transferred_filepath="./transferred"
touch $transferred_filepath

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
        --exclude-from="$transferred_filepath"              \
        | tee -a "$transferred_filepath"

rsync_exit_status=${PIPESTATUS[0]}
if [ "$rsync_exit_status" -ne "0" ]; then
    echo "rsync exited with $rsync_exit_status"
    exit $rsync_exit_status
fi

clean_up_transferred_list "$transferred_filepath"

echo "$0 done"