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
    mkdir rsync_source rsync_dest
    touch rsync_source/single_file.txt

    run ./transfer_once.sh rsync_source rsync_dest

    echo -e "status:\n${status}\n"
    echo -e "output:\n${output}\n"
    [ -d rsync_dest ]
    [ -f rsync_dest/single_file.txt ]
    [ "$status" -eq 0 ]
}


@test "Single file transfer once" {
    mkdir rsync_source rsync_dest
    touch rsync_source/single_file.txt
    [ ! -f rsync_dest/single_file.txt ]
    [ ! -f ./transferred ]
    echo "single_file.txt" > transferred

    run ./transfer_once.sh rsync_source/ rsync_dest/

    echo -e "status:\n${status}\n"
    echo -e "output:\n${output}\n"
    [ -d rsync_dest ]
    [ ! -f rsync_dest/single_file.txt ]
    [ "$status" -eq 0 ]
}