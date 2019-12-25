. ./transfer_once.sh --source-only

@test "Non-existant source" {
    mkdir rsync_dest

    run transfer_once nonexistant_source rsync_dest
    echo -e "status:\n${status}\n"
    echo -e "output:\n${output}\n"
    [ -d rsync_dest ] 
    [ "$status" -eq 23 ]
}


@test "Non-existant dest" {
    mkdir rsync_source

    run transfer_once rsync_source nonexistant_dest

    echo -e "status:\n${status}\n"
    echo -e "output:\n${output}\n"
    [ -d nonexistant_dest ] 
    [ "$status" -eq 0 ]
}


@test "Non-existant source and destination" {
    run transfer_once nonexistant_source nonexistant_dest

    echo -e "status:\n${status}\n"
    echo -e "output:\n${output}\n"0
    [ -d nonexistant_dest ] 
    [ "$status" -eq 23 ]
}


@test "Empty source and dest" {
    mkdir rsync_source rsync_dest

    run transfer_once rsync_source rsync_dest

    echo -e "status:\n${status}\n"
    echo -e "output:\n${output}\n"
    [ -d rsync_dest ] 
    [ "$status" -eq 0 ]
}
teardown() {
    rm -rf nonexistant_dest nonexistant_source rsync_dest rsync_source
}

