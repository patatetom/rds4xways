# hashwiniso

Automatic extraction of SHA1 sets from a Microsoft Windows ISO image and the WIM files it contains.


## Prerequisites

With the exception of [wimlib](https://github.com/ebiggers/wimlib) which must be installed/present to process WIM files, all other binaries used by [hashwiniso](hashwiniso) should be in your Linux.


## Installation

- download [hashwiniso](https://raw.githubusercontent.com/patatetom/rds4xways/master/hashwiniso) (in one of the folders defined in your `PATH` variable) 
- check it (with `(bat||less)</path/to/hashwiniso`)
- make it executable (with `chmod +x /path/to/hashwiniso`)
- try it :

```console
$ hashwiniso 
usage: hashwiniso mount_point
```
