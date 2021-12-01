# rds4xways

Extraction of SHA1 sets from [Reference Data Set](https://www.nist.gov/itl/ssd/software-quality-group/national-software-reference-library-nsrl/about-nsrl) (RDS) provided by the [National Software Reference Library](https://www.nist.gov/itl/ssd/software-quality-group/national-software-reference-library-nsrl) (NSRL) for X-Ways Forensics _(or any other tool that uses SHA1)_.


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

The full modern RDS Version 2.74 of september 2021 is [downloaded](https://www.nist.gov/itl/ssd/software-quality-group/national-software-reference-library-nsrl/nsrl-download/current-rds) (3,4 Gb) and used.

The content of the iso image `RDS_modern.iso` is made accessible through `/media/` :

```bash
mount -o ro ./RDS_modern.iso /media/
```



## Disk space

Uncompaction of the archive `NSRLFile.txt.zip` would require 25 Gb of disk space for 192 677 750 records :

```bash
unzip -p /media/NSRLFile.txt.zip | pv | wc
25,0GiO 0:02:18 [ 184MiO/s] [     <=>                               ]
192677750 194541093 26804404409
```

> `wc` results can be formated with `| printf "%'d - %'d - %'d" $( cat )` : `192 677 750 - 194 541 093 - 26 804 404 409`

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
25,0GiO 0:13:55 [30,6MiO/s] [        <=>                            ]
182753918 365507836 8938968303
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
38320335 38320335 1571133700
```

**According to X-Ways documentation** : *Now, important top tip follows: If you are creating your own hash file to import, perhaps from another forensic tool, and if you are using SHA-1, be sure to make sure your column heading in your source file is written exactly as "SHA-1" and not "SHA1" or "SHA" or "SHA 1".* ***It has to be "SHA-1", exactly, to be understood.***

```bash
head -3 sha1
SHA-1
0000001ffef4be312bab534eca7aeaa3e4684d85
00000052a9eeec6c8348cfb2aea77bc1fbf8d239
```

The file `sha1` weighs 1,5 Gb for 38 320 335 records.



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
3264 27202 179692
```
```bash
cat microsoft.product
62	the compaq personal computer startup diskette	608
62	the compaq personal computer startup diskette	608
…
214741	skype for desktop	608
214741	skype for desktop	608
```

Extract SHA1 :

```bash
( echo SHA-1; fgrep -f <( cut -f 1 microsoft.product | sed -e 's/^/\t/g' -e 's/$/x/g' | sort -u ) nsrl | cut -f 1 | sort -u ) | tee microsoft.sha1 | wc
7402919 7402919 303519644
```

The file `microsoft.sha1` weighs 290 Mb for 7 402 918 records (~25%).



## Extract «Windows» SHA1

Extract operating systems :

```bash
./csv2tsv < /media/NSRLOS.txt | cut -f 1,2,4 | grep -f <( cut -f 1 microsoft | sed -e 's/^/\t/g' -e 's/$/$/g' ) | tee microsoft.os | wc
445 2777 14722
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
18982 109498 700111
```
```bash
cat windows.product
62	the compaq personal computer startup diskette	56
62	the compaq personal computer startup diskette	56
…
215906	creator nxt 7 - esd	772
215933	zoom client for windows	189
```

Extract SHA1 :

```bash
( echo SHA-1; fgrep -f <( cut -f 1 windows.product | sed -e 's/^/\t/g' -e 's/$/x/g' | sort -u ) nsrl | cut -f 1 | sort -u ) | tee windows.sha1 | wc
16402601 16402601 672506606
```

The file `windows.sha1` weighs 642 Mb for 16 402 600 records (~55%).



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
