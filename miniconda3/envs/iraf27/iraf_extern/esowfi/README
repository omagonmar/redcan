INSTALLATION (Nov99)             esowfi             INSTALLATION (Nov99)



                ESOWFI: ESO WFI MOSAIC REDUCTION PACKAGE
              Release Notes and Installation Instructions



SUMMARY
The ESOWFI external package is used to reduce ESO WFI CCD  mosaic  data.
It  provides  a  single task for converting the ESO headers to work with
the MSCRED package.  It also sets the default instrument  files  and  an
astrometry  solution.   The  reductions  are  then done using the MSCRED
Mosaic reduction package.



DISCLAIMER
The package is provided as a service to IRAF users with  ESO  WFI  data.
It  was  developed  and  is  supported  by  the IRAF Group at NOAO.  The
European  Southern  Observatory  is  in  no  way  responsible  for  this 
package.    Please   report   any   problems   and   send  questions  to 
iraf@noao.edu.



RELEASE INFORMATION
The following summary only highlights the  major  changes.   There  will
also be minor changes and bug fixes as needed.


V1.3: March 6, 2001
    Rather  than have the package set the parameters when it is loaded a
    new task, ESOSETINST, was added to do  this.   This  change  was  to
    avoid  having the default parameters modified every time the package
    is loaded.  Now  the  user  should  run  this  new  task  once  when
    begining reductions of ESOWFI data.

V1.2: June 13, 2000
    Now supports binned readouts.

V1.1: January 31, 2000
    Since  the  last  release the ESO headers changed the "DET CHIP" and
    "DET OUT" HIERARCH keywords to "DET CHIPn" and "DET OUTn",  where  n
    is  the  extension index.  This broke the ESOHDR task.  The task has
    been modified to work with both the previous and current format.

V1.1: December 2, 1999
    The esodb$esowfi.dat file was  modified  to  map  the  expected  ESO
    values for "HIERARCH ESO DPR TYPE" to the types used by MSCRED.

V1.1: November 24, 1999
    Added  a  step  to  ESOHDR that expands all the headers in one step.
    This is to avoid a complete copy of the MEF  file  for  each  header
    updated.
    
    The  esodb$esowfi.dat  file  was  modified  to  change the imagetype
    keyword to point to "HIERARCH ESO DPR TYPE" which  is  TYPE  in  the
    final header.

V1.0: November 16, 1999
    First  package  release.   This  package  requires  that  the MSCRED
    external package also be installed.  This version has only  had  one
    beta   tester   at   NOAO.    Send   feedback  on  this  package  to 
    iraf@noao.edu.


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
    
        reset esowfi = <path>/esowfi/
        task  esowfi.pkg = esowfi$esowfi.cl
    
    Near the end of the hlib$extern.pkg file, update the  definition  of
    helpdb  so  it includes the esowfi help database, copying the syntax
    already  used  in  the  string.   Add  this  line  before  the  line 
    containing a closing quote:
    
        ,esowfi$lib/helpdb.mip\

[1-personal]
    In your login.cl or loginuser.cl file make the following definitions
    somewhere before the "keep" statement.
    
        reset esowfi = /mydir/esowfi/
        task  esowfi.pkg = esowfi$esowfi.cl
        printf ("reset helpdb=%s,esowfi$lib/helpdb.mip\nkeep\n",
            envget("helpdb")) | cl
        flpr

[2] Login into IRAF.  Create a directory to contain the package files as
    defined  above.   This directory should be outside the standard IRAF
    directory tree.
    
        cl> mkdir esowfi$
        cl> cd esowfi

[3] The package is distributed as a tar archive.
    
        cl> ftp iraf.noao.edu (140.252.1.1)
        login: anonymous
        password: [your email address]
        ftp> cd iraf/extern
        ftp> get esowfi.readme
        ftp> binary
        ftp> get esowfi.tar.Z
        ftp> quit
        cl> !uncompress esowfi.tar
    
    The readme file contains these instructions.

[4] Extract the source files from the tar archive using 'rtar".
    
        cl> softools
        so> rtar -xrf esowfi.tar
        so> bye
    
    The tar file can be deleted once it has been successfully installed.

This should complete the installation.  You can  now  load  the  package
and begin testing and use.

To  use the package first load it.  You do not need to load MSCRED as it
will be done for you.  The first step is to run the task  ESOSETINST  to
set  default  parameters.   This only needs to be run when beginning new
reductions.  This sets parameters in the MSCRED package.

The next step is to run ESOHDR to convert  the  ESOWFI  headers.   After
that  you  can  use the tasks from the MSCRED package.  For help on that
package use "help mscguide".  There is currently only minimal  help  for
MSCRED  other  than  the  user's guide.  There is help available for the
two tasks in this interface package.
