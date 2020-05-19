FILENAMES=(
    "underscore_filename"
    "whitespace filename"
    ".hidden filename"
    "[ bracket ] filename"
    "* asterisk"
    "** double asterisk filename"
    "? question filename"
)


function teardown {
    rm -rf nonexistant_dest nonexistant_source rsync_dest rsync_source        \
           transferred other_transferred
}


function reset_dest {
    rm -r rsync_dest
    mkdir rsync_dest
}


@test "No input" {
    run ./transfer_once.sh -v

    [ "$status" -eq 1 ]
}


@test "Non-existant source" {
    mkdir rsync_dest

    run ./transfer_once.sh -v nonexistant_source rsync_dest

    echo -e "status:\n${status}\n"
    echo -e "output:\n${output}\n"
    [ -d rsync_dest ] 
    [ "$status" -eq 23 ]
}


@test "Non-existant dest" {
    source_dir="rsync_source"
    destination_dir="nonexistant_dest"    
    mkdir rsync_source

    run ./transfer_once.sh -v "$source_dir" "$destination_dir"

    echo -e "status:\n${status}\n"
    echo -e "output:\n${output}\n"
    [ "$status" -eq 0 ]
    [ -d "$destination_dir" ] 
}


@test "Non-existant source and destination" {
    run ./transfer_once.sh -v nonexistant_source nonexistant_dest

    echo -e "status:\n${status}\n"
    echo -e "output:\n${output}\n"0
    [ -d nonexistant_dest ] 
    [ "$status" -eq 23 ]
}


@test "Empty source and dest" {
    mkdir rsync_source rsync_dest

    run ./transfer_once.sh -v rsync_source rsync_dest

    echo -e "status:\n${status}\n"
    echo -e "output:\n${output}\n"
    [ "$status" -eq 0 ]
    [ -d rsync_dest ]
}


@test "Single file transfer" {
    for i in "${FILENAMES[@]}"; do
        echo "filename being tested: "$i""
        teardown
        mkdir rsync_source rsync_dest
        touch rsync_source/"$i"

        run ./transfer_once.sh -v rsync_source rsync_dest

        echo -e "status:\n${status}\n"
        echo -e "output:\n${output}\n"
        [ -d rsync_dest ]
        [ -f rsync_dest/"$i" ]
        [ "$status" -eq 0 ]
    done
}


@test "Single file transfer once" {
    for i in "${FILENAMES[@]}"; do
        echo "filename being tested: "$i""
        teardown
        mkdir rsync_source rsync_dest
        touch rsync_source/"$i"
        [ ! -f ./transferred ]

        run ./transfer_once.sh -v rsync_source rsync_dest
        reset_dest
        run ./transfer_once.sh -v rsync_source rsync_dest

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
        touch rsync_source/"$i"
    done

    run ./transfer_once.sh -v rsync_source rsync_dest  

    echo -e "status:\n${status}\n"
    echo -e "output:\n${output}\n"
    [ "$status" -eq 0 ]
    [ -d rsync_dest ]

    for i in "${FILENAMES[@]}"; do
        echo "filename: "$i""
        [ -f rsync_dest/"$i" ]
    done
}


@test "Multi-file transfer once" {
    mkdir rsync_source rsync_dest
    for i in "${FILENAMES[@]}"; do
        echo "filename: "$i""
        touch rsync_source/"$i"
        # echo "$i" >> transferred
    done

    run ./transfer_once.sh -v rsync_source rsync_dest
    reset_dest
    run ./transfer_once.sh -v rsync_source rsync_dest

    echo -e "status:\n${status}\n"
    echo -e "output:\n${output}\n"
    [ "$status" -eq 0 ]
    [ -d rsync_dest ]
    for i in "${FILENAMES[@]}"; do
        echo "filename: "$i""
        [ ! -f rsync_dest/"$i" ]
    done
}


@test "Multi-file subdirectory" {
    mkdir rsync_source rsync_dest
    mkdir rsync_source/subdirectory
    for i in "${FILENAMES[@]}"; do
        echo "filename: "$i""
        touch rsync_source/"$i"
        touch rsync_source/subdirectory/"$i"
    done

    run ./transfer_once.sh -v rsync_source rsync_dest  

    echo -e "status:\n${status}\n"
    echo -e "output:\n${output}\n"
    [ "$status" -eq 0 ]
    [ -d rsync_dest ]
    for i in "${FILENAMES[@]}"; do
        echo "filename: "$i""
        [ -f rsync_dest/"$i" ]
        [ -f rsync_dest/subdirectory/"$i" ]
    done
}


@test "Multi-file subdirectory transfer once" {
    mkdir rsync_source rsync_dest
    mkdir rsync_source/subdirectory
    for i in "${FILENAMES[@]}"; do
        echo "filename: "$i""
        touch rsync_source/"$i"
        touch rsync_source/subdirectory/"$i"
    done

    run ./transfer_once.sh -v rsync_source rsync_dest
    reset_dest
    run ./transfer_once.sh -v rsync_source rsync_dest 

    echo -e "status:\n${status}\n"
    echo -e "output:\n${output}\n"
    [ "$status" -eq 0 ]
    [ -d rsync_dest ]
    for i in "${FILENAMES[@]}"; do
        echo "filename: "$i""
        [ ! -f rsync_dest/"$i" ]
        [ ! -d rsync_dest/subdirectory ]
    done
}


@test "New files after transfer" {
    mkdir rsync_source rsync_dest
    mkdir rsync_source/subdirectory
    for i in "${FILENAMES[@]}"; do
        echo "filename: "$i""
        touch rsync_source/"$i"
        touch rsync_source/subdirectory/"$i"
    done

    run ./transfer_once.sh -v rsync_source rsync_dest  

    touch rsync_source/"additional file"
    touch rsync_source/subdirectory/"additional file"

    run ./transfer_once.sh -v rsync_source rsync_dest  

    echo -e "status:\n${status}\n"
    echo -e "output:\n${output}\n"
    [ "$status" -eq 0 ]
    [ -d rsync_dest ]

    for i in "${FILENAMES[@]}"; do
        echo "filename: "$i""
        [ -f rsync_dest/"$i" ]
        [ -f rsync_dest/subdirectory/"$i" ]
    done
    [ -f rsync_dest/"additional file" ]
    [ -f rsync_dest/subdirectory/"additional file" ]
}


@test "Specified transferred file location" {
    mkdir rsync_source rsync_dest
    for i in "${FILENAMES[@]}"; do
        echo "filename: "$i""
        touch rsync_source/"$i"
    done

    run ./transfer_once.sh -v -t other_transferred rsync_source rsync_dest  

    echo -e "status:\n${status}\n"
    echo -e "output:\n${output}\n"
    [ "$status" -eq 0 ]
    [ -d rsync_dest ]

    for i in "${FILENAMES[@]}"; do
        echo "filename: "$i""
        [ -f rsync_dest/"$i" ]
    done
    [ -f other_transferred ]
    [ ! -f transferred ]
}