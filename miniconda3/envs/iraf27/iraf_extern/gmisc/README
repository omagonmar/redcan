               GMISC -- Miscellaneous Gemini Related Tasks

GMISC contains the development versions of those Gemini reduction packages,
scripts, and tasks written by the NOAO IRAF group.  


RELEASE INFORMATION
===============================================================================

Wed Apr 14 16:08:33 MST 2004
	Added GSCOMBINE task (Pre-release of revised SCOMBINE).  (Valdes)
Tue Jan 25 14:33:54 MST 2000
	Added GSTANDARD task.  (Valdes)
Wed Sep 15 10:58:04 MST 1999
	Initial version (Davis, Valdes).



INSTALLATION INSTRUCTIONS
===============================================================================

The installation instructions that follow assume that you have copied the
tar format GMISC archive onto your host machine.  The method you use to
copy the file (or remotely access the tar file) is OS dependent and is not
discussed in this document.  If you have any questions, please contact the
author at davis@noao.edu or the IRAF group at iraf@noao.edu,

[1] The package is distributed as a tar archive; IRAF is distributed
    with a tar reader.  The tar archive may be obtained by anonymous ftp
    as shown below.

        % ftp iraf.noao.edu (140.252.1.1)
        login: anonymous
        password: [your email address]
        ftp> cd iraf/extern
        ftp> get gmisc.readme
        ftp> binary
        ftp> get gmisc.tar.Z
        ftp> quit
        % uncompress gmisc.tar.Z

    The gmisc.readme file contains these instructions. 

[2] Create a directory to contain the GMISC external package files.  This
    directory should be outside the IRAF directory tree and must be owned
    by the IRAF account.  In the following examples, this root directory is
    named  /local/gmisc/.  Make the appropriate file name substitutions
    for your site.

[3] Log in as IRAF and edit the extern.pkg file in the hlib$ directory to
    define the package to the CL.  From the IRAF account, outside the CL,
    you can move to this directory with the commands:

        % cd $hlib              

    Define the environment variable gmisc to be the pathname to the
    gmisc root directory. UNIX pathnames must be terminated with a '/'.
    Edit extern.pkg to include:

        reset gmisc  = /local/gmisc/
        task  gmisc.pkg = gmisc$gmisc.cl

    Near the end of the hlib$extern.pkg file, update the definition of helpdb
    so it includes the gmisc help database, copying the syntax already used
    in the string.  Add this line before the line containing a closing quote:
        
                ,gmisc$lib/helpdb.mip\

[4] Log into the CL from the IRAF account and unpack the archive file.  Change
    directories to the gmisc root directory created above and use 'rtar':

        cl> cd gmisc
        cl> softools
        cl> rtar -xrf <archive>  where <archive> is the host name of the
                                 archive file

   UNIX sites should leave the symbolic link 'bin' in the GMISC
   root directory pointing to 'bin.generic' but can delete any of the 
   bin.`mach' directories that won't be used.  The archive file can be
   deleted once the package has been successfully installed.

[5] Configure the package for the type of system executables to be built;
    i.e. bin.sparc, bin.ssun, bin.linux, bin.alpha, etc.

        cl> mkpkg bin.ssun

[6] When the archive has been unpacked, build the GMISC package executable.  
    The compilation and linking of the GMISC package is done using the
    following command:

        cl> mkpkg -p gmisc update >& gmisc.spool &

    NOTE: On systems that concurrently support different architectures
    (e.g., Suns), you must configure the system for the desired
    architecture before issuing the above command.  SUN/IRAF sites must
    execute a pair of 'mkpkg' commands for each supported architecture type.
    The Unix environment variable IRAFARCH must be set as well before
    compiling.  For example:

        # Assuming IRAFARCH is set to ffpa
        cl> mkpkg -p nmisc -p noao ffpa
        cl> mkpkg -p nmisc -p noao update >& nmisc.ffpa &
        cl> mkpkg -p nmisc -p noao f68881
        # Now reset IRAFARCH to f68881 before continuing
        cl> mkpkg -p nmisc -p noao update >& nmisc.f68881 &

    The spool file(s) should be reviewed upon completion to make sure there
    were no errors.  
