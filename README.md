# rds4xways

Extraction of SHA1 sets from [Reference Data Set](https://www.nist.gov/itl/ssd/software-quality-group/national-software-reference-library-nsrl/about-nsrl) (RDS) provided by the [National Software Reference Library](https://www.nist.gov/itl/ssd/software-quality-group/national-software-reference-library-nsrl) (NSRL) for X-Ways Forensics.


## Prerequisites

- relatively recent Linux distribution
- a few Gb of memory
- at least 12 Gb of free disk space
- `bash` to bind tools
- `unzip` to extract to stdout
- `python2` to convert files format and preserve some space
- `sed` to add/delete headers and more
- `egrep`, `fgrep` and `grep` to match strings
- `cut` to cut fields
- `tee` to duplicate the data stream
- `pv` to monitor the progress of work
- `wc` to do some counts

Except `pv`, `tee` and `unzip`, all the above mentioned tools should be present in a Linux distribution.
If the use and thus the installation of `pv` and `tee` is optional, the installation of `unzip` is required.



## Download and mount

The full modern RDS Version 2.69 of June 2020 is [downloaded](https://www.nist.gov/itl/ssd/software-quality-group/national-software-reference-library-nsrl/nsrl-download/current-rds) (2,5 Gb) and used.

The content of the iso image `RDS_modern.iso` is made accessible through `/media/` :

```bash
mount -o ro ./RDS_modern.iso /media/
```



## Disk space

Uncompaction of the archive `NSRLFile.txt.zip` would require 22,9 Gb of disk space for 183 887 293 records :

```bash
unzip -p /media/NSRLFile.txt.zip | pv | wc
15GiO 0:05:47 [31,8MiB/s] [       <=>                               ]
114812390 116049259 16071653636
```

> `wc` results can be formated with `awk '{printf '${_:="\"%'d\""}',$1; printf " - "; printf '$_',$2; printf " - "; printf '$_',$3;}'` : `114 812 390 - 116 049 259 - 16 071 653 636`

Extraction of strictly necessary data with reformatting will save some precious gigabytes.

The formatting is carried out by the Python script `csv2tsv` which removes all double quots and separates the fields by a tabulation, which will make it easier to process them, especially with `cut`.



## Extract data

The file `NSRLFile.txt` is structured as follows :

```bash
unzip -p /media/NSRLFile.txt.zip | head -3
"SHA-1","MD5","CRC32","FileName","FileSize","ProductCode","OpSystemCode","SpecialCode"
"00000079FD7AAC9B2F9C988C50750E1F50B27EB5","8ED4B4ED952526D89899E723F3488DE4","7A5407CA","wow64_microsoft-windows-i..timezones.resources_31bf3856ad364e35_10.0.16299.579_de-de_f24979c73226184d.manifest",2520,190718,"362",""
"00000079FD7AAC9B2F9C988C50750E1F50B27EB5","8ED4B4ED952526D89899E723F3488DE4","7A5407CA","wow64_microsoft-windows-i..timezones.resources_31bf3856ad364e35_10.0.16299.579_de-de_f24979c73226184d.manifest",2520,190719,"362",""
```

Only fields `SHA-1` and `ProductCode` are extracted from it :

```bash
unzip -p /media/NSRLFile.txt.zip | pv | sed 1d | ./csv2tsv | cut -f 1,6 | sed 's/$/x/g' | sort -u | tee nsrl | wc
15GiO 0:33:41 [6,23MiB/s] [          <=>                            ]
108170733 216341466 5285694740
```
```bash
head -3 nsrl
00000079fd7aac9b2f9c988c50750e1f50b27eb5	190718x
00000079fd7aac9b2f9c988c50750e1f50b27eb5	190719x
00000079fd7aac9b2f9c988c50750e1f50b27eb5	190721x
```

> the final character `x` is introduced for the later use of `fgrep`.



## Extract all SHA1

```bash
( echo SHA-1; cut -f 1 nsrl | sort -u ) | tee sha1 | wc
29459433 29459433 1207836718
```

**According to X-Ways documentation** : *Now, important top tip follows: If you are creating your own hash file to import, perhaps from another forensic tool, and if you are using SHA-1, be sure to make sure your column heading in your source file is written exactly as "SHA-1" and not "SHA1" or "SHA" or "SHA 1".* ***It has to be "SHA-1", exactly, to be understood.***

```bash
head -3 sha1
SHA-1
00000079fd7aac9b2f9c988c50750e1f50b27eb5
000000f694ca9bf73836d67deb5e2724338b422d
```

The file `sha1` weighs 1,2 Gb for 29 459 432 records.



## Extract images SHA1

***This only way of doing so, based on the extension of the file name, will import SHA1 that are not necessarily those of images and leave out SHA1 of images that will not have been imported because there is no extension to the file name.***

Extensions used for the main image formats are searched :

```bash
re='\.(jpg|jpeg|png|gif|bmp|svg|tif|psd|pcx|webp)$'
unzip -p /media/NSRLFile.txt.zip | pv | ./csv2tsv | cut -f 1,4 | egrep $re | cut -f 1 | sort -u | tee image.sha1 | wc
15GiO 0:16:47 [6,25MiB/s] [             <=>                         ]
1335405 1335405 54751605
```
```bash
sed -i '1i SHA-1' image.sha1
```

The file `image.sha1` weighs 53 Mb for 1 335 405 records (~4%).



## Extract Microsoft SHA1

Extract manufacturer :

```bash
# ./csv2tsv < /media/NSRLMfg.txt | grep microsoft > microsoft
./csv2tsv < /media/NSRLMfg.txt | grep microsoft | tee microsoft | wc
3 9 68
```
```bash
cat microsoft
5804	microsoft corporation
608	microsoft
609	microsoft game studios
```

Extract products :

```bash
# ./csv2tsv < /media/NSRLProd.txt | cut -f 1,2,5 | grep -f <( cut -f 1 microsoft | sed -e 's/^/\t/g' -e 's/$/$/g' ) > microsoft.product
./csv2tsv < /media/NSRLProd.txt | cut -f 1,2,5 | grep -f <( cut -f 1 microsoft | sed -e 's/^/\t/g' -e 's/$/$/g' ) | tee microsoft.product | wc
5603 40406 257223
```
```bash
cat microsoft.product
62	the compaq personal computer startup diskette	608
62	the compaq personal computer startup diskette	608
…
203345	2018-04 security only quality update for windows server 2012 r2 for x64 (kb4093115)	608
203346	delta update for windows 10 for x86 (kb4093107)	608
```

Extract SHA1 :

```bash
# ( echo SHA-1; fgrep -f <( cut -f 1 microsoft.product | sed -e 's/^/\t/g' -e 's/$/x/g' | sort -u ) nsrl | cut -f 1 | sort -u ) > microsoft.sha1
( echo SHA-1; fgrep -f <( cut -f 1 microsoft.product | sed -e 's/^/\t/g' -e 's/$/x/g' | sort -u ) nsrl | cut -f 1 | sort -u ) | tee microsoft.sha1 | wc
10994536 10994536 450775941
```

The file `microsoft.sha1` weighs 430 Mb for 10 994 535 records (~19%).



## Extract «Windows» SHA1

Extract operating systems :

```bash
# ./csv2tsv < /media/NSRLOS.txt | cut -f 1,2,4 | grep -f <( cut -f 1 microsoft | sed -e 's/^/\t/g' -e 's/$/$/g' ) > microsoft.os
./csv2tsv < /media/NSRLOS.txt | cut -f 1,2,4 | grep -f <( cut -f 1 microsoft | sed -e 's/^/\t/g' -e 's/$/$/g' ) | tee microsoft.os | wc
437 2713 14379
```
```bash
cat microsoft.os
1000	windows nt 3	608
1001	windows 8 sp1 x64	608
…
994	windows 2003 sp2 x32	608
995	windows 2003 sp2 x64	608
```

Extract products :

```bash
# ./csv2tsv < /media/NSRLProd.txt | cut -f 1,2,4 | grep -f <( cut -f 1 microsoft.os | sed -e 's/^/\t/g' -e 's/$/$/g' ) > windows.product
./csv2tsv < /media/NSRLProd.txt | cut -f 1,2,4 | grep -f <( cut -f 1 microsoft.os | sed -e 's/^/\t/g' -e 's/$/$/g' ) | tee windows.product | wc
34958 207759 1295619
```
```bash
cat windows.product
9	pcanywhere	190
9	pcanywhere	200
…
204254	ue_4.22	189
204255	jade empire	189
```

Extract SHA1 :

```bash
# ( echo SHA-1; fgrep -f <( cut -f 1 windows.product | sed -e 's/^/\t/g' -e 's/$/x/g' | sort -u ) nsrl | cut -f 1 | sort -u ) > windows.sha1
( echo SHA-1; fgrep -f <( cut -f 1 windows.product | sed -e 's/^/\t/g' -e 's/$/x/g' | sort -u ) nsrl | cut -f 1 | sort -u ) | tee windows.sha1 | wc
34615489 34615489 1419235014
```

The file `windows.sha1` weighs 1,4 Gb for 34 615 488 records (~61%).



## More SHA1 sets

With the same constraints as for images, the variable `re` can be modified to extract file names with the `.exe` extension :

```bash
# re='\.(com|sys|dll|exe)$'
re='\.exe$'
unzip -p /media/NSRLFile.txt.zip | ./csv2tsv | cut -f 1,4 | egrep $re | cut -f 1 | sort -u > executable.sha1
sed -i '1i SHA-1' executable.sha1
```

Images can be reduced to Microsoft or Windows with the use of `comm` :

```bash
comm -1 -2 microsoft.sha1 image.sha1 > image.microsoft.sha1
comm -1 -2 windows.sha1 image.sha1 > image.windows.sha1
```



## See also

- [Testing the National Software Reference Library](https://www.sciencedirect.com/science/article/pii/S1742287612000345)
