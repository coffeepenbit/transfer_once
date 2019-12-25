# Transfer once
Transfers files only one time using rsync.

The purpose is to allow for moving/deleting files at the destination, without worrying about files being copied over additional times. By default, rsync will retransfer these moved/deleted files.
