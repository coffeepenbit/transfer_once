FILENAMES=(
    "single_file"
    "whitespace file"
    ".hidden file"
)


teardown() {
    rm -rf nonexistant_dest nonexistant_source rsync_dest rsync_source transferred
}


@test "No input" {
    run ./transfer_once.sh

    [ "$status" -eq 1 ]
}


@test "Non-existant source" {
    mkdir rsync_dest

    run ./transfer_once.sh nonexistant_source rsync_dest

    echo -e "status:\n${status}\n"
    echo -e "output:\n${output}\n"
    [ -d rsync_dest ] 
    [ "$status" -eq 23 ]
}


@test "Non-existant dest" {
    source_dir="rsync_source"
    destination_dir="nonexistant_dest"    
    mkdir rsync_source

    run ./transfer_once.sh "$source_dir" "$destination_dir"

    echo -e "status:\n${status}\n"
    echo -e "output:\n${output}\n"
    [ "$status" -eq 0 ]
    [ -d "$destination_dir" ] 
}


@test "Non-existant source and destination" {
    run ./transfer_once.sh nonexistant_source nonexistant_dest

    echo -e "status:\n${status}\n"
    echo -e "output:\n${output}\n"0
    [ -d nonexistant_dest ] 
    [ "$status" -eq 23 ]
}


@test "Empty source and dest" {
    mkdir rsync_source rsync_dest

    run ./transfer_once.sh rsync_source rsync_dest

    echo -e "status:\n${status}\n"
    echo -e "output:\n${output}\n"
    [ "$status" -eq 0 ]
    [ -d rsync_dest ]
}


@test "Single file transfer" {
    for i in "${FILENAMES[@]}"; do
        echo "single file name: "$i""
        teardown
        mkdir rsync_source rsync_dest
        touch rsync_source/"$i"

        run ./transfer_once.sh rsync_source rsync_dest

        echo -e "status:\n${status}\n"
        echo -e "output:\n${output}\n"
        [ -d rsync_dest ]
        [ -f rsync_dest/"$i" ]
        [ "$status" -eq 0 ]
    done
}


@test "Single file transfer once" {
    for i in "${FILENAMES[@]}"; do
        echo "single file name: "$i""
        teardown
        mkdir rsync_source rsync_dest
        touch rsync_source/"$i"
        [ ! -f rsync_dest/"$i" ]
        [ ! -f ./transferred ]
        echo "$i" > transferred

        run ./transfer_once.sh rsync_source rsync_dest

        echo -e "status:\n${status}\n"
        echo -e "output:\n${output}\n"
        [ "$status" -eq 0 ]
        [ -d rsync_dest ]
        [ ! -f rsync_dest/"$i" ]
    done
}


@test "Multi-file transfer" {
    mkdir rsync_source rsync_dest
    for i in "${FILENAMES[@]}"; do
        echo "filename: "$i""
        ls rsync_dest
        touch rsync_source/"$i"
    done

    run ./transfer_once.sh rsync_source rsync_dest  

    echo -e "status:\n${status}\n"
    echo -e "output:\n${output}\n"
    [ "$status" -eq 0 ]
    [ -d rsync_dest ]

    for i in "${FILENAMES[@]}"; do
        echo "filename: "$i""
        ls rsync_dest
        [ -f rsync_dest/"$i" ]
    done
}


@test "Multi-file transfer once" {
    mkdir rsync_source rsync_dest
    for i in "${FILENAMES[@]}"; do
        echo "filename: "$i""
        ls rsync_dest
        touch rsync_source/"$i"
        echo "$i" >> transferred
    done

    run ./transfer_once.sh rsync_source rsync_dest  

    echo -e "status:\n${status}\n"
    echo -e "output:\n${output}\n"
    [ "$status" -eq 0 ]
    [ -d rsync_dest ]
    for i in "${FILENAMES[@]}"; do
        echo "filename: "$i""
        ls rsync_dest
        [ ! -f rsync_dest/"$i" ]
    done
}


@test "Multi-file subdirectory" {
    mkdir rsync_source rsync_dest
    mkdir rsync_source/subdirectory
    for i in "${FILENAMES[@]}"; do
        echo "filename: "$i""
        ls rsync_dest
        touch rsync_source/"$i"
        touch rsync_source/subdirectory/"$i"
    done

    run ./transfer_once.sh rsync_source rsync_dest  

    echo -e "status:\n${status}\n"
    echo -e "output:\n${output}\n"
    [ "$status" -eq 0 ]
    [ -d rsync_dest ]
    for i in "${FILENAMES[@]}"; do
        echo "filename: "$i""
        ls rsync_dest
        [ -f rsync_dest/"$i" ]
        [ -f rsync_dest/subdirectory/"$i" ]
    done
}


@test "Multi-file subdirectory transfer once" {
    mkdir rsync_source rsync_dest
    mkdir rsync_source/subdirectory
    for i in "${FILENAMES[@]}"; do
        echo "filename: "$i""
        ls rsync_dest
        touch rsync_source/"$i"
        echo "$i" >> transferred
        touch rsync_source/subdirectory/"$i"
        echo "subdirectory/$i" >> transferred
    done

    run ./transfer_once.sh rsync_source rsync_dest  

    echo -e "status:\n${status}\n"
    echo -e "output:\n${output}\n"
    [ "$status" -eq 0 ]
    [ -d rsync_dest ]
    for i in "${FILENAMES[@]}"; do
        echo "filename: "$i""
        ls rsync_dest
        ls rsync_dest/subdirectory
        [ ! -f rsync_dest/"$i" ]
        [ ! -d rsync_dest/subdirectory ]
    done
}