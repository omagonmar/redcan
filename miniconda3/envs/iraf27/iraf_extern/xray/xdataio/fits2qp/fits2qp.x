#$Header: /home/pros/xray/xdataio/fits2qp/RCS/fits2qp.x,v 11.0 1997/11/06 16:34:43 prosb Exp $
#$Log: fits2qp.x,v $
#Revision 11.0  1997/11/06 16:34:43  prosb
#General Release 2.5
#
#Revision 9.3  1997/09/18 22:50:27  prosb
#JCC(9/16/97) - add a flag (isAXAF) for asc data and pass it to ft_nxtext
#               [ rosat needs ft_addparam for case 200-220 in ft_nxtext ]
#
#Revision 9.2  1997/09/03 15:16:51  prosb
#no changes.
#
#Revision 9.0  1995/11/16 18:58:41  prosb
#General Release 2.4
#
#Revision 8.1  1994/09/16  16:33:46  dvs
#Modified routine to add support for alternate qpoe indexing and
#to support reading of TSCAL/TZERO.
#
#Revision 8.0  94/06/27  15:20:17  prosb
#General Release 2.3.1
#
#Revision 7.2  94/03/02  14:16:43  mo
#MC	3/2/94		no changes
#
#Revision 7.1  94/02/25  11:18:05  mo
#MC	2/25/94		Fix some bad calling sequences for streq
#			and add knowncards initializations here so
#			they no longer happen inside ft_nxtext loop
#			and do memory alloc/clean-up here so that
#			it's correctly paired.
#
#Revision 6.5  93/12/15  11:53:55  mo
#no changes
#
#Revision 6.4  93/12/13  12:54:30  mo
#MC	12/13/93		Propagate the 'display' parameter to subs
#
#Revision 6.3  93/11/29  16:26:20  mo
#MC	11/29/93		Update for RDF, GTIFILT callling sequence, etc.
#
#Revision 6.2  93/09/03  17:29:44  mo
#JMORAN/MC	9/3/93		GTI update for RATFITS
#
#Revision 6.1  93/07/28  14:06:33  mo
#Jmoran's fixes for RDF (mostly MWCS stuff)
#
#Revision 5.2  92/11/23  09:42:17  jmoran
#JMORAN added "call qpio_close(io)" to avert PANIC SEGV's with QPOES
#having time, but no GTIS
#
#Revision 5.1  92/11/18  11:51:47  mo
#MC	11/18/29		Fix tim_cktime call which was using the
#				qpio handle instead of the qp handle
#				This was fatal for files with QPOE files
#				with no 'time' attribute
#
#Revision 5.0  92/10/29  21:37:59  prosb
#General Release 2.1

#Revision 4.14  92/10/23  15:39:32  mo
#MC	remove debug statements
#
#Revision 4.13  92/10/21  16:05:47  mo
#MC	10/21/92	Fixed case of no events and no gti.
#
#Revision 4.12  92/10/15  16:24:41  jmoran
#*** empty log message ***
#
#Revision 4.11  92/10/14  16:50:32  mo
#MC	10/14/92		Add attribute check for 'time' and
#				force an update of the MWCS using the
#				corrected CRPIX values
#
#Revision 4.10  92/10/11  17:47:28  mo
#MC/JM	10/11/92		Add ONTIME entry for MPE tables
#
#Revision 4.9  92/10/01  18:30:03  mo
#MC	10/1/92		Add the IRAF 'title' parameter with the OBJECT
#			value
#
#Revision 4.8  92/10/01  15:08:21  jmoran
#JMORAN Added change for gtis - one pointer with all gtis -> 
#  2 pointers, one w/ start times, one w/ stop (ALL FOR MPE)
#
#Revision 4.7  92/09/28  18:06:18  mo
#MC/JMORAN	9/27/92		Added mpe_instr paramter to ft_addev, etc.
#
#Revision 4.6  92/09/23  13:39:04  jmoran
#JMORAN - fixed call sequence to ft_addev
#
#Revision 4.5  92/09/23  11:27:40  jmoran
#JMORAN - MPE ASCII FITS changes
#
#Revision 4.4  92/07/13  14:08:29  jmoran
#JMORAN broke subs into own files
#
#Revision 4.3  92/07/07  17:24:41  jmoran
#JMORAN Added code to append indices (for FITS vectors) to QPOE macro names
#        Changed SZ_LINE in numerous instances to SZ_TYPEDEF so that the
#        QPOE header parameters could be longer
#
#Revision 4.2  92/06/24  16:16:54  jmoran
#JMORAN - Added boolean to determine whether auto-naming happened to get
#correct QPOE output name to open and close at the end of the task
#
#Revision 4.1  92/06/08  14:07:42  jmoran
#JMORAN added code to get and put the qpoe header to ensure that the
#dead time correction factor is written out correctly to the qpoe file
#
#Revision 4.0  92/04/27  15:01:29  prosb
#General Release 2.0:  April 1992
#
#Revision 3.5  92/04/23  15:42:32  mo
#MC	4/23/92		Fix routine to check for GTI's before reading them!
#
#Revision 3.4  92/04/15  10:42:40  jmoran
#JMORAN changed strcpy to correct number of args
#
#Revision 3.3  92/04/13  14:59:25  mo
#MC	4/13/92		Update this code to add deffilt as well
#			as defattr but only if TIME available in 
#			the file
#
#Revision 3.2  91/12/16  17:39:13  dennis
#DS	12/16/91	Removed the conditional 'if (IEEE_USED == NO)' 
#
#			for the 2 calls to miiustruct(); miiustruct() 
#			handles all cases correctly, and the conditional 
#			prevented correct processing on non-Sun-like 
#			IEEE machines (e.g., DECstation)
#
#Revision 3.1  91/09/16  12:08:17  mo
#MC	9/16/91		Add a few missing card types to header reader
#			to improve ERROR reporting on NON-A3DTABLE files
#			Since this ONLY reads A3DTABLE( oops - BINTABLE )
#			it should be graceful when given the wrong type.
#
#Revision 3.0  91/08/02  01:13:56  prosb
#General Release 1.1
#
#Revision 2.6  91/08/01  22:00:00  mo
#MC	8/1/91		Improved the error message when input doesn't exist
#
#Revision 2.5  91/07/17  17:07:23  mo
#MC	7/17/91		Add checks for case where the user input filename
#			is the same as the OLDQPOENAME filename, so
#			that they don't conflict.
#
#Revision 2.4  91/05/24  15:04:21  mo
#5/24/91	MC	Introduced the new BINTABLE extension keyword
#			though A3DTABLE will be supported as well.
#			Cleaned up the code a bit for forcing all QPOE
#			parameters to be UPPER CASE ( with the exception
#			of TITLE - of course. )
#
#Revision 2.3  91/04/11  17:54:17  mo
#	MC	4/11/91		Add code to handle TITLE string differently
#				by making sure the TITLE name gets written
#				as lower case - though all other parameter
#				names have been changed to upper case to
#				be compatible with the QPOE files.  This
#				got broken with the last fix.
#
#Revision 2.2  91/03/27  16:02:13  mo
#	MC	3/27/91		Fix bug for autonaming when clobber == no.
#
#Revision 2.1  91/03/22  15:51:21  pros
#MC	3/22/91		Modified this routine to write out all UPPER CASE
#			QPOE header parameter keywords, since this is
#			what the related toe2qp routines do.  QPOE parameters
#			are case-sensitive, but IMHEAD only shows them
#			as upper case, so let's try to be obvious.  
#
#Revision 2.0  91/03/06  23:26:29  pros
#General Release 1.0
#
# Module:	FITS2QP
# Project:	PROS -- ROSAT RSDC
# Purpose:	Convert FITS files using 3D TABLES to PROS QPOE file
# Description:	< opt, if sophisticated family>
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989.  You may do anything you like with this
#		file except remove this copyright
# Modified:	{0} E. Mandel initial version 	August 1990
#		{1} M. Conroy -- Fixes bug that caused GTI records to
#				 be lost when copied  -- November 1990 
#		{2} MC    -- Add macro definitions for TSI
#			     and fix parameter name building
#			     in addaux			 -- 1/91
#		{3} MC    -- Add support for TITLE and IRAFNAME
#			     strings				 -- 2/25/91
#		{4} MC    -- Add support for our new QPOENAME
#			     keyword and an oldqpoename parameter
#			     similar to the IRAF RFITS switch    -- 2/26/91
#		{n} <who> -- <does what> -- <when>
#

include <mach.h>
include <qpset.h>
include <ext.h>
include <fset.h>
include <evmacro.h>
include <qpioset.h>
include	<qpoe.h>
include "cards.h"
include "fits2qp.h"
include "mpefits.h"
include "ftwcs.h"

procedure t_fits2qp()

char	fname[SZ_LINE]			# FITS file name
char	qpname[SZ_LINE]			# QPOE file name
char	tempname[SZ_LINE]		# temp QPOE name
char	extname[SZ_LINE]		# table extension name
char	extitype[SZ_TYPEDEF]		# extension type definition (input)
char	extotype[SZ_TYPEDEF]		# extension type definition (output)
char	extptype[SZ_TYPEDEF]		# pros event type definition
char	keystr[SZ_LINE]			# pros header keyword for deffilt
char	dname[SZ_LINE]			# pros header keyword for deffilt
char	key_x[SZ_LINE]			# x-index key 
char	key_y[SZ_LINE]			# y-index key
int	nrecs				# number of records in extension
int	bytes				# numner of bytes per extension record
int	fptr				# current pointer into FITS file
int	display				# display level
int	fd				# FITS file handle
pointer	wcs				# wcs from the fits file.
pointer	mw
pointer	gintvs				# good intervals array
pointer	gbegs				# good intervals array
pointer	gends				# good intervals array
pointer	ltimsp				# time filter string
pointer	ev				# pointer to requested event
pointer	io				# QPOE/EVENT list handle
int	n,i
int	num_gintvs			# number of intervals in gintvs
int	qp				# QPOE file handle
int	idx
int	offset
bool	clobber				# clobber already existing output?
bool	scale				# should we apply TSCAL/TZERO scaling?
double	duration

int	clgeti()			# get cl int param
int	access()
int	open()				# open a file
pointer	coerce()
pointer	qp_open()			# open a qpoe file
pointer	qpio_open()
pointer	qpio_stati()
int	qp_accessf()			# open a qpoe file
int	ft_nxtext()			# get next extension
bool	clgetb()			# get cl bool param
bool	streq()				# string compare
bool	strne()				# string compare
bool	ck_qpatt()
bool	knowncards()
bool	fits_qpname_flag
int	strlen()
double	get_gtitimes()

pointer	qphead

int	in
int	retval
bool	mpe_table
pointer mpe_ptr
pointer mpe_gti
pointer dummy_ptr

int	mpe_instr
pointer wcs_rat
bool	wcs_rat_found 

char	gti_root[SZ_LINE]
char	which_gti[SZ_LINE]
char	stdgti_str[SZ_LINE]
char	allgti_str[SZ_LINE]
char    oldgti_str[SZ_LINE]

char	skipname[SZ_LINE]
char	which_events[SZ_LINE]
char	old_events[SZ_LINE]
char	std_events[SZ_LINE]
char	rej_events[SZ_LINE]

bool	gtis_exist
bool    get_timeoff()

pointer	ext

int	revision
int	format	

#JCC(9/16/97)
int     strldx()        #last index into string
int     strncmp()       
int     ip2 
bool    isAXAF          # new flag

include "fits2qp.com"

begin

#-------------------------
# Flush STDOUT on newlines
#-------------------------          
	ltimsp = NULL
	wcs = NULL
	call fseti (STDOUT, F_FLUSHNL, YES)

#call printf("running fits2qp...\n")

	# get input file name
	call clgstr("fits", fname, SZ_LINE)
	# make an input file name
	if( access(fname,0,0) == NO ){
	    call rootname("", fname, ".fits", SZ_LINE)
	}
	if( access(fname,0,0) == NO ){
	    call eprintf("Input file does not exist WITH or WITHOUT the .fits: %s\n")
	        call pargstr(fname)
	    call error(0,"Input file does not exist")

	}
	# make sure we have a valid input file name
	if( streq(fname, "NONE") )
	    call error(1, "requires a input FITS file name")

	# get output file
	call clgstr("qpoe", qpname, SZ_LINE)

	# make the output file name
	call rootname(fname, qpname, EXT_QPOE, SZ_LINE)

	# make sure we have a valid file name
	if( streq(qpname, "NONE") )
	    call error(1, "requires a qpoe file name as output")

	# get qpoe size info, in case its not in the fits file
	naxlen = clgeti("naxes")
	axlen1 = clgeti("axlen1")
	axlen2 = clgeti("axlen2")

	# set the revision # to a default value
	revision = 0
	format = 0

	# get index key x & y
	call clgstr("key_x", key_x, SZ_LINE)
	call clgstr("key_y", key_y, SZ_LINE)

	# make sure they're in lower case!
	call strlwr(key_x)
	call strlwr(key_y)

	# get the table name that contains the events, in case its not
	# in the fits file

	call clgstr("old_events", old_events, SZ_LINE)
	call clgstr("std_events", std_events, SZ_LINE)
	call clgstr("rej_events", rej_events, SZ_LINE)
	call clgstr("which_events", which_events, SZ_LINE)

	call strclr(skipname)

	if (streq(which_events, "old"))
	{
	   call strcpy(old_events, evname, SZ_LINE)
	}
	else 
	   if (streq(which_events, "standard") )
	   {
	       call strcpy(std_events, evname, SZ_LINE)
	       call strcpy(rej_events, skipname, SZ_LINE)
	   }
	   else
	      if (streq(which_events, "rejected") )
	      {
	          call strcpy(rej_events, evname, SZ_LINE)
		  call strcpy(std_events, skipname, SZ_LINE)
	      }
	   
	# get the ever-present clobber and display params
	clobber = clgetb ("clobber")
	qpoe = clgetb("oldqpoename")

	# make sure we can clobber the file
	call clobbername(qpname, tempname, clobber, SZ_PATHNAME)
	display = clgeti("display")

	if( display > 1)
	{   call printf("event table name is:  *%s*\n")
        	call pargstr(evname)
	    call printf("table name to skip is *%s*\n")
		call pargstr(skipname)
	}

	# get boolean to see if is an MPE ASCII FITS table
	mpe_table = clgetb("mpe_ascii_fits")

	# get boolean to see if we should apply TSCAL/TZERO scaling
	scale = clgetb("scale")

	# get qpoe internals
	if( clgetb("qp_internals") ){
	    pagesize = clgeti("qp_pagesize")		# get qpoe pagesize
	    bucketlen = clgeti("qp_bucketlen")		# get qpoe bucketlen
	    blockfactor = clgeti("qp_blockfactor")	# get default block
	    mkindex = clgetb("qp_mkindex")		# make an index?
	    if( mkindex )
		call clgstr("qp_key", key, SZ_KEY)	# get index key
	    debug = clgeti ("qp_debug")			# get qpoe debug level
	}
	else{
	    pagesize = QPC_PAGESIZE
	    bucketlen = QPC_BUCKETLEN
	    mkindex = QPC_MKINDEX
	    blockfactor = QPC_BLOCKFACTOR
	    if( mkindex )
		call strcpy(QPC_KEY, key, SZ_KEY)
	    debug = QPC_DEBUG
	}

	# init the fits2qp common
	naxis = 0
	tnaxis = 0
	bitpix = 0
	evpos = 0
	evitype[1] = EOS
	evotype[1] = EOS
	evnrecs = 0
	evbytes = 0
	evfptr = 0

#       # define known cards
        call clgstr("fits_cards", dname, SZ_LINE)
        if( !knowncards(dname) )
           call errstr(1, "can't open fits defs file", dname)

	fd = open(fname, READ_ONLY, BINARY_FILE)

	# open the qpoe file
	qp = qp_open (tempname, NEW_FILE, NULL)

	# write some standard parameters to the qpoe file
	call ft_standard(qp)

	# process the FITS header and write qpoe header
	call ft_header(fd, qp, qpname, clobber, mpe_table, display)

	# Zap the previous knowncards for FITS primary image
	call zapknown()
	# define known cards for FITS extentions
	call clgstr("ext_cards", dname, SZ_LINE)
	if( !knowncards(dname) )
	    call errstr(1, "can't open ext defs file", dname)

        call clgstr("wcs_cards", dname, SZ_LINE)
        if( !knowncards(dname) )
	    call errstr(1, "can't open wcs defs file", dname)
# JCC(9/16/97)- add a flag isAXAF and pass it to ft_nxtext()
        #call printf("wcs_cards= %s\n")
        #call pargstr(dname)

        ip2 = strldx(".",dname[1])     #strldx(".","testtt.cards")=7
        #call printf(" strldx of . =%d\n")
        #call pargi(ip2)
        #call printf("wcs_cards[ip2-6]=%sJCC\n")
        #call pargstr(dname[ip2-6])    #for wcshri.cards
        #if (strncmp(dname[ip2-6],"wcshri.cards",12) == 0 ) 
        #call printf("it is wcshri.cards\n")
        #else
        #call printf("it is NOT wcshri.cards\n")

        if ((strncmp(dname[ip2-6],"wcshri.cards",12)!=0)&&
           (strncmp(dname[ip2-7],"wcspspc.cards",12)!=0)&&
           (strncmp(dname[ip2-3],"wcs.cards",12)!=0)&&
           (strncmp(dname[ip2-7],"wcsipc1.cards",12)!=0))
        {  isAXAF = TRUE
           #call printf("isAXAF = TRUE\n")
        }
        else 
        {  isAXAF = FALSE
           #call printf("isAXAF = FALSE\n")
        }
# JCC(9/16/97) - end

	call clgstr("qpoe_cards", dname, SZ_LINE)
	if( !knowncards(dname) )
	    call errstr(1, "can't open qpoe defs file", dname)
	
	# Now skip the image data, if necessary
	if( naxis !=0 ){
	    call eprintf("warning: skipping image data\n")
	    call eprintf("warning: Use RFITS to access FITS IMAGE data\n")
	    call ft_skip(fd, tnaxis*bitpix/NBITS_BYTE/SZB_CHAR, NO)
	}

	if (!mpe_table)
	{
	   wcs_rat_found = false
	   # process the extension tables until EOF
	   while(true)
	   {
	      dummy_ptr = NULL

              #JCC (9/16/97) - pass isAXAF to ft_nxtext
	      retval = ft_nxtext(fd, display, extname, 
		        extitype, extotype, extptype, nrecs, bytes, 
                        fptr, wcs, qp, ext, scale, dummy_ptr, mpe_gti, 
                        mpe_instr, mpe_table, wcs_rat, wcs_rat_found, 
                        key_x, key_y, revision, format, skipname,isAXAF)

	      switch(retval)
	      {

	      # end of file
	      case END:
		break
	      # add auxiliary data
	      case AUX:
		call ft_addaux(fd, extname, extitype, extotype,
					extptype, nrecs, bytes, qp, ext, scale)
	      # save event data for later entry
	      case EVENT:

                call ft_savev(extname, extitype, extotype, extptype,
                              ext, nrecs, bytes, fptr, wcs)
                call ft_skip(fd, nrecs*bytes/SZB_CHAR, NO)

	      # skip unknown table
	      case SKIP:
		call ft_skip(fd, nrecs*bytes/SZB_CHAR, NO)

	    } # end switch
	  } # end while

          # add the events last of all
          if( (evfptr !=0) && (evotype[1] != EOS) )
	  {
             call ft_addev(fd, qp, mpe_ptr, mpe_table, mpe_instr, scale)

	     call ft_free_ev()  # frees memory saved in event structure.
	  }
          else
	  {
            call eprintf("warning: no event list found!\n")
            call eprintf("If this is an IMAGE FITS file - use RFITS\n")
          }
	} # end if
	else
	{
           #-------------------------------
           # Allocate the MPE GTI structure
           #-------------------------------
           call calloc (mpe_gti, SZ_GTI_STRUCT, TY_STRUCT)
           FOUND_GTIS(mpe_gti) = false
           PARSED_GTIS(mpe_gti) = false
           COUNT_GTIS(mpe_gti) = 0
           GTI_BUFSZ(mpe_gti)  = MAX_GTIS
           call calloc (GTI_PTR(mpe_gti), GTI_BUFSZ(mpe_gti), TY_DOUBLE)

           #JCC (9/16/97) - pass isAXAF to ft_nxtext
           retval = ft_nxtext(fd, display, extname, extitype, extotype,
		    extptype,nrecs, bytes, fptr, wcs, qp, ext, scale, 
                    mpe_ptr, mpe_gti, mpe_instr, mpe_table, wcs_rat,
		    wcs_rat_found, key_x, key_y, revision, format, 
                    skipname, isAXAF)

	   call ft_savev(extname, extitype, extotype, extptype,
				ext, nrecs, bytes, fptr, wcs)
	   call ft_addev(fd, qp, mpe_ptr, mpe_table, mpe_instr, scale)

           call ft_free_ev()  # frees memory saved in event structure.
           #------------------------------------------------------
           # Reallocate the GTI memory to the exact number of GTIS
           #------------------------------------------------------
           call realloc (GTI_PTR(mpe_gti), COUNT_GTIS(mpe_gti), TY_DOUBLE)

	   # this space is allocated in mpe_typedef
	   call mfree(SIZE(mpe_ptr), TY_INT)
	   call mfree(TYPE(mpe_ptr), TY_INT)
           call mfree(mpe_ptr, TY_STRUCT)
	}

	#  Alloced in ft_nxtext (or MPE_HEAD) - no longer freed in ft_addev
	do i=1,2
	    call mfree(IW_CTYPE(wcs, i), TY_CHAR)
	call mfree(wcs, TY_STRUCT)
	wcs = NULL

# write event macros
	call ft_macros(qp, prostype)

	# write history
	if( qpoe )
	    call ft_hist(qp, fname, qpoename)
	else
	    call ft_hist(qp, fname, qpname)

	call close(fd)
	call qp_close(qp)
	# rename the output file if necessary
	if( qpoe ){     # try to rename to the FITS QPOENAME if requested
	    fits_qpname_flag = true
	    if( display >= 1){
	        call printf("Writing output QPOE file: %s\n")
	            call pargstr(qpoename)
	    }
	    if( strne(tempname,qpoename) ){   # if the temp != qpoename
					     # finalname will 'delete' qpoename
					     # so - make sure it exists
		if (access (qpoename, 0, BINARY_FILE) == NO){
                    in = open (qpoename, NEW_FILE, BINARY_FILE)
                    call close(in)
		}
	    }
	    iferr( call finalname(tempname, qpoename) ){
	        if( display >= 1){
		      call printf("Output filename failed -- retrying\n")
	            call printf("Writing output QPOE file: %s\n")
		      call pargstr(qpname)
		}
	        call finalname(tempname, qpname)  # otherwise default to user name
		fits_qpname_flag = false
	    }
	}
	else{
	    fits_qpname_flag = false
	    if( display >= 1){
	        call printf("Writing output QPOE file: %s\n")
		    call pargstr(qpname)
	    }
	    call finalname(tempname, qpname)
	}
	if (fits_qpname_flag)
	{
	   qp = qp_open(qpoename, READ_WRITE, NULL)
	}
	else
	{
 	    qp = qp_open(qpname, READ_WRITE, NULL)
	}

        
	#----------------------------------------------------
	# Add the DEFFILT header parameter if there are GTI's
        #----------------------------------------------------
	call clgstr("stdgti_name", stdgti_str, SZ_LINE)
        call clgstr("allgti_name", allgti_str, SZ_LINE)
        call clgstr("oldgti_name", oldgti_str, SZ_LINE)

	gtis_exist = false
	if (qp_accessf(qp, oldgti_str) == YES)
	{
	    call strcpy(oldgti_str, gti_root, SZ_LINE)
	    gtis_exist = true
	}
	else
	{
	   call clgstr("which_gti", which_gti, SZ_LINE)

           if (streq(which_gti, "standard"))
              call strcpy(stdgti_str, gti_root, SZ_LINE)

           if (streq(which_gti, "all"))
              call strcpy(allgti_str, gti_root, SZ_LINE)
	        
	   if (qp_accessf(qp, gti_root) == YES)
	      gtis_exist = true
	}
	
	if (gtis_exist)
	{
	       duration = get_gtitimes(qp,gbegs,gends,num_gintvs,1, gti_root)
               call put_gtifilt(gbegs, gends, num_gintvs, ltimsp)
	       call mfree(gbegs,TY_DOUBLE)
	       call mfree(gends,TY_DOUBLE)
	}
	else if (mpe_table)
	{
               num_gintvs = COUNT_GTIS(mpe_gti)/2
               gintvs = GTI_PTR(mpe_gti)

	       duration = 0.D0
               call calloc(gbegs, num_gintvs+1, TY_DOUBLE)
               call calloc(gends, num_gintvs+1, TY_DOUBLE)

               do idx = 1, num_gintvs
	       {
                  Memd[gbegs + idx - 1] = Memd[gintvs + 2*idx - 2]
                  Memd[gends + idx - 1] = Memd[gintvs + 2*idx - 1] 
	          duration = duration + Memd[gends+idx-1] - Memd[gbegs+idx-1]
	       }

               call put_gtifilt(gbegs, gends, num_gintvs, ltimsp )
               call mfree(gbegs,TY_DOUBLE)
               call mfree(gends,TY_DOUBLE)
	}
	else      # use first and last event if there are no time intervals
	{
	    if( ck_qpatt(qp,"time") )
	    {
                io = qpio_open(qp,"",READ_ONLY)
                if( get_timeoff(qp,"source",offset) )
                {
                    num_gintvs = 1
                    call calloc(gbegs, num_gintvs+1, TY_DOUBLE)
                    call calloc(gends, num_gintvs+1, TY_DOUBLE)
                    ev = qpio_stati(io,QPIO_MINEVP)
                    Memd[gbegs] = Memd[coerce(ev+offset,TY_SHORT,TY_DOUBLE)] -
				  double(EPSILONR)
                    ev = qpio_stati(io,QPIO_MAXEVP)
                    Memd[gends] = Memd[coerce(ev+offset,TY_SHORT,TY_DOUBLE)] +
				  double(EPSILONR)
                    call put_gtifilt(gbegs, gends, num_gintvs, ltimsp )
                    call mfree(gbegs,TY_DOUBLE)
                    call mfree(gends,TY_DOUBLE)
                } # end 'timeoff' - time is double precision
                call qpio_close(io)

	    }  # end ck_qpatt ( time available in file )
	}

            if( ck_qpatt(qp,"time") )
	        call strcpy("deffilt", keystr, SZ_LINE)
	    else
	        call strcpy("XS-FHIST", keystr, SZ_LINE)

#	    If there are NO EVENTS with TIME, and NO GTI info, ltimsp will never
#		have been allocated  
	    if( ltimsp != NULL ){
	        n = strlen(Memc[ltimsp])
                call qpx_addf(qp, keystr, "c", n+SZ_LINE,
                        "standard time filter",QPF_NONE)
                call qp_pstr(qp, keystr, Memc[ltimsp])
	    }

	# close the input and output files
	call mfree(ltimsp,TY_CHAR)

#-------------------------------------
# If MPE ASCII, free the GTI structure
#-------------------------------------
        if (mpe_table)
        {
	   call mfree(GTI_PTR(mpe_gti), TY_DOUBLE)
           call mfree(mpe_gti, TY_STRUCT)
        }


#------------------------------------------------------------------------
# To ensure that the dead_time correction factor is written out correctly
# to the output qpoe file, open the qpoe, get the header, put the header
# and close the qpoe.  The routine "get_qphead" calls the routine that
# will fix the dead time correction factor.  
#------------------------------------------------------------------------
	call get_qphead(qp, qphead)
	call qph2mw(qphead,mw)
	call qp_savewcs(qp,mw,2)
	call mw_close(mw)

#--------------------------------------------------------------------
# If this is an mpe_table, need to write out the on times, live times
# and dead times since they're not in the FITS file
#--------------------------------------------------------------------
	if (mpe_table)
	{
           QP_DEADTC(qphead) = 1.0E0
	   QP_ONTIME(qphead) = duration
	   QP_DEADTC(qphead) = 1
           QP_LIVETIME(qphead) = QP_ONTIME(qphead)*QP_DEADTC(qphead)
	}

#--------------------------------------------------------------------
# We must also write out the x- and y- indices to the qphead
#--------------------------------------------------------------------
	call strcpy(key_x,QP_INDEXX(qphead),SZ_INDEXX)
	call strcpy(key_y,QP_INDEXY(qphead),SZ_INDEXY)

#JCC(9/16/97) - add 2 lines for rosat 
        if (!isAXAF)
           QP_FORMAT(qphead) = 1

	call put_qphead(qp, qphead)
	call mfree(qphead,TY_STRUCT)
	call qp_close(qp)
	call zapknown()

#call printf("Exit fits2qp\n")

end
