# rds4xways

Extraction of SHA1 sets from [Reference Data Set](https://www.nist.gov/itl/ssd/software-quality-group/national-software-reference-library-nsrl/about-nsrl) (RDS) provided by the [National Software Reference Library](https://www.nist.gov/itl/ssd/software-quality-group/national-software-reference-library-nsrl) (NSRL) for X-Ways Forensics _(or any other tool that uses SHA1)_.


## Prerequisites

- relatively recent Linux distribution
- a few Gb of memory
- at least 12 Gb of free disk space
- `bash` to bind tools
- `unzip` to extract to stdout
- `python` to convert files format and preserve some space
- `sed` to add/delete headers and more
- `egrep`, `fgrep` and `grep` to match strings
- `cut` to cut fields
- `tee` to duplicate data stream
- `pv` to monitor progress of work
- `wc` to do some counts

Except `pv`, `tee` and `unzip`, all the above mentioned tools should be present in a Linux distribution.
If the use and thus the installation of `pv` and `tee` is optional, the installation of `unzip` is required.



## Download and mount

The full modern RDS Version 2.77 of june 2022 is [downloaded](https://www.nist.gov/itl/ssd/software-quality-group/national-software-reference-library-nsrl/nsrl-download/current-rds) (4,2 Gb) and used.

The content of the iso image `RDS_modern.iso` is made accessible through `/media/` :

```bash
mount -o ro ./RDS_modern.iso /media/
```



## Disk space

Uncompaction of the archive `NSRLFile.txt.zip` would require 30 Gb of disk space for 222 113 225 records :

```bash
unzip -p /media/NSRLFile.txt.zip | pv | wc
28,6GiO 0:11:44 [41,6MiB/s] [    <=>                                           ]
222113225 223814314 30736964414
```

> `wc` results can be formated with this `bash` function `bignumbers(){ printf "%'d - " $( cat ) | sed 's/ - $//'; }` : `unzip -p /media/NSRLFile.txt.zip | pv | wc | bignumbers` will produce `222 113 225 - 223 814 314 - 30 736 964 414`

Extraction of strictly necessary data with reformatting will save some precious gigabytes.

The formatting is carried out by the Python script `csv2tsv` which removes all double quots and separates the fields by a tabulation, which will make it easier to process them, especially with `cut`.



## Extract data

The file `NSRLFile.txt` is structured as follows :

```bash
unzip -p /media/NSRLFile.txt.zip | head -3
"SHA-1","MD5","CRC32","FileName","FileSize","ProductCode","OpSystemCode","SpecialCode"
"0000001FFEF4BE312BAB534ECA7AEAA3E4684D85","344428FA4BA313712E4CA9B16D089AC4","7516A25F",".text._ZNSt14overflow_errorC1ERKSs",33,219181,"362",""
"00000052A9EEEC6C8348CFB2AEA77BC1FBF8D239","F46CA74CA3D89E9D3CF8D8E5CD77842D","2F9CC135","__DATA__mod_init_func",772,218747,"362",""
```

Only fields `SHA-1` and `ProductCode` are extracted from it :

```bash
unzip -p /media/NSRLFile.txt.zip | pv | sed 1d | ./csv2tsv | cut -f 1,6 | sed 's/$/x/g' | sort -u | tee nsrl | wc
28,6GiO 0:24:18 [20,1MiB/s] [          <=>                          ]
210502817 421005634 10299328069
```

> the `sort -u` command used above can quickly run out of space when the `/tmp/` folder is mounted in memory : use its `-T /somedir/` option or the `$TMPDIR` environment variable in this case.

```bash
head -3 nsrl
0000001ffef4be312bab534eca7aeaa3e4684d85	219181x
00000052a9eeec6c8348cfb2aea77bc1fbf8d239	218747x
00000079fd7aac9b2f9c988c50750e1f50b27eb5	190718x
```

> the final character `x` is introduced for the later use of `fgrep`.



## Extract all SHA1

```bash
( echo SHA-1; cut -f 1 nsrl | sort -u ) | tee sha1 | wc
46688293 46688293 1914219978
```

**According to X-Ways documentation** : *Now, important top tip follows : If you are creating your own hash file to import, perhaps from another forensic tool, and if you are using SHA-1, be sure to make sure your column heading in your source file is written exactly as "SHA-1" and not "SHA1" or "SHA" or "SHA 1".* ***It has to be "SHA-1", exactly, to be understood.***

```bash
head -3 sha1
SHA-1
0000001ffef4be312bab534eca7aeaa3e4684d85
00000052a9eeec6c8348cfb2aea77bc1fbf8d239
```

The file `sha1` weighs 1,8 Gb for 46 688 292 records.



## Extract images SHA1

***This only way of doing so, based on the extension of the file name, will import SHA1 that are not necessarily those of images and leave out SHA1 of images that will not have been imported because there is no extension to the file name.***

Extensions used for the main image formats are searched :

```bash
re='\.(jpg|jpeg|jfif|jif|jp2|jpx|j2k|j2c|png|gif|bmp|svg|tif|tiff|psd|pcx|webp|psd|emf|wmf)$'
unzip -p /media/NSRLFile.txt.zip | pv | ./csv2tsv | cut -f 1,4 | egrep $re | cut -f 1 | sort -u | tee image.sha1 | wc
25,0GiO 0:13:06 [32,5MiO/s] [           <=>                         ]
1826385 1826385 74881785
```
```bash
sed -i '1i SHA-1' image.sha1
```

The file `image.sha1` weighs 72 Mb for 1 826 385 records (~4%).



## Extract Microsoft SHA1

Extract manufacturer :

```bash
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
./csv2tsv < /media/NSRLProd.txt | cut -f 1,2,5 | grep -f <( cut -f 1 microsoft | sed -e 's/^/\t/g' -e 's/$/$/g' ) | tee microsoft.product | wc
7399 61640 402337
```
```bash
cat microsoft.product
62	the compaq personal computer startup diskette	608
62	the compaq personal computer startup diskette	608
…
281008	windows 11 consumer editions april 2022	608
281009	windows 11 business editions april 2022	608
```

Extract SHA1 :

```bash
( echo SHA-1; fgrep -f <( cut -f 1 microsoft.product | sed -e 's/^/\t/g' -e 's/$/x/g' | sort -u ) nsrl | cut -f 1 | sort -u ) | tee microsoft.sha1 | wc
10991183 10991183 450638468
```

The file `microsoft.sha1` weighs 430 Mb for 10 991 182 records (~23%).



## Extract «Windows» SHA1

Extract operating systems :

```bash
./csv2tsv < /media/NSRLOS.txt | cut -f 1,2,4 | grep -f <( cut -f 1 microsoft | sed -e 's/^/\t/g' -e 's/$/$/g' ) | tee microsoft.os | wc
483 3014 16063
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
./csv2tsv < /media/NSRLProd.txt | cut -f 1,2,4 | grep -f <( cut -f 1 microsoft.os | sed -e 's/^/\t/g' -e 's/$/$/g' ) | tee windows.product | wc
34043 204661 1325704
```
```bash
cat windows.product
62	the compaq personal computer startup diskette	56
62	the compaq personal computer startup diskette	56
…
281074	fuck putin	189
281220	vampire: the masquerade - bloodhunt	189
```

Extract SHA1 :

```bash
( echo SHA-1; fgrep -f <( cut -f 1 windows.product | sed -e 's/^/\t/g' -e 's/$/x/g' | sort -u ) nsrl | cut -f 1 | sort -u ) | tee windows.sha1 | wc
25029548 25029548 1026211433
```

The file `windows.sha1` weighs 979 Mb for 25 029 547 records (~54%).



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
- [hashwiniso](hashwiniso.md)
