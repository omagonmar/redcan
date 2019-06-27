*** Last Change 16JUN94

Fix typos in parameter file for SQSKY.  The user can select the type of
statistic to apply to the data (norm_stat) and whether to offset or scale the
data to a common statistic ("norm_opt") prior to imcombine.

Handle case where do transformation file present for TRANSMAT

### Last change 23APR94

Separated "nircombine" into nircombine, which supports only current (>= 2.10.2)
imcombine and "onircombine" which supports only older (<= 2.20.1) imcombine.

NIRCOMBINE work

Modify stack database; submit intensity offsets to imcombine rather than perform
imarith prior tro submission.

Fix bug in recovering intensity offsets from imcombine log:
   When less than 10 images are combined, the format is
      imname[n] median adjust xoff yoff
   However when 10 or more images are combined, the  format is:
      imname[ n] median adjust xoff yoff ;  n < 10
      imname[nn] median adjust xoff yoff ;  n >= 10
   Since the field count varies for ten or more images, the assumption that
   field 3 contained the "adjust" value fails on images 1-9 (median is extracted
   instead).

Replace fscan with scan from a pipe to get database parameters.

Add apply_zero flag to allow choice of:
   (1) applying zero-point shifts via imarith prior to imcombine,
       so that zeropoint adjusted results will be saved via
       make_stack+ or save_images+.
   (2) submitting intensity offsets file directly to imcombine,
       so that zeropoint unadjusted results will be saved via
       make_stack+ or save_images+.

Note: IRAF V2.10EXPORT April 1992 imcombine has an inconsistency in the sign
convention on applied zeropoint.  The sign of the file based zeropoint assumes
the value to be subtracted, whereas the reported number is the value to be
added.  These have been reconciled to "value to be added" in the next release
and current IRAFX  zero_invert flag toggles these situations.

Tested results against original code.  Results are indistinguishable.  However,
note that recorded log from IMCOMBINE can lose precision due to formatting.
(This will be fixed inside next release IRAF imcombine.)

Fix so frame_nums = ""," ","all" work to correctly signify "use all COM lines".

### Last change 07APR94

Major "bug" fix:

  Replaced internal writes to file which used "type" with "concatenate" or
     "copy" as appropriate.  Within the core SQIID database routines, lines
     longer than a given length (e.g. 80 characters) were being wrapped to
     80 characters with the rest of the line appearing as a new line in
     an enviromentally sensitive way: 
        stty gterm worked OK
        stty xterm or stty xgterm exhibited the "wrap" behavior
     The above modification fixes this bug in the following routines:
       closure, getcenters, ircombine, linklaps, mergecom, nircombine, sqmos,
       transmat, xyadopt, xyget, xylap, xytrace, zget
     Apparently "type" is context sensitive to the tty even when writing to
     files.

Some changes/additions:

  The tasks getcombine.cl, compose.cl, getmatch.cl, getoffsets.cl, which have
     not been kept current, have been dropped from the current distribution.

  Sub-directory "prior" contains earlier versions of tasks:
     1) which were changed in the current release.
     2) which were frozen as compatible with earlier IRAF releases,
        such as the *.cl0 tasks mentioned below.

### Last change 23MAR94

Some changes/additions:

 `chlist' and `colorlist' have been updated to allow the new WILDFIRE
     naming convention for IRIM/CRSP/COB (id_color = "seq"), which does not
     append a channel designator (j|h|k|l) to the end of the image_name.
    (The old FIRE convention is id_color = "predot" for SQIID.)
    (The current WFIRE convention is id_color = "end" for SQIID.)
    (The current WFIRE convention is id_color = "seq" for IRIM|COB|CRSP.)
 `sqmos' has been modified to allow wildcarded images like `sqproc', `sqky',
    `sqdark', and `sqflat' already allow.  Thus:
         sqmos pn1_001_*j.imh mosj 3 3 
     will put the 9 files pn1_001_001j thru pn1_001_009j into the mosaic "mosj".

### Last change 05OCT93

NB: IRAF2.10.2 contains a change to the IMCOMBINE task which requires
    changes to all tasks which use imcombine.
    The versions which work with 2.10.0 and 2.10.1 are labeled *.cl0
    and the ones which work with 2.10.2 and later are labeled *.cl.
    To use the *.cl0 files, delete (or rename) the .cl versions and rename
    the *.cl0 files *.cl.

A preliminary discussion on how to use the "sqiid" package, by K. Michael
Merrill and John Mackenty is in "DOC/sqiidpkg.doc".  There are no help pages
yet.  The latest copy of the SQIID observation manual is in "DOC/sqiid.aug92".

Some changes/additions:

  `chlist' and `colorlist' have been updated to allow the new WILDFIRE naming
     convention (id_color = "end"), which appends the SQIID channel designator
     (j|h|k|l) to the end of the image_name.  (The old FIRE convention is
     id_color = "predot")
  `nircombine' -- incorporates "frame_num" list to combine a designated subset
      of the data list and incorpates `imstack' as a means of getting around
      the 102 frame limit for "imcombine".
  `sqproc' -- the general list-process data task has undergone minor revisions
     and some new data processing tasks have been generated:
     `sqnotch' uses a subset of a datalist within a specified distance of
        each frame (the "notch") to generate a running SKY frame which is
        subtracted from that frame.
     `sqtriad' - list-process SQIID raw image data of the form ON OFF ON ...
                 ON  OFF
           list#  1  2
           list#  3  2
           list#  4  5
           list#  6  5
           list#  7  8
           list#  9  8
     `sq9pair' - list-process SQIID raw image data of the form ON OFF OFF ON ...
                 ON  OFF
           list#  1  2
           list#  4  3
           list#  5  6
           list#  8  7
           list#  9 10
           list# 12 11
           list# 13 14
           list# 16 15
           list# 17 18
  `show1' -- display and optionally sky subtract an image
  `show4' -- display and optionally sky subtract all 4 channels of an image
  `show9' -- display and optionally sky subtract a 3x3 grid of image data
  `show9pair' -- display sky subtracted data taken as noted above
  `which' -- interactive task which outputs the path_ids ("COM_XXXX") that
                were `nircombined' to produce the image at a given image cursor
                position.  The resultant image must be in the display.
  `xyadopt' -- a number of changes, including an "all_images" parameter to
                 over-ride "nraster" within a mosaic to allow all the images to
                 be used.  Previously, one was limited to the number of images
                 within the "nraster" line of the database.  Since one could
                 have generated a longer listing (using `mergecom'), the task
                 was amended to allow a larger number.
  `xyget' -- output modified to skip images which have not been adequately
                 centroided.  Previously, all images were included.  Only on
                 careful reading of verbose+ output, could one realize that
                 some of the off-sets might be ill-defined.
  `zget' -- minor changes

================================================================================

Assuming you copy the package somewhere in a directory called "sqiid", you
would put the following definitions in you loginuser.cl file:

	set     sqscripts       = "your_pathname/sqiid/"
	task    $sqiid          =  sqscripts$sqiid.cl

You also need to edit the sqiid.cl in the "sqiid" package to file to point to
your path instead of my path!

Sample files needed to GEOTRAN images in one color to that of another color are
included in the geotran subdirectory as follows:
  files for GEOTRAN the raw (S up E left) JH to K: n10[jh]tok.geo[co|db]
  files for GEOTRAN the raw (S up E left) HK to J: n10[hk]toj.geo[co|db]
  files for GEOTRAN the raw (S up E left) JK to H: n10[jk]toh.geo[co|db]
  files for GEOTRAN the oriented (N up E left) JH to K: n10[jh]toktr.geo[co|db]
  files for GEOTRAN the oriented (N up E left) HK to J: n10[hk]tojtr.geo[co|db]
  files for GEOTRAN the oriented (N up E left) JK to H: n10[jk]tohtr.geo[co|db]

Both (.geoco & .geodb) files are needed in the directory where images are
GEOTRANed.  See the README file inside the geotran directory for more details.

Since a number of the scripts call the UNIX "awk" command to do their fancy
formatted output, "awk" must be available if the parameter format=yes
is selected.

A preliminary user manual for the sqiid package is in "DOC/sqiid.doc"

The sqiid IRAF package is available from a tar file called "sqiid.tar"
within the ftp-anonymous area at mira.tuc.noao.edu.  You can retrieve it
by using:

   ftp mira.tuc.noao.edu ( aka 140.252.3.85)
   logging in as "anonymous"
   using your last name as password
   cd pub/sqiid
      to see what's there
   get sqiid.tar
      to get tar file
   bye

Contact me (merrill@noao.edu;602-325-9319) when you have successfully retrieved
the programs and if you have further questions.

Program-related problems are most easily addressed if the appropriate info are
included with the problem report:

    copy of command line used to call the task 
    lpar of the task in question ( lpar task_name >> errfile )
    copies of the ascii files called by that task (type filenames >> errfile)
    version of IRAF used (= cl.version)

Michael Merrill
