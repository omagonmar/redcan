#$Header: /home/pros/xray/lib/qpcreate/RCS/qpcreate.x,v 11.1 1999/01/29 19:51:56 prosb Exp $
#Revision 11.0  1997/11/06 16:21:47  prosb
#General Release 2.5
#
#Revision 9.2  1996/08/21 15:15:54  prosb
#MO/JCC - Replace SZ_LINE (& SZ_MACRO_STRING) with SZ_TYPEDEF for 
#         prosdef_in/out and irafdef_in/out to fix some problems 
#         with qpsort for AXAF
#
#Revision 9.1  1996/03/11  15:45:24  prosb
#MO/Janet - ascds - add check that the input file is QPOE format.
#
#Revision 9.0  95/11/16  18:29:42  prosb
#General Release 2.4
#
#Revision 8.1  94/09/16  16:17:31  dvs
#Updated qpcreate to allow for any QPOE index, not just "x" and "y".
#Changed position sort to check indices, not default to "y x".
#
#Revision 8.0  94/06/27  14:33:41  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:17:24  prosb
#General Release 2.3
#
#Revision 6.1  93/12/16  09:33:53  mo
#MC	12/15/93		Add new case - QPOE copy for LIST of
#				QPOES, can't use 'new_copy'.
#
#
#Revision 6.0  93/05/24  15:58:40  prosb
#General Release 2.2
#
#Revision 5.3  93/05/19  17:17:53  mo
#MC	5/20/93		Eliminate, can't make index message, when we
#			have 'mkindex=no'.  Move 'finale' stuff to
#			accomodate QPAPPEND.
#
#Revision 5.1  93/01/15  14:32:01  mo
#MC	1/15/92		Added missing 'alloc' for filtstr in updeffilt.
#Caused SEGV on QPOE files which do not contain an existing DEFFILT
#
#Revision 5.0  92/10/29  21:19:04  prosb
#General Release 2.1
#
#Revision 4.12  92/10/23  10:44:28  mo
#MC	10/24/92	Remove obsolete 'deffilt' when new output file
#			has no time.  ( INHERIT caused it to be copied )
#
#Revision 4.11  92/10/16  20:22:50  mo
#no changes
#
#Revision 4.10  92/10/15  16:31:15  jmoran
#JMORAN qp_accessf added 
#
#Revision 4.9  92/10/15  10:27:58  jmoran
#MC added calls to "qph2mw" and "qp_savewcs"
#
#Revision 4.8  92/10/13  14:13:06  mo
#MC	10/13/92		Add conditional for input qpoe to new code					for auto irafdef.  Add fix_wcsref to
#				correct bad files.
#
#Revision 4.7  92/10/05  14:49:40  jmoran
#JMORAN big changes:  shift buffer changes to accomodate FULL event
#	definintion.  Also, if blank output irafdef, default to the
#	input QPOE irafdef
#
#Revision 4.6  92/10/01  11:15:29  mo
#MC	10/1/92		Update with check for QPOE 'time' attribute
#			(qpex_getattr fails on non-time QPOES )
#
#Revision 4.5  92/09/29  14:43:33  mo
#MC	9/29/92		First draft of changes to support DEFFILT as the
#>>                      absolute referenece for exposure time and leaving
#>>                      GTI only as an original archive.  Required changing 
#>>                      to the IRAF format of gbegs and gends rather than
#>>                      a double dimensioned array.
#>>                      Also forces use of DEFFILT for calculating exposure,
#>>                      even if 'nodeffilt' specified by user.
#
#Revision 4.4  92/08/21  14:19:26  mo
#MC	8/21/92		Added additional check for MKINDEX after qpc_oldsort
#			This cured problem when copying a time-sorted file
#			and by default it tried to make an INDEX.  After
#			it's retrieved an existing sortstr from an input
#			QPOE File (  original problem in QPSORT )
#			QPCOPY should default correctly when given a time-sorted
#			input file.
#
#Revision 4.3  92/07/31  13:55:58  prosb
#7/31/92	MC	Move the fix_mjdref routine to xhead
#
#Revision 4.2  92/07/31  13:51:06  prosb
#MC	7/31/92		Add routine to correct existing Einstein files
#			that have the MJDREF set too large by 1 day
#
#Revision 4.1  92/06/08  14:16:44  jmoran
#JMORAN added two routines: "fix_dead_time_cf" and "fix_qphead_times", 
#modified "updeffilt": added boolean "skip_gti_code" and removed goto
#statement
#
#Revision 4.0  92/04/27  13:52:43  prosb
#General Release 2.0:  April 1992
#
#Revision 3.7  92/04/23  15:41:37  mo
#MC	4/23/92		Fix updeffilt for case of no GTI, it
#			needed to skip ALL the rest of the routine.
#
#Revision 3.6  92/04/23  13:00:13  mo
#MC	4/23/92		Had to move the 'updeffilt' code a little
#			later in the driver to accommodate APPLY_BARY
#			Also added 2 additional places to check for
#			'nodeffilt'  In particular, apply_bary sets
#			'qp',QPOE_NODEFFILT in 'hist' to prevent
#			QPCREATE from destroying its changes to 
#			deffilt and GTI, and the correct reference time
#
#Revision 3.5  92/04/22  10:37:32  mo
#MC	4/22/92		UPDEFFILT with bug fix correction - now stable
#			for 10 days ( bug in changing input parameter 
#			in call to output_gtis )
#
#Revision 3.4  92/04/09  08:46:24  mo
#MC	4/9/92	Add routine 'updeffilt' to update the GTI's and athe
#		deffilt header keyword each time a qpoe is copied
#		Incorporates the user filter as well.
#		If deffilt already exists, it uses it, if not ( old format)
#		it retrieves the good_time intervals (GTIS)
#
#Revision 3.3  92/03/18  11:43:29  mo
#MC	Make the LIVETIME calculation conditional on non-zero livetime
#
#Revision 3.2  92/02/06  16:57:15  mo
#MC	2/5/92		Add code to filter the existing GTI records
#			and write the edited GTI records to the output
#			QPOE file.
#			Also update the qphead parameters for total
#			on-time
#
#Revision 3.1  92/01/20  15:47:01  mo
#MC	1/20/92		Add proto-code to update QPOE GTI's with
#			QPOE time-filter info
#
#Revision 3.0  91/08/02  01:05:25  prosb
#General Release 1.1
#
#Revision 2.3  91/08/01  21:52:55  mo
#MC	8/1/91		No change
#
#Revision 2.2  91/04/16  16:20:09  mo
#MC	4/16/91		 Re-fixed the code of the eprintf when deciding when
#to perform a mkindex.  The || needed to be a &&.  Too much
#reverse logic in this statement.
#        Also fixed an error message to eliminate the trailing \n
#which caused an IRAF error.
#
#Revision 2.1  91/04/12  10:06:12  mo
#MC	3/91 	 Fixed the eprintf code, for turning off mkindex.  Widened
#the allowed conditions for accepting a mkindex directive, since
#this code is very generic.  If called from qpcopy, there is
#no sortstr, and key is blank.  This is a legal default to
#position sort and mkindex is valid.
#
#
#
#Revision 2.0  91/03/07  00:11:22  pros
#General Release 1.0
#
# Module:	QPCREATE,A3DCREATE
# Project:	PROS -- ROSAT RSDC
# Purpose:	routines to create PROS/qpoe files and FITS 3d tables files
# Description:	< opt, if sophisticated family>
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989.  You may do anything you like with this
#		file except remove this copyright
# Modified:	{0} egm  initial version <when>	
#		{1} mc -- To warn user when index not possible  -- 11/15/90
#		{2} mc -- To make region addition QPOE specific -- 1/91
#
#

include <qpioset.h>
include <qpoe.h>
include <qpset.h>
include <ext.h>
include <mach.h>
include <einstein.h>
include <evmacro.h>
include <qpc.h>
include <ctype.h>
include "qpcreate.h"
define	SZ_PARAM	20

#
#
# QP_CREATE - main procedure to create a qp file
#
procedure qp_create(argv)

pointer	argv				# i: user argument list

int	eventfd[MAX_ICHANS]		# l: event file channels
int	hdrfd[MAX_ICHANS]		# l: hdr file channels
int	auxfd[MAX_ICHANS]		# l: aux file channels
int	i				# l: loop counter
int	naux				# l: number of aux records
int	display				# l: display level
int	nodeffilt			# l: QPDEFS status for auto filtering
int	pagesize			# l: qpoe pagesize
int	bucketlen			# l: qpoe bucketlen
int	block				# l: qpoe block factor
int	debug				# l: qpoe debug level
int	convert				# l: data conversion flag
int     in_sz_rec
int     out_sz_rec
int     in_cnt
int     out_cnt
int     len
int     in_nmacros
int     in_oevsize
int     out_ev
int     in_ev
pointer	buf
pointer qp				# l: qpoe handle
pointer	io				# l: event handle
pointer	qphead				# l: qpoe header pointer
pointer	qpaux				# l: aux record pointer
pointer	files				# l: array of file names
pointer	sp				# l: stack pointer
pointer key
pointer	timspec				# l: user qpoe filter specifier
pointer qproot				# l: user base qpoe file name
pointer tempname
pointer in_ptr
pointer out_ptr
pointer in_msymbols
pointer in_mvalues
pointer instrument
pointer posstring			# l: position string (e.g. "y x")
bool	input_is_qpoe                   # l: flag that input is a qpoe file
bool	qpoe_list                       # l: flag that input is a qpoe file LIST
bool	mkindex				# l: true if we make an index
bool 	clobber				# l: clobber old qpoe
bool    evdef_blank

int	qpc_isqpoe()			# l: determine if a file is a qpoe
int	clgeti()			# l: get int parameter
int	open()				# l: open a file
int	qp_accessf()
int	qp_stati()
int     qp_gstr()
int     strncmp()
int     stridxs()
bool	clgetb()			# l: get boolean
bool	streq()				# l: string compare
bool	ck_qpatt()
bool	ev_shift
bool	ck_none()
bool	ck_empty()

extern	def_finale()

include "qpcreate.com"

define	start_	99

begin
	otype = QPOE
	goto start_

entry a3d_create(argv) 
	otype = A3D
	goto start_

start_	call smark(sp)

	call salloc(timspec, SZ_EXPR, TY_CHAR)
	call salloc(qproot, SZ_PATHNAME, TY_CHAR)
	call salloc(tempname, SZ_PATHNAME, TY_CHAR)
	call salloc(key, SZ_KEY, TY_CHAR)
	call salloc(buf, SZ_PARAM, TY_CHAR)
	call salloc(posstring, SZ_LINE, TY_CHAR)

	evdef_blank = false
        ev_shift = false

	qphead = 0

	#----------------------------------------------
	# make sure we have a default event put for A3D
	#----------------------------------------------
	if (otype == QPOE)
	{
	  call qpc_load("qpoe", ".qp", 0, 0, 0, 0, F_OUT)
	}

	if (otype == A3D)
	{
	  call qpc_load("fits", ".fits", 0, 0, 0, 0, F_OUT)
	}

	#---------------------------------------------
	# load qp defaults if the input is a qpoe file
	# may override the def_noput routine
	#  but DON'T override an existing finale load
	#---------------------------------------------
	input_is_qpoe = false
	qpoe_list = false
	if (otype == QPOE)	
	{
#	   call printf("EXT_QPOE %s\n")
#		call pargstr(EXT_QPOE)
#	   call printf("QPC_EXT %s\n")
#		call pargstr(QPC_EXT(file,1) )
	   if ( stridxs(EXT_QPOE, QPC_EXT(file, 1)) > 0 )
	   {
	      if( grand_finale == 0 )
	          call qpc_finaleload(def_finale)
	      input_is_qpoe = true
	   }
	#  The 'qpoe_list' is the exact parameter input name from the
        #		QPAPPEND task.  This string must match that
	   if ( input_is_qpoe && streq("qpoe_list", QPC_PARAM(file, F_IN))  )
	   {
	      qpoe_list = true
	   }
	}
	# insufficient algorithm -- egm 4/95
	# there appears to be no reason why we can't check the
	# input for being QPOE is the output is not QPOE!
	if (otype == A3D){	
	   if ( stridxs(EXT_QPOE, QPC_EXT(file, 1)) > 0 )
	   {
	      input_is_qpoe = true
	   }
	}
### MC Force input QPOE format
#        input_is_qpoe = true

	#-------------------------------------------
	# make sure all drivers are loaded correctly
	#-------------------------------------------
	call qpc_loadcheck()

	#-----------------------------------
	# allocate space for the qpoe header 
	#-----------------------------------
	call calloc(qphead, SZ_QPHEAD, TY_STRUCT)

	#--------------------
	# get input file name
	#--------------------
	call clgstr(QPC_PARAM(file,F_IN), QPC_FILE(file,F_IN), SZ_LINE)

	#------------------------
	# make an input file name
	#------------------------
	call rootname("", QPC_FILE(file,F_IN), QPC_EXT(file,F_IN), SZ_LINE)

	#------------------------------------------
	# make sure we have a valid input file name
	#------------------------------------------
	if (streq(QPC_FILE(file,F_IN), "NONE"))
	{
	    call error(1, "requires a input file name")
	}

	#----------------------------------------------
	# if input_is_qpoe, make sure the file is there
	#----------------------------------------------
	if (input_is_qpoe)
	{
	    if (qpc_isqpoe(QPC_FILE(file,F_IN)) == NO)
	    {
		call errstr(1, "invalid input qpoe file", QPC_FILE(file,F_IN))
	    }
	}

	#---------------------
	# get header file name
	#---------------------
	if (QPC_OPEN(file, F_HD) != 0)
	{
	    call clgstr(QPC_PARAM(file,F_HD), QPC_FILE(file,F_HD), SZ_LINE)
	    call rootname(QPC_FILE(file,F_IN), QPC_FILE(file,F_HD),
			  QPC_EXT(file,F_HD), SZ_LINE)

	    #-------------------------------------------------
	    # use the event file for header, if NONE specified
            #-------------------------------------------------
	    if (ck_none(QPC_FILE(file,F_HD)))
	    {
		call strcpy(QPC_FILE(file,F_IN), QPC_FILE(file,F_HD), SZ_LINE)
	    }
	}
	else
	{
	    call strcpy("NONE", QPC_FILE(file,F_HD), SZ_LINE)
	}

	#------------------
	# get all aux files
	#------------------
	do i = (F_MAX+1), nfiles
	{
	    #---------------------------------
	    # get time file name, if necessary
	    #---------------------------------
	    if (QPC_OPEN(file,i) != 0)
	    {
		call clgstr(QPC_PARAM(file,i), QPC_FILE(file,i), SZ_LINE)
		call rootname(QPC_FILE(file,F_IN), QPC_FILE(file,i),
			      QPC_EXT(file,i), SZ_LINE)
	    }
	    else
	    {
		call strcpy("NONE", QPC_FILE(file,i), SZ_LINE)
	    }
	} # end loop

	#----------------------------------
	# get user parameters, if necessary
	#----------------------------------
	if (getparam != 0)
	{
	    call zcall2(getparam, QPC_FILE(file,F_IN), argv)
	}

	#----------------
	# get output file
	#----------------
	call clgstr(QPC_PARAM(file,F_OUT), QPC_FILE(file,F_OUT), SZ_LINE)

	#--------------------------
	# make the output file name
	#--------------------------
	call rootname(QPC_FILE(file,F_IN), QPC_FILE(file,F_OUT),
		      QPC_EXT(file,F_OUT), SZ_LINE)

	#------------------------------------
	# make sure we have a valid file name
	#------------------------------------
	if (ck_none(QPC_FILE(file,F_OUT)))
	{
	    call error(1, "requires a qpoe file name as output")
	}

	#-----------------------------------
	# get event definition (into common)
	#-----------------------------------
	call clgstr("eventdef", Memc[prosdef_out], SZ_TYPEDEF)
	
        #------------------------------
	# Check if prosdef_out is blank
	#------------------------------
	if (ck_none(Memc[prosdef_out]) || ck_empty(Memc[prosdef_out]))
	{
	   evdef_blank = true
	}

	clobber = clgetb ("clobber")
	call clobbername(QPC_FILE(file,F_OUT), Memc[tempname], clobber, 
			 SZ_PATHNAME)

	if (streq(QPC_FILE(file,F_IN), QPC_FILE(file,F_OUT)))
	{
	  call eprintf("WARNING: OUTPUT and INPUT file names are identical\n")
	  call eprintf("INPUT file will be deleted at completion of program\n")
	}

	display = clgeti("display")		
	if ((otype == QPOE && !input_is_qpoe) || (otype == A3D))
	{
		convert = clgeti("datarep")
	}

	#-------------------
	# Get qpoe internals
	#-------------------
	if (otype == QPOE)
	{
	   if (clgetb("qp_internals"))	
	   {
	      pagesize = clgeti("qp_pagesize")	
	      bucketlen = clgeti("qp_bucketlen")
	      block = clgeti("qp_blockfactor")	
	      mkindex = clgetb("qp_mkindex")	
	      if (mkindex)
	      {
		call clgstr("qp_key", Memc[key], SZ_KEY)
	      }
	      debug = clgeti ("qp_debug")		
	   }
	   else
	   {
	      pagesize = QPC_PAGESIZE
	      bucketlen = QPC_BUCKETLEN
	      block = QPC_BLOCKFACTOR
	      mkindex = QPC_MKINDEX
	      if (mkindex)
	      {
		call strcpy(QPC_KEY, Memc[key], SZ_KEY)
	      }
	      debug = QPC_DEBUG
	   }
	}

	#----------------------------------------------------
	# allocate a buffer to hold input file names for hist
	#----------------------------------------------------
	call salloc(files, nfiles, TY_POINTER)

	#--------------------------------------------------------
	# place pointers to the input file names into this buffer
	#--------------------------------------------------------
	Memi[files+0] = QPC_FPTR(file,F_IN)
	Memi[files+1] = QPC_FPTR(file,F_HD)

	do i = (F_MAX+1), nfiles
	{
	    Memi[files+i-(F_MAX+1)+2] = QPC_FPTR(file,i)
	}

	#-----------------------------------------------
	# open and read the header file first, if we can
	# example: XPR file
	#-----------------------------------------------
	if (QPC_OPEN(file,F_HD) != 0)
	{
	    if (!ck_none(QPC_FILE(file,F_HD)))
	    {
		call zcall5(QPC_OPEN(file,F_HD), QPC_FILE(file,F_HD),
			    hdrfd, convert, display, argv)
	    }
	    else
	    {
		call error(1, "must supply a header file")
	    }

	    #---------------------------------------------------------
	    # create a qpoe header structure and write it to qpoe file
            #---------------------------------------------------------
	    call zcall5(QPC_GET(file,F_HD), hdrfd, convert, qphead,
			display, argv)

	    #----------------------
	    # close the header file
	    #----------------------
	    call zcall4(QPC_CLOSE(file,F_HD), hdrfd, qphead, display, argv)
	}

        #-------------------------------------------------------------
	# open the input event file (will also get the header if input
	# is QPOE
	#-------------------------------------------------------------
	call zcall7(QPC_OPEN(file,F_IN), QPC_FILE(file,F_IN), eventfd, inrecs,
			convert, qphead, display, argv)

	#-------------------------------------------------------
	# if the header is on the event file, we can now read it
	# example: FITS file
	#-------------------------------------------------------
	if ((QPC_OPEN(file,F_HD) == 0) && (QPC_GET(file,F_HD) != 0))
	{
	    call amovi(eventfd, hdrfd, MAX_ICHANS)
	
	    #---------------------------------------------------------
	    # create a qpoe header structure and write it to qpoe file
	    #---------------------------------------------------------
	    call zcall5(QPC_GET(file,F_HD), hdrfd, convert, qphead,
			display, argv)
	}

        #----------------------------------------------------------------
	# If the input file is a QPOE then check to see if the "XS-EVENT"
	# string exists. If it does exist, then get the string.  If it 
	# doesn't exist, check to see if the IRAF string "EVENT" exists.
	# If the IRAF string exists, get it and	make an PROS definition 
	# string out of it.  If the IRAF string doesn't exist, it's a bad
	# QPOE file and a fatal error results.
	#----------------------------------------------------------------
	if (input_is_qpoe)
	{
	   if (qp_accessf(eventfd[1], "XS-EVENT") == YES)
	   {
#JCC (8/20/96) - replace SZ_LINE with SZ_TYPEDEF
              len = qp_gstr(eventfd[1],"XS-EVENT",Memc[prosdef_in],SZ_TYPEDEF)
	   }
	   else
	   {
	      if (qp_accessf(eventfd[1], "event") == YES)
              {
#JCC (8/20/96) - replace SZ_LINE with SZ_TYPEDEF
                 len = qp_gstr(eventfd[1], "event", Memc[irafdef_in],SZ_TYPEDEF)
		 call strlwr(Memc[irafdef_in])
		 call ev_create_names(Memc[irafdef_in], Memc[prosdef_in])
              }
	      else
	      {
                 call error(1, "No event definition found in the input QPOE")
	      }
	   }
	   #--------------------------------------------------------------
	   # If the event definition for the output QPOE is not entered as
	   # a parameter, default to the input QPOE defintion
	   #--------------------------------------------------------------
           if (evdef_blank)
	   {
              call strcpy(Memc[prosdef_in], Memc[prosdef_out], SZ_TYPEDEF)
	   }

	   #------------------
	   # Lower the strings
	   #------------------
	   call strlwr(Memc[prosdef_out])
	   call strlwr(Memc[prosdef_in])

	   #-------------------------
	   # Check/expand the aliases
	   #-------------------------
#JCC (8/20/96) - replace SZ_MACRO_STRING with SZ_TYPEDEF
           call ev_alias(Memc[prosdef_in], Memc[prosdef_in], SZ_TYPEDEF)
           call ev_alias(Memc[prosdef_out], Memc[prosdef_out],SZ_TYPEDEF)

	   #---------------------------------------------------------
	   # Parse the descriptors, compare them, and assign the argv 
	   # variables 
	   #---------------------------------------------------------
           call parse_descriptor(Memc[prosdef_in],in_ptr,in_sz_rec,in_cnt) 
           call parse_descriptor(Memc[prosdef_out],out_ptr,out_sz_rec,out_cnt) 

           call compare_descriptors(in_ptr, out_ptr, in_cnt, out_cnt)

           SWAP_CNT(argv) = out_cnt
           SWAP_PTR(argv) = out_ptr

	   #-------------------------------------------------------------
	   # If the display is "programmer level" display the descriptors
	   #-------------------------------------------------------------
	   if (display > 4)
	   {
	      call print_descriptor(in_ptr, in_cnt)
	      call print_descriptor(out_ptr, out_cnt)
	   }

#-----------------------------------------------------------------
# BLOCK MOVE CODE (IF DESIRED IN THE FUTURE)  
#-----------------------------------------------------------------
# 	This call will check if the input and output event macros 
# are the same or ordered subsets of each other. The intention is 
# to optimize the speed of the data moving inside the "def_get"
# call by doing a "block move".   
#
# (probably just an "amovs(in,out,rounded_size)", like was done
# for ALL cases of input/output in "def_get" in the past) 
#
# All the following call does is set the boolean "block_move" to 
# true or false.  To use it inside of the "def_get" routine, it 
# will have to be assigned to the "argv" structure.  This block
# move was not implemented within "def_get" because no degradation
# of performance/speed was observed without the block move in
# place.  
#-----------------------------------------------------------------
#
#	int	max_move
#	bool 	block_move
#
#       call block_move_check(in_ptr, out_ptr, in_cnt, out_cnt, 
#                              max_move, block_move)
#
#-----------------------------------------------------------------

	} # END if (input_is_qpoe)
	else
	{
#JCC (8/20/96) - replace SZ_MACRO_STRING with SZ_TYPEDEF
	   call ev_alias(Memc[prosdef_out], Memc[prosdef_out],SZ_TYPEDEF)
	}

	#-------------------------------------
	# strip a pros def to get the iraf def
	#-------------------------------------
        call ev_strip(Memc[prosdef_out], Memc[irafdef_out], SZ_TYPEDEF, qphead)
	
	#----------------------------
	# create a list of the macros
	#----------------------------
        call ev_crelist(Memc[prosdef_out], msymbols, mvalues, nmacros)

	#----------------------------
	# get the size of the irafdef
	#
	#----------------------------
	call ev_size(Memc[irafdef_out], oevsize)
        oevsize = oevsize/SZ_SHORT

	#-------------------------------------------------------------
	# set size of record we are dealing with, padded for alignment
	#-------------------------------------------------------------
        call qpc_roundup(oevsize, revsize)

	#-------------------------------------------------------------
	# Now that we have a QPOE header, deal with sort string
	#-------------------------------------------------------------
	call get_sort_params(sort, sortsize, Memc[sortstr], qphead)

	#-------------------------------------------------------------
	# Make position sort string for comparison.
	#-------------------------------------------------------------		
	call sprintf(Memc[posstring],SZ_LINE,"%s %s")
	 call pargstr(QP_INDEXY(qphead))
	 call pargstr(QP_INDEXX(qphead))

	#---------------------------------------------------------------
	# if the sort is not by position, don't make an index regardless
	# of what the user says
	#---------------------------------------------------------------
	if (!streq(Memc[sortstr],Memc[posstring]) &&
		 !streq(Memc[key],"") && !streq(Memc[key],Memc[posstring]))
	{
	  if( mkindex)
	  {
               call eprintf("WARNING: Can't make index unless doing a position\n") 
	       call eprintf("sort - proceeding without index\n")
	  }
	  mkindex = FALSE
	}


	if (input_is_qpoe)
	{
	out_ev = EV_NEITHER
	in_ev = EV_NEITHER

	IN_F_TO_L(argv) = false
	IN_L_TO_F(argv) = false

	#------------------------
	# get the instrument name
	#------------------------
	call salloc(instrument, SZ_LINE, TY_CHAR)
	if (qp_accessf(eventfd[1], "INSTRUME") == YES)
	{
           len = qp_gstr(eventfd[1], "INSTRUME", Memc[instrument], SZ_LINE)
	   call strupr(Memc[instrument])
	}
	else
	{
	  call strcpy("UNKNOWN", Memc[instrument], SZ_LINE)
	}

	#--------------
	# check if PSPC
	#--------------
	if (strncmp ("PSPC", Memc[instrument], 4) == 0)
	{
	   if (streq(Memc[prosdef_out], PROS_LARGE))
	      out_ev = EV_LARGE

	   if (streq(Memc[prosdef_out], PROS_FULL))
	      out_ev = EV_FULL

	   if (streq(Memc[prosdef_in], PROS_LARGE))
	      in_ev = EV_LARGE

	   if (streq(Memc[prosdef_in], PROS_FULL))
	      in_ev = EV_FULL

	   #-----------------------------------------------------
	   # set large_to_full or full_to_large boolean variables
	   #-----------------------------------------------------
	   if (in_ev == EV_LARGE && out_ev == EV_FULL)
	      IN_L_TO_F(argv) = true

	   if (in_ev == EV_FULL && out_ev == EV_LARGE)
              IN_F_TO_L(argv) = true

	   if (IN_F_TO_L(argv) || IN_L_TO_F(argv))
	   {
	      ev_shift = true 

	      call ev_strip(Memc[prosdef_in],Memc[irafdef_in],SZ_TYPEDEF,qphead)

	     call ev_crelist(Memc[prosdef_in],in_msymbols,in_mvalues,in_nmacros)
	      call ev_size(Memc[irafdef_in], in_oevsize)
	      in_oevsize = in_oevsize/SZ_SHORT

              #--------------------------------------
	      # set output prosdef_out symbols and values
	      #--------------------------------------
	      IN_MSYM(argv) = in_msymbols
	      IN_MVAL(argv) = in_mvalues
	      IN_MNUM(argv) = in_nmacros

	      #---------------------------------------------------
	      # call the initialization routine to set up the argv
	      # variables
	      #---------------------------------------------------
	      call def_init_shift(msymbols, mvalues, nmacros, argv)
	   }
	} # if instrument is PSPC
	} # if input_is_qpoe ( input )

	#---------------------
	# open a new qpoe file
	#---------------------
	if (otype == QPOE)
	{
	   if (input_is_qpoe && !qpoe_list )
	   {
	      if ((streq(Memc[sortstr], "time"))        && 
		  (qp_accessf(eventfd[1], "TIME")== NO) &&
		  (qp_accessf(eventfd[1], "time")== NO)) 
	      {
		 call eprintf("unable to time sort\n")
		 call error(QPC_FATAL,"TIME does not exist in input QPOE file")
	      }
	      call qpc_copyqp(Memc[tempname], eventfd[1], qphead, qp)
	   }
	   else # an APPENDED list of QPOEs must be copied from scratch
	   {
	      call qpc_creqp(Memc[tempname], pagesize, bucketlen, debug, qp)
	   }
		
	   #-----------------------------
	   # set the default block factor
           #-----------------------------
	   call qpc_defblock(qp, block)

	   #---------------------------------
	   # write the qpoe and pros versions
           #---------------------------------
	   call qpc_version(qp, display)

	   #---------------------------------------------------
	   # write the macros for each data in the event struct
	   #---------------------------------------------------
	   call ev_wrlist(qp, msymbols, mvalues, nmacros)

	   #-------------------------------------------------------
	   # if this is not a copy, we must write header parameters
           #-------------------------------------------------------
	   if (!input_is_qpoe || qpoe_list )
	   {
	      #-------------------------------
	      # write the standard QPOE header
	      #-------------------------------
	      call qpc_wrheadqp(qp, qphead, display)

	      #-----------------------------
	      # write the X-ray uhead params
	      #-----------------------------
	      call put_qphead(qp, qphead)
	  }

	} # end "if (otype == QPOE)"

	#-------------------------------------------------------
	# see if we need to add regions to the output event list
        #-------------------------------------------------------
	call qpc_initregion(qp, msymbols, nmacros)

	#---------------------------
	# open the new A3D FITS file
	#---------------------------
	if (otype == A3D)    #JCC-output file type is FITS
	{
	   qp = open (Memc[tempname], NEW_FILE, BINARY_FILE)
	   
	   #-----------------------------------------------
	   # dummy the standard FITS header to the A3D file
           #-----------------------------------------------
	   call a3d_main_header(qp, "EVENTS")

	   #---------------------
	   # write history record
           #---------------------
	   if (hist != 0)
	   {
	      call zcall6(hist, qp, QPC_FILE(file,F_OUT), Memi[files],
			  qphead, display, argv)
	   }

	  #--------------------------------
	  # write last card, and blank fill
	  #--------------------------------
	  call a3d_main_end(qp)
	}

	#-------------------------------------------------------------
	# if "sort" is YES, build the array of sort compare routines 
	# and read/write information stored in qpcreate db
	# else if the input is QPOE, maintain the sort type from the 
	# input file
	#-------------------------------------------------------------
	if (sort == YES)
	{
	    call qpc_buildsort(qp)
	}
	else 
	{
	   if( input_is_qpoe )
	   {
	      call qpc_oldsort(eventfd[1]) # This updates sortstr
	      if (!streq(Memc[sortstr],Memc[posstring])) 
	      {
		if( mkindex )
	         call eprintf("WARNING: Can't make an index for non-position sorted file - proceeding without index\n")
	        mkindex = FALSE
	      }
	   }
	}

	#----------------------
	# process the aux files
	#----------------------
	do i = (F_MAX + 1), nfiles
	{
	    #-------------------------
	    # open the input time file
	    #-------------------------
	    if (QPC_OPEN(file,i) != 0)
	    {
		if (!ck_none(QPC_FILE(file,i)))
		{
		    call zcall6(QPC_OPEN(file,i), QPC_FILE(file,i), auxfd,
			        convert, qphead, display, argv)
		}
		else
		{
		    #--------------------
		    # flag no aux records
		    #--------------------
		    auxfd[1] = -1
		}
	    }
	    else
	    {
		#--------------------------------------------------
		# assume we are using the input file as an aux file
		#--------------------------------------------------
		call amovi(eventfd, auxfd, MAX_ICHANS)
	    }

	    #--------------------------------------------------------------
	    # get aux records, if we have an aux file (could be input file)
            #--------------------------------------------------------------
	    if (auxfd[1] != -1)
	    {
		if (QPC_GET(file,i) != 0)
		{
		    call zcall7(QPC_GET(file,i), auxfd, convert, qpaux,
			        naux, qphead, display, argv)
		}
	    }
	    else
	    {
		naux = 0
	    }

	    #------------------------------------------------------------
	    # write the aux params - we might write 0 records (if "NONE")
	    #------------------------------------------------------------
	    if (QPC_PUT(file,i) != 0)
	    {
		call zcall6(QPC_PUT(file,i), qp, qpaux, naux, qphead,
			    display, argv)
	    }

	    #----------------------------
	    # close time file (if opened)
            #----------------------------
	    if ((auxfd[1] != -1) && (auxfd[1] != eventfd[1]) &&
		(QPC_CLOSE(file,i) != 0))
	    {
		call zcall4(QPC_CLOSE(file,i), auxfd, qphead, display, argv)
	    }

	    call mfree(qpaux, TY_STRUCT)
	}


	#------------------------------------
	# create the event list (photon list)
	#------------------------------------
	if (otype == QPOE)
	{
	  call qpc_opnev(qp, Memc[irafdef_out], io)
	}

	if (otype == QPOE)    #JCC- output file type is QPOE
	{
           #----------------------------------------
           # create and write out the events to qpoe
           #----------------------------------------
	   call qpc_write(QPC_GET(file,F_IN), eventfd, io,
			  convert, qphead, display, argv)

	   #-----------------------------------
           # write out sort type and event size 
           #-----------------------------------
           call qpc_sortparam(qp)
#JCC-temporary
           call ev_qpput(qp, Memc[prosdef_out])
	
	   #---------------------
           # write history record
	   #---------------------
           if (hist != 0)
	   {
              call zcall6(hist, qp, QPC_FILE(file,F_OUT), Memi[files],
                          qphead, display, argv)
	   }
	}
	else
	{
	   #--------------------------------
	   # create and write events to fits
	   #--------------------------------
	   if (otype == A3D)  #JCC- output file type is FITS
	   {
	     call qpc_write(QPC_GET(file,F_IN), eventfd, qp,
			    convert, qphead, display, argv)
	   }
	}

	#---------------------------------------------------------------------
	# UPDATE the GTI's when a QPOE is copied with a time filter
        #	When copying QPOE to QPOE the GTI's were copied automatically
	#	with the inheritance flag
	# This block of code up to 'put_qpgti' should become a routine:
	#	get_qpfilt(eventfd,timspec,display,qpgti,naux)
	# DO THIS LAST so that DEFFILT can be turned off if needed by
	#	calling task ( APPLY_BARY and QPAPPEND in particular )
	# read time filter and update the GTI records, using filter
        #---------------------------------------------------------------------
	if (input_is_qpoe && otype == QPOE)
	{
	    call qpparse(QPC_FILE(file,F_IN), Memc[qproot], SZ_PATHNAME, 
			 Memc[timspec], SZ_EXPR)
	    nodeffilt = qp_stati(qp,QPOE_NODEFFILT)
	    if (nodeffilt == NO)
	    {
	  	#---------------------------------------------------------
	        # Check that 'time' is an attribute in the input QPOE file
		#---------------------------------------------------------
		call strcpy("time",Memc[buf],SZ_PARAM)
                if (ck_qpatt(eventfd[1],Memc[buf]) && ck_qpatt(qp,Memc[buf]) )
		{
		    call updeffilt(eventfd[1],qp,timspec,"deffilt",qphead)
		    call qpc_wrheadqp1(qp)
		}
	        else
		    call updeffilt(eventfd[1],qp,timspec,"XS-FHIST",qphead)
	    }
	}
	#------------------------------------------------
	# do something for the grand finale, if necessary
	#------------------------------------------------
	if (grand_finale != 0)
	{
	    call zcall7(grand_finale, eventfd, qp, io, convert,
			qphead, display, argv)
	}


	#---------------------------
	# close the input event file
	#---------------------------
	call zcall4(QPC_CLOSE(file,F_IN), eventfd, qphead, display, argv)

	#------------------------------------
	# sort the event list and close it up
	#------------------------------------
	if (otype == QPOE)
	{
	   call qpc_clsev(io, mkindex, Memc[key])
	}

	#----------
	# finish up
	#----------
	if (otype == QPOE)
	{
	  call qpc_closeqp(qp)
	}
	else
	{
	  call close(qp)
	}

	if (display >= 1)
	{
	    if (otype == QPOE)
	    {
	        call printf("Creating QPOE output file: %s\n")
                call pargstr(QPC_FILE(file,F_OUT))
	    }
	    else
	    {
	        call printf("Creating A3D FITS output file: %s\n")
                call pargstr(QPC_FILE(file,F_OUT))
	    }
	}

        #------------------------------------
        # rename the output file if necessary
        #------------------------------------
	call finalname(Memc[tempname], QPC_FILE(file,F_OUT))

	#------------------------
	# free up the qpoe header
	#------------------------
	call mfree(qphead, TY_STRUCT)

	#-----------------------------------
	# destroy the macro names and values
	#-----------------------------------
	call ev_destroylist(msymbols, mvalues, nmacros)

	#---------------------------
	# Free the descriptor memory 
	#---------------------------
        call free_descriptor(in_ptr, in_cnt)
        call free_descriptor(out_ptr, out_cnt)

	#---------------------------------------------------------------
	# if events were shifted, space for the output event macros were 
	# created with "ev_crelist" and must now be freed
	#---------------------------------------------------------------
        if (ev_shift)
	{
	   call ev_destroylist(in_msymbols, in_mvalues, in_nmacros)
	}

	#---------------------------
	# destroy the sort structure
	#---------------------------
	if (sort == YES)
	{
	    call qpc_destroysort()
	}

	#-----------
	# stack free
	#-----------
	call sfree(sp)
end
