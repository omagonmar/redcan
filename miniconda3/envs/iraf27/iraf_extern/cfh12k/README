INSTALLATION (Mar01)             cfh12k             INSTALLATION (Mar01)



                CFH12K: CFH 12K MOSAIC REDUCTION PACKAGE
              Release Notes and Installation Instructions



SUMMARY
The CFH12K external package is used to reduce CFH 12K CCD  mosaic  data.
It  provides a task for updating the raw headers to work with the MSCRED
package and a task to set the default parameters.   The  reductions  are
then done using the MSCRED Mosaic reduction package.



DISCLAIMER
The  package  is  provided as a service to IRAF users with CFH 12K data.
It was developed and is supported by the IRAF Group at  NOAO.   The  CFH
Observatory  is  in  no way responsible for this package.  Please report
any problems and send questions to iraf@noao.edu.



RELEASE INFORMATION
The following summary only highlights the  major  changes.   There  will
also be minor changes and bug fixes as needed.


V1.1: July 24, 2002
    The  HDRCFH12K  task which fixes up problems in the raw data headers
    was setting a vertical flip in the  display  of  "chip07".   Whether
    this  was  actually  ever  right  I am not sure but the flip has now
    been removed.

V1.0: March 6, 2001
    First package  release.   This  package  requires  that  the  MSCRED
    external  package  of  at  least  "V4.4:  March  6,  2001"  also  be 
    installed.  Send feedback on this package to iraf@noao.edu.


INSTALLATION INSTRUCTIONS
Installation of this external package consists of obtaining  the  files,
creating   a   directory   containing  the  package,  and  defining  the 
environment to load and run the package.  The package may  be  installed
for  a  site or as a personal installation.  If you need help with these
installation  instructions  contact  iraf@noao.edu  or  call  the   IRAF 
HOTLINE at 520-318-8160.

[1-site]
    If  you  are  installing  the package for site use login as IRAF and
    edit the IRAF file defining the packages.
    
        % cd $hlib
        % vi extern.pkg
    
    Add the following to the file.
    
        reset cfh12k = <path>/cfh12k/
        task  cfh12k.pkg = cfh12k$cfh12k.cl
    
    Near the end of the hlib$extern.pkg file, update the  definition  of
    helpdb  so  it includes the cfh12k help database, copying the syntax
    already  used  in  the  string.   Add  this  line  before  the  line 
    containing a closing quote:
    
        ,cfh12k$lib/helpdb.mip\

[1-personal]
    In your login.cl or loginuser.cl file make the following definitions
    somewhere before the "keep" statement.
    
        reset cfh12k = /mydir/cfh12k/
        task  cfh12k.pkg = cfh12k$cfh12k.cl
        printf ("reset helpdb=%s,cfh12k$lib/helpdb.mip\nkeep\n",
            envget("helpdb")) | cl
        flpr

[2] Login into IRAF.  Create a directory to contain the package files as
    defined  above.   This directory should be outside the standard IRAF
    directory tree.
    
        cl> mkdir cfh12k$
        cl> cd cfh12k

[3] The package is distributed as a tar archive.
    
        cl> ftp iraf.noao.edu (140.252.1.1)
        login: anonymous
        password: [your email address]
        ftp> cd iraf/extern
        ftp> get cfh12k.readme
        ftp> binary
        ftp> get cfh12k.tar.Z
        ftp> quit
        cl> !uncompress cfh12k.tar
    
    The readme file contains these instructions.

[4] Extract the source files from the tar archive using 'rtar".
    
        cl> softools
        so> rtar -xrf cfh12k.tar
        so> bye
    
    The tar file can be deleted once it has been successfully installed.

This should complete the installation.  You can  now  load  the  package
and begin testing and use.

To  use the package first load it.  You do not need to load MSCRED as it
will be done for you.  The first step is to run the  task  SETCFH12K  to
set  some  default  parameters.   This  corresponds to the SETINSTRUMENT
task in MSCRED and CCDRED.  This task only needs to  be  run  once  when
you  start  reducing  data and does not need to be done again unless you
use MSCRED to reduce data from another mosaic.

The task HDRCFH12K must be run on all raw data files.   After  this  you
can  use  the  tasks  from the MSCRED package.  For help on that package
use "help mscguide".  There is currently only minimal  help  for  MSCRED
other  than  the user's guide.  This is help for SETCFH12K and HDRCFH12K
available with this package.
