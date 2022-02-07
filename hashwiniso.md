# hashwiniso

Automatic extraction of SHA1 sets from a Microsoft Windows ISO image and the WIM files it contains.


## Prerequisites

With the exception of [wimlib](https://github.com/ebiggers/wimlib) which must be installed/present to process WIM files, all other binaries used by [hashwiniso](hashwiniso) should be in a Linux distribution.


## Installation

- download [hashwiniso](https://raw.githubusercontent.com/patatetom/rds4xways/master/hashwiniso) (in one of the folders defined in your `PATH` variable) 
- check it (with `(bat||less)</path/to/hashwiniso`)
- make it executable (with `chmod +x /path/to/hashwiniso`)
- try it :

```console
patateom@linux:~$ hashwiniso 
usage: hashwiniso mount_point
```

> [bat](https://github.com/sharkdp/bat) is cat clone with wings.  


## Usage

- mount the ISO image disk :

```console
patateom@linux:~$ udisksctl loop-setup -f /path/to/image.file.iso
patateom@linux:~$ # or
patateom@linux:~$ sudo mount /path/to/image.file.iso /mount/point/
```

- get informations :

```console
patateom@linux:~$ mount | grep /path/to/image.file.iso
/path/to/image.file.iso on /run/media/patatetom/IMAGE_LABEL type udf (ro,nosuid,nodev,relatime,uid=1000,gid=1000,iocharset=utf8,uhelper=udisks2)
```

- collect digital footprints :

```console
patateom@linux:~$ hashwiniso /run/media/patatetom/IMAGE_LABEL | tee image.file.iso.sha1sums
# hashing '/path/to/image.file.iso'...
da39a3ee5e6b4b0d3255bfef95601890afd80709  /path/to/image.file.iso
# hashing files in '/run/media/patatetom/IMAGE_LABEL'...
…
da39a3ee5e6b4b0d3255bfef95601890afd80709  /sources/boot.wim
…
da39a3ee5e6b4b0d3255bfef95601890afd80709  /sources/install.wim
…
# hashing files in '/sources/boot.wim'...
# 1/2 Microsoft Windows PE (x64)
…
# 2/2 Microsoft Windows Setup (x64)
…
# hashing files in '/sources/install.wim'...
# 1/11 Windows 10 Home
…
# 5/11 Windows 10 Education N
…
# 6/11 Windows 10 Pro
# 7/11 Windows 10 Pro N
# 8/11 Windows 10 Pro Education
# 9/11 Windows 10 Pro Education N
# 10/11 Windows 10 Pro for Workstations
# 11/11 Windows 10 Pro N for Workstations
# done
```

> `Pro` versions are not collected (see [hashwiniso source code](hashwiniso#L106) to change this behavior);
> 
> hash algorithm can be easily modified (see [hashwiniso source code](hashwiniso#L22) to change hash algorithm);
> 
> a warning will be displayed if the standard output of the script is not captured/redirected.

```console
patateom@linux:~$ grep -v '^#' image.file.iso.sha1sums | wc -l
501903
patateom@linux:~$ grep -v '^#' image.file.iso.sha1sums | sort -u | wc -l
106574
patateom@linux:~$  grep -v '^#' image.file.iso.sha1sums | cut -f 1 | sort -u | wc -l
69340
```
