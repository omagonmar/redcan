    MSCRED database directory files for use with NOAO Mosaic Data 


========================== Release Notes =======================================
02/09/04: V4.3
01/15/04: V4.3
    New calibration files.
10/24/02: V4.2
    New Mosaic1 crosstalk and  bad pixel masks.
    New Mosaic2 WCS solutions.
5/18/01: V4.1
    The keyword editing to the CTIO masks was done with the wrong version
    of IRAF making the files unreadable. The symptom is a segmentation
    violation when trying to access the files.  The CTIO masks have been
    convert to the correct format.
4/23/01: V4.1
    The CTIO bad pixel masks lacked the IMAGEID keyword to identify the
    extension to which they belonged.  Even though an explicit filename is
    given in the data CCDPROC will not accept the bad pixel mask unless the
    keywords match.  This behavior of CCDPROC will be changed.  This
    version of MSCDB has the keyword added to the CTIO masks.
3/06/01: V4.1
    This version adds a KPNO crosstalk file derived from Feb 2001 data.
    It is very similar to the previous version.  The data headers continue
    to point to the Sep. 2000 file.
2/28/01: V4
    This version adds CTIO 16ch crosstalk.
1/7/01: V3
    This version adds bad pixel masks for CTIO Mosaic
9/1/00: V2
    This version adds new crosstalk for KPNO Mosaic  This is the mscdb
    for semesters 2000B/2001A with KPNO Mosaic.  If new calibrations are
    made there will be updates.
8/21/99: V1
    This version adds files for the CTIO Mosaic and the WIYN Mosaic.
    It allso adds the WCS database files for all current instruments.
    The WCS files can be used to reset the WCS using the task MSCSETWCS.

================================================================================


mscdb.tar.Z
    When reducing NOAO/Mosaic data with the MSCRED package various setup and
    calibration files are used.  These include the instrument header
    translation files, default parameter setup files (used by
    SETINSTRUMENT), the current crosstalk correction coefficient file, the
    current default bad pixel masks, and the current WCS solutions.  These
    files are in this compressed tar file.mscdb.tar.Z.  To extract the files

	% mkdir mscdb
	% cd mscdb
	% zcat [path]/mscdb.tar | rtar -x

    This will create a directory mscdb in the current directory.  The
    path to this directory is defined in hlib$extern.pkg when installing
    the MSCRED package.  It can also be defined or overridden by the
    user either in login.cl, loginuser.cl or interactively.
