# RDSv3 format

```
The new RDSv3 format will include a number of major changes, which include
publication as an SQLite3 database, the inclusion of SHA-256 hashes for
published files, and incremental releases, along with other changes.
```

```
The RDSv3 publication also includes a more modern set of hashes, with the
publication of SHA-256 file hashes, and the removal of CRC-32 file hashes.
```

```
With the RDSv3 publication, it will also be possible for users to construct an
RDSv2 like publication from data included in the RDSv3 format. Data in the four
core NSRL files in RDSv2, NSRLFile.txt, NSRLMfg.txt, NSRLOS.txt, and
NSRLProd.txt, will be stored in a set of four VIEWS in the RDSv3 SQLite
publication, known as FILE, MFG, OS, and PKG.
```

```
It is planned that the NSRL will be publishing complete
and full RDSv3 publications in the first quarter of each year (March), and publish delta RDSv3
publications that build on the full publication in all four quarters (March, June, September, December).
The delta RDSv3 publications will be a set of SQL INSERT, UPDATE, and DELETE statements contained in
a single SQL file, that can be run in the previous full RDSv3 SQLite database publication. The NSRL will
provide instructions for constructing the most up to date full RDSv3 publication from a past release and
the latest delta set publication.
```


## Download

[RDS_2022.03.1_modern.zip](https://s3.amazonaws.com/rds.nsrl.nist.gov/RDS/rds_2022.03.1/RDS_2022.03.1_modern.zip)

**WARNING : compressed file `RDS_2022.03.1_modern.zip` size is 63Gb !**


## Schema

[sqleton](https://github.com/inukshuk/sqleton)

```bash
# example with archlinux as root
pacman -Sy
pacman -S gcc graphviz make npm
npm install -g sqleton
sqleton -f 'source code pro medium' -o RDS_yyyy.mm.r.schema.png RDS_yyyy.mm.r.db
```


## Extract all SHA1

```bash
sqlite3 RDS_YYYY.MM.R.db "
	SELECT 'SHA-1';
	SELECT DISTINCT sha1
	FROM metadata
	ORDER BY sha1;
" | tee sha1 | wc
```


## Extract images SHA1

```bash
sqlite3 RDS_YYYY.MM.R.db "
	SELECT 'SHA-1';
	SELECT DISTINCT sha1
	FROM metadata
	WHERE extension IN ('jpg', 'jpeg', 'jfif', 'jif', 'jp2', 'jpx', 'j2k', 'j2c', 'png', 'gif', 'bmp', 'svg', 'tif', 'tiff', 'psd', 'pcx', 'webp', 'psd', 'emf', 'wmf')
	ORDER BY sha1;
" | tee images.sha1 | wc
```

