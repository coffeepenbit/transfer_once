function transfer_once {
    source_dir="$1"
    destination_dir="$2"

    echo "Running transfer_once"
    echo "source_dir: \"$source_dir\""
    echo "destination_dir: \"$destination_dir\""

    lock_filepath="$HOME/.transfer_once.lock"
    echo "lock_filepath \"$lock_filepath\""

    transferred_filepath="./transferred"
    touch $transferred_filepath

    flock --nonblock $lock_filepath                 \
        rsync                                       \
            "$source_dir/"                          \
            "$destination_dir/"                     \
            --itemize-changes                       \
            --archive                               \
            --compress                              \
            --human-readable                        \
            --out-format="%n"                       \
            --exclude-from="$transferred_filepath"  \
            >> "$transferred_filepath"
                  
    echo "transfer_once done"
}