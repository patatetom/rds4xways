# rds4xways

Extract SHA1 from [Reference Data Set](https://www.nist.gov/itl/ssd/software-quality-group/nsrl-download/current-rds-hash-sets) (RDS) provided by the [National Software Reference Library](https://www.nist.gov/software-quality-group/national-software-reference-library-nsrl) (NSRL) for X-Ways Forensics.


## Prerequisites

- relatively recent Linux distribution
- few Gb of memory
- 1x Gb of disk space
- `unzip` to extract `NSRLFile.txt.zip` to pipe
- `python2` to convert files format and preserve some space
- `sed` to delete the headers
- `cut` to cut fields
- `tee` (optional) to duplicate the data stream
- `pv` (optional) to monitor the progress of work
- `wc` (optional) to do some counts

Except `pv` and `unzip`, all the above mentioned tools should be present in a Linux distribution.


## Download and mount

The full modern RDS Version 2.59 of December 2017 is [downloaded](https://www.nist.gov/itl/ssd/software-quality-group/nsrl-download/current-rds-hash-sets) and used.

The content of the iso image `RDS_modern.iso` is made accessible through `/media/` :

```bash
mount -o ro ./RDS_modern.iso /media/
```


## Disk space

Uncompaction of the archive `NSRLFile.txt.zip` would require 13.7 Gb of disk space for 112 182 782 records :

```bash
unzip -p /media/NSRLFile.txt.zip | pv | wc
13,7GiO 0:07:19 [  32MiB/s] [       <=>                               ]
112182782 116433441 14740940496
```

Extraction of strictly necessary data with reformatting will save some precious gigabytes.

The formatting is carried out by the Python script `csv2tsv` which removes all double quots and separates the fields by a tabulation, which will make it easier to process them, especially with `cut`.


## Extract data

The file `NSRLFile.txt` is structured as follows :

```bash
unzip -p /media/NSRLFile.txt.zip | head -3
"SHA-1","MD5","CRC32","FileName","FileSize","ProductCode","OpSystemCode","SpecialCode"
"0000002D9D62AEBE1E0E9DB6C4C4C7C16A163D2C","1D6EBB5A789ABD108FF578263E1F40F3","FFFFFFFF","_sfx_0024._p",4109,11063,"358",""
"0000004DA6391F7F5D2F7FCCF36CEBDA60C6EA02","0E53C14A3E48D94FF596A2824307B492","AA6A7B16","00br2026.gif",2226,8280,"358",""
```

Only fields `SHA-1` and `ProductCode` are extracted from it :

```bash
unzip -p /media/NSRLFile.txt.zip | sed 1d | ./csv2tsv | cut -f 1,6 | sort -u | tee nsrl | wc -l
```
