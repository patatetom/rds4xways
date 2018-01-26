# rds4xways

Extract SHA1 from [Reference Data Set](https://www.nist.gov/itl/ssd/software-quality-group/nsrl-download/current-rds-hash-sets) (RDS) provided by the [National Software Reference Library](https://www.nist.gov/software-quality-group/national-software-reference-library-nsrl) (NSRL) for X-Ways Forensics.


## Prerequisites

- relatively recent Linux distribution
- few Gb of memory
- 1x Gb of disk space
- `unzip` to extract `NSRLFile.txt.zip` to pipe
- `wc` to do some counts
- `python2` to convert files format and preserve some space
- `pv` (optional)


Uncompaction of the archive `NSRLFile.txt.zip` would require 13.7 Gb (14740940496/1024^3) of disk space for 112 182 782 records :
```bash
unzip -p /media/NSRLFile.txt.zip | pv | wc
13,7GiO 0:07:19 [  32MiB/s] [       <=>                               ]
112182782 116433441 14740940496
```
