# Transfer once
Transfer files only once using rsync

The purpose is to allow for moving/deleting files at the destination, without worrying about files being copied over additional times. By default, rsync will retransfer these moved/deleted files.

## Running
To run:
`./transfer_once.sh <source_directory> <destination_directory>`

## Running tests
To run unit tests, run:
`bats ./tests.sh`
