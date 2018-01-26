# rds4xways

Extraction of SHA1 sets from [Reference Data Set](https://www.nist.gov/itl/ssd/software-quality-group/nsrl-download/current-rds-hash-sets) (RDS) provided by the [National Software Reference Library](https://www.nist.gov/software-quality-group/national-software-reference-library-nsrl) (NSRL) for X-Ways Forensics.


## Prerequisites

- relatively recent Linux distribution
- few Gb of memory
- 1x Gb of disk space
- `unzip` to extract `NSRLFile.txt.zip` to pipe
- `python2` to convert files format and preserve some space
- `sed` to delete headers and more
- `fgrep` to match fixed strings
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
unzip -p /media/NSRLFile.txt.zip | sed 1d | ./csv2tsv | cut -f 1,6 | sort -u | tee nsrl | wc
104339754  208679508 4857127280
```
```bash
head -3 nsrl 
0000002d9d62aebe1e0e9db6c4c4c7c16a163d2c	11063
0000004da6391f7f5d2f7fccf36cebda60c6ea02	8280
00000142988afa836117b1b572fae4713f200567	10463
```


## Extract all SHA1

```bash
( echo SHA-1; cut -f 1 nsrl | sort -u ) | tee sha1 | wc
39599836 39599836 1623593241
```

**According to X-Ways documentation** : *Now, important top tip follows: If you are creating your own hash file to import, perhaps from another forensic tool, and if you are using SHA-1, be sure to make sure your column heading in your source file is written exactly as "SHA-1" and not "SHA1" or "SHA" or "SHA 1". It has to be "SHA-1", exactly, to be understood.*

```bash
head -3 sha1
SHA-1
0000002d9d62aebe1e0e9db6c4c4c7c16a163d2c
0000004da6391f7f5d2f7fccf36cebda60c6ea02
```

The file `sha1` weighs 1,6 Gb contains 39 599 836 records.
