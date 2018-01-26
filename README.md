# rds4xways

Extract SHA1 from [Reference Data Set](https://www.nist.gov/itl/ssd/software-quality-group/nsrl-download/current-rds-hash-sets) (RDS) provided by the [National Software Reference Library](https://www.nist.gov/software-quality-group/national-software-reference-library-nsrl) (NSRL) for X-Ways Forensics.


## Prerequisites

- `unzip` to extract `NSRLFile.txt.zip` to pipe
- `wc` to do some counts
- `python2` to convert files format and preserve some space
- `pv` (optional)


Decompact the archive `NSRLFile.txt.zip` would require 13.7Gb of disk space for 112 182 782 records :
```bash
unzip -p /media/NSRLFile.txt.zip | pv | wc
13,7GiO 0:07:19 [  32MiB/s] [       <=>                               ]
112182782 116433441 14740940496
```
