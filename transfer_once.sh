set -e

nexpected_args=2

if [ ! $# -eq $nexpected_args ]
    then
        echo "Number of arguments provided: $#"
        echo "Number of arguments expected: $nexpected_args"
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

flock --nonblock $lock_filepath                 \
    rsync                                       \
        "$source_dir/"                          \
        "$destination_dir/"                     \
        --prune-empty-dirs                      \
        --itemize-changes                       \
        --archive                               \
        --compress                              \
        --human-readable                        \
        --out-format="%n"                       \
        --exclude-from="$transferred_filepath"  \
        >> "$transferred_filepath"              

grep -v "^\.\/$" $transferred_filepath          \
    > "$transferred_filepath"_intermediate      \
&& mv "$transferred_filepath"_intermediate      \
      "$transferred_filepath"

echo "$0 done"