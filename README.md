# rds4xways

Extraction of SHA1 sets from [Reference Data Set](https://www.nist.gov/itl/ssd/software-quality-group/nsrl-download/current-rds-hash-sets) (RDS) provided by the [National Software Reference Library](https://www.nist.gov/software-quality-group/national-software-reference-library-nsrl) (NSRL) for X-Ways Forensics.


## Prerequisites

- relatively recent Linux distribution
- a few Gb of memory
- at least 12 Gb of free disk space
- `bash` to bind tools
- `unzip` to extract to stdout
- `python2` to convert files format and preserve some space
- `sed` to add/delete headers and more
- `fgrep` to match fixed strings
- `cut` to cut fields
- `tee` (optional) to duplicate the data stream
- `pv` (optional) to monitor the progress of work
- `wc` (optional) to do some counts

Except `pv` and `unzip`, all the above mentioned tools should be present in a Linux distribution.



## Download and mount

The full modern RDS Version 2.59 of December 2017 is [downloaded](https://www.nist.gov/itl/ssd/software-quality-group/nsrl-download/current-rds-hash-sets) (3,1 Gb) and used.

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
unzip -p /media/NSRLFile.txt.zip | pv | sed 1d | ./csv2tsv | cut -f 1,6 | sort -u | tee nsrl | wc
13,7GiO 0:29:56 [  7MiB/s] [          <=>                            ]
104339754  208679508 4857127280
# unzip -p /media/NSRLFile.txt.zip | sed 1d | ./csv2tsv | cut -f 1,6 | sort -u > nsrl
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
# ( echo SHA-1; cut -f 1 nsrl | sort -u ) > sha1
```

**According to X-Ways documentation** : *Now, important top tip follows: If you are creating your own hash file to import, perhaps from another forensic tool, and if you are using SHA-1, be sure to make sure your column heading in your source file is written exactly as "SHA-1" and not "SHA1" or "SHA" or "SHA 1". It has to be "SHA-1", exactly, to be understood.*

```bash
head -3 sha1
SHA-1
0000002d9d62aebe1e0e9db6c4c4c7c16a163d2c
0000004da6391f7f5d2f7fccf36cebda60c6ea02
```

The file `sha1` weighs 1,6 Gb and contains 39 599 835 records.



## Extract images SHA1

***This only way of doing so, based on the extension of the file name, will import SHA1 that are not necessarily those of images and leave out SHA1 of images that will not have been imported because there is no extension to the file name.***

Extensions used for the main image formats are searched :

```bash
re='\.(jpg|jpeg|png|gif|bmp|svg|tif|psd|pcx)$'
unzip -p /media/NSRLFile.txt.zip | pv | ./csv2tsv | cut -f 1,4 | egrep $re | cut -f 1 | sort -u | tee image | wc
13,7GiO 0:37:49 [6,19MiB/s] [             <=>                         ]
5265462 5265462 215883942
# unzip -p /media/NSRLFile.txt.zip | ./csv2tsv | cut -f 1,4 | egrep $re | cut -f 1 | sort -u > image
```
```bash
sed -i '1i SHA-1' image
```

The file `image` weighs 206 Mb and contains 5 265 462 records (13%).



## Extract Microsoft SHA1

Extract manufacturer :

```bash
./csv2tsv < /media/NSRLMfg.txt | grep microsoft | tee microsoft | wc
3 9 68
# ./csv2tsv < /media/NSRLMfg.txt | grep microsoft > microsoft
```
```bash
cat microsoft
3912	microsoft corporation
609	microsoft
610	microsoft game studios
```

Extract products :

```bash
./csv2tsv < /media/NSRLProd.txt | cut -f 1,2,5 | fgrep -f <( cut -f 1 microsoft | sed 's/^/\t/g' ) | tee microsoft.product | wc
4020 26362 163827
# ./csv2tsv < /media/NSRLProd.txt | cut -f 1,2,5 | fgrep -f <( cut -f 1 microsoft | sed 's/^/\t/g' ) > microsoft.product
```
```bash
cat microsoft.product
62	the compaq personal computer startup diskette	609
62	the compaq personal computer startup diskette	609
...
184355	microsoft windows xp professional	609
184355	microsoft windows xp professional	609
```

Extract SHA1 :

```bash
( echo SHA-1; fgrep -f <( cut -f 1 microsoft.product | sed 's/^/\t/g' ) nsrl | cut -f 1 | sort -u ) | tee microsoft.sha1 | wc
17553387 17553387 719688832
# ( echo SHA-1; fgrep -f <( cut -f 1 microsoft.product | sed 's/^/\t/g' ) nsrl | cut -f 1 | sort -u ) > microsoft.sha1
```

The file `microsoft.sha1` weighs 687 Mb and contains 17 553 386 records (44%).



## Extract «Windows» SHA1

Extract operating systems :

```bash
./csv2tsv < /media/NSRLOS.txt | cut -f 1,2,4 | fgrep -f <( cut -f 1 microsoft | sed 's/^/\t/g' ) | tee microsoft.os | wc
392 2403 12664
# ./csv2tsv < /media/NSRLOS.txt | cut -f 1,2,4 | fgrep -f <( cut -f 1 microsoft | sed 's/^/\t/g' ) > microsoft.os
```
```bash
cat microsoft.os
109	novel dos 7.0	609
115	pcdos 5.0	609
...
934	windows 8 enterprise	609
947	windows 10 ltsb	609
```

Extract products :

```bash
./csv2tsv < /media/NSRLProd.txt | cut -f 1,2,4 | fgrep -f <( cut -f 1 microsoft.os | sed 's/^/\t/g' ) | tee windows.product | wc
  27804  162979 1001782
# ./csv2tsv < /media/NSRLProd.txt | cut -f 1,2,4 | fgrep -f <( cut -f 1 microsoft.os | sed 's/^/\t/g' ) > windows.product
```
```bash
cat windows.product
9	pcanywhere	190
9	pcanywhere	200
...
184362	matlab & simulink	237
184363	oracle9i database release 2	189
```

Extract SHA1 :

```bash
( echo SHA-1; fgrep -f <( cut -f 1 windows.product | sed 's/^/\t/g' ) nsrl | cut -f 1 | sort -u ) | tee windows.sha1 | wc
35337414 35337414 1448833939
# ( echo SHA-1; fgrep -f <( cut -f 1 windows.product | sed 's/^/\t/g' ) nsrl | cut -f 1 | sort -u ) > windows.sha1
```

The file `windows.sha1` weighs 1,4 Gb and contains 35 337 413 records (89%).
