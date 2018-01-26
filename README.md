# rds4xways

Extract SHA1 from [Reference Data Set](https://www.nist.gov/itl/ssd/software-quality-group/nsrl-download/current-rds-hash-sets) (RDS) provided by the [National Software Reference Library](https://www.nist.gov/software-quality-group/national-software-reference-library-nsrl) (NSRL) for X-Ways Forensics.


## Prerequisites

- relatively recent Linux distribution
- few Gb of memory
- 1x Gb of disk space
- `unzip` to extract `NSRLFile.txt.zip` to pipe
- `python2` to convert files format and preserve some space
- `cut` to cut fields
- `pv` (optional) to monitor the progress of work
- `wc` (optional) to do some counts


## Disk space

Uncompaction of the archive `NSRLFile.txt.zip` would require 13.7 Gb of disk space for 112 182 782 records :
```bash
unzip -p /media/NSRLFile.txt.zip | pv | wc
13,7GiO 0:07:19 [  32MiB/s] [       <=>                               ]
112182782 116433441 14740940496
```
Extraction of strictly necessary data with reformatting should save some precious gigabytes.

The formatting is carried out by the Python script `csv2tsv` which removes all double quots and separates the fields by a tabulation, which will make it easier to process them, especially with `cut`.
