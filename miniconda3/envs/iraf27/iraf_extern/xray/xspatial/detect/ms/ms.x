# $Header: /home/pros/xray/xspatial/detect/ms/RCS/ms.x,v 11.0 1997/11/06 16:32:38 prosb Exp $
# $Log: ms.x,v $
# Revision 11.0  1997/11/06 16:32:38  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:52:02  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  15:14:28  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:35:26  prosb
#General Release 2.3
#
#Revision 6.1  93/07/02  14:38:36  mo
#MC	7/2/93		Update integer function usage to not test for bool
#
#Revision 6.0  93/05/24  16:19:55  prosb
#General Release 2.2
#
#Revision 1.1  93/05/13  12:06:42  janet
#Initial revision
#
#
# Module:	ms.x
# Project:	PROS -- ROSAT RSDC
# Purpose:	
# Description:	Match Sources computes the distance between detections
#               in an input source list and makes a match when the distance
#		is within a set tolerance.  If there a more than one match
#		for a detection, then it is matched with the source with the
#		closest distance.  An output table indicating the matches is
#		written.
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989.  You may do anything you like with this
#		file except remove this copyright
# Modified:	{0} JD - initial version - 4/93
#		{n} <who> -- <does what> -- <when>
#
# --------------------------------------------------------------------------
include  <tbset.h>
include  <ext.h>
include  <fset.h>
include  "ms.h"

procedure t_ms()

pointer buff			# temp name buffer
pointer icolptr[20]		# input table column pointer storage
pointer ocolptr[20]		# input table column pointer storage
pointer list			# node pointer
pointer mtch_list		# output table file name
pointer new			# new node to match
pointer	sp			# space allocation pointer
pointer src_list		# file to match to
pointer tempname                # temp table file name
pointer itp, otp		# input/output tab file pointer
pointer qpname                  # qpoe file name
pointer im, imw			# file handles
pointer ict			# wcs pointer
pointer qproot, ks, is		# qpoe name pointers

int     display			# display level
int     i			# loop counters
int     max_match		# composite region with the most matches
int	num_srcs		# number of input sources

real    err_fact		# unique error factor

bool    clobber			# indicates whether to overwrite out file
bool    overide			# indicates whether to overide use of errors 

bool    ck_none()		# check for none as input name
bool	clgetb()		# retrieve a bool from par file
int     clgeti()		# retrieve an integer from par file
int     cl_index, cl_size       # l: name parsing counters
int     tbpsta()               	# table function
int     qpc_isqpoe()		# check that input is a qpoe
pointer tbtopn()               	# table open function
pointer immap()			# image file open
pointer mw_openim()		# wcs open
pointer mw_sctran()		# retreive wcs handle
real    clgetr()		# retrieve a real from par file
bool    streq()

begin

        call fseti (STDOUT, F_FLUSHNL, YES)

#   Allocate space for arrays
        call smark  (sp)
        call salloc (buff,      SZ_LINE,     TY_CHAR)
        call salloc (mtch_list, SZ_PATHNAME, TY_CHAR)
        call salloc (qpname,    SZ_PATHNAME, TY_CHAR)
        call salloc (qproot,    SZ_PATHNAME, TY_CHAR)
        call salloc (is,        SZ_FNAME,    TY_CHAR)
        call salloc (ks,        SZ_FNAME,    TY_CHAR)
        call salloc (src_list,  SZ_PATHNAME, TY_CHAR)
        call salloc (tempname,  SZ_PATHNAME, TY_CHAR)

#    Open the Qpoe file for reading, we use the wcs to determine ra &
#    dec of the pixel position.  It also reinforces the requirement that
#    all input position tables are the result of running detect on the
#    same qpoe.
      	call clgstr ("qpoe", Memc[qpname], SZ_PATHNAME)
      	call rootname (Memc[qpname], Memc[qpname], EXT_QPOE, SZ_PATHNAME)
      	if ( qpc_isqpoe(Memc[qpname])==NO ) {
           call error (1,"Input QPOE file not Accessible!!")
      	}
      	im = immap (Memc[qpname], READ_ONLY, 0)
      	imw = mw_openim(im)
      	ict = mw_sctran(imw, "logical", "world", 3B)

#  Input Detection File:  Retrieve name & open the table file for reading
	call clgstr ("src_list", Memc[src_list], SZ_PATHNAME)
        call rootname("", Memc[src_list], EXT_TABLE, SZ_PATHNAME)
        if ( ck_none (Memc[src_list]) ) {
           call error (1, "requires *.tab file as input")
        }
        itp = tbtopn (Memc[src_list], READ_ONLY, 0)
        if ( tbpsta (itp, TBL_NROWS) <= 0 ) {
           call error (1, "Table File empty!!")
        }

#   Initialize the table and Retrieve the number of rows 
        call init_srctab (itp, icolptr, num_srcs)

#  Error checking ... table header param 'QPOE' must exist and match name
#  of reference qpoe.  This is a minimal test, cause when the input tables
#  are appended, only the qpoe in the last table is saved in the header.
        iferr ( call tbhgtt (itp, "QPOE", Memc[buff], SZ_LINE) ) {
	      call printf ("Qpoe name in input table header not found")
	      call printf ("Note: Qpoe reference for ldetect and match sources must be the same file\n")
        } else {
           call imparse (Memc[buff], Memc[qproot], SZ_PATHNAME, Memc[ks],
                         SZ_FNAME, Memc[is], SZ_FNAME, cl_index, cl_size)

	   if ( !streq (Memc[qpname], Memc[qproot]) ) {
              call printf ("\n*** Warning ***\n")
	      call printf ("Input Qpoe filename and Qpoe name in Srclist table header do not match!!\n")
              call printf ("%s, %s -- This task requires that they match!! \n")
                call pargstr (Memc[qpname])
                call pargstr (Memc[qproot])
              call printf ("*** Warning ***\n\n")
	  }
	}

#  Output Match File:  Retrieve name & open the table file for writing
	clobber = clgetb("clobber")
        call clgstr ("matchlist", Memc[mtch_list], SZ_PATHNAME)
        call rootname("", Memc[mtch_list], EXT_TABLE, SZ_PATHNAME)
        if ( ck_none (Memc[mtch_list]) ) {
           call error (1, "requires *.tab file as input")
        }
        call clobbername(Memc[mtch_list], Memc[tempname], clobber, SZ_PATHNAME)
        otp = tbtopn (Memc[tempname], NEW_FILE, 0)

        err_fact = clgetr ("err_factor")
        overide  = clgetb ("overide")
        display  = clgeti ("display") 

#   Initialize the node
     	list = 0
        max_match = 0

#   Loop through the Sources
     	do i = 1, num_srcs {

#   ... Assign the input data to a Node
           call get_node (itp, icolptr, i, overide, new)

#   ... Make the Match
           call matchit (new, list, err_fact, i, max_match, overide, display)
     	}

#   ... and output the results
        call init_matchtab (otp, ocolptr, max_match, display)

        call ms_results (ict, list, otp, ocolptr, display)

        call wr_mhead (otp, display, Memc[src_list], Memc[qpname])

#    Close files
        call tbtclo(itp)
        call tbtclo(otp)

        call finalname (Memc[tempname], Memc[mtch_list])
        if ( display > 0 ) {
           call printf ("\nWriting to Match Results table:  %s\n")
             call pargstr (Memc[mtch_list])
	}

end
