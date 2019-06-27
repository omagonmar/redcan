#$Header: /home/pros/xray/xtiming/timfilter/RCS/timfilter.x,v 11.0 1997/11/06 16:45:00 prosb Exp $
#$Log: timfilter.x,v $
#Revision 11.0  1997/11/06 16:45:00  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:34:44  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:41:59  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:02:40  prosb
#General Release 2.3
#
#Revision 6.1  93/07/02  14:59:55  mo
#MC	7/2/93		Remove redundant == TRUE (RS6000 port)
#
#Revision 6.0  93/05/24  16:58:50  prosb
#General Release 2.2
#
#Revision 5.1  93/05/20  10:26:20  janet
#jd - bugfix to accept a NONE as an input.
#
#Revision 5.0  92/10/29  23:05:28  prosb
#General Release 2.1
#
#Revision 4.1  92/09/30  16:06:06  mo
#MC	9/28/92		Updated calling sequence to use gbegs and gends
#			instead of 2 dimensional gintvs
#
#Revision 4.0  92/04/27  15:35:35  prosb
#General Release 2.0:  April 1992
#
#Revision 3.5  92/04/23  17:46:09  janet
#removed filter param amd added filtering to qpoe input file name.
#
#Revision 3.4  92/04/21  12:00:13  janet
#investigating differences with sun/vax open of ascii files.
#
#Revision 3.3  92/04/06  16:52:00  mo
#MC	4/6/92		Replace output file open/WRITE_ONLY with open/NEW_FILE
#			since the former doesn't work under VMS
#
#Revision 3.2  92/04/06  16:51:07  mo
#MC	4/6/92		Add a format specifier to the output_gtis call
#			which now requires it
#
#Revision 3.1  92/03/06  15:01:27  mo
#MC	Jan 92		Update with new PROS library routine get_gdtimes
#			to replace previous get_goodtimes
#
#Revision 3.0  91/08/02  02:02:09  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  22:49:10  pros
#General Release 1.0
#
# -------------------------------------------------------------------------
# Module:	timfilter
# Project:	PROS -- ROSAT RSDC
# Purpose:	display and write filtered good time intervals
# Description:	
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1990.  You may do anything you like with this
#		file except remove this copyright
# Modified:	{0} Janet DePonte initial version  August 1990
#		{n} <who> -- <does what> -- <when>
#
# -------------------------------------------------------------------------
include  <qpset.h>
include  <qpioset.h>
include  <qpoe.h>
include  <ext.h>
include  <fset.h>
include  "timfilter.h"

procedure  t_timfilter()

bool     clobber		# clobber old file
bool     merge                  # merge time filters ? (t/f)
bool     mklst                  # make ascii output list

int      num_gintvs		# number of good time intvs
int      display                # display level (0-5)

pointer  evlist
pointer  fd			# ascii out file pointer
#pointer  filter                 # qpoe gti filter
pointer  sp                     # stack pointer
pointer  gbegs			# good time intervals
pointer  gends			# good time intervals
pointer  qpfile                 # name of input file
pointer  qproot			# root name of qpoe file
pointer  tempname               # temp name of output file
pointer  qp			# qpoe in file pointer
pointer  qphead                 # qpoe header pointer
pointer  tofile			# output ascii filename 

double   duration               # length of gintvs
#double	 get_goodtimes()


bool	 clgetb()				
#bool	 streq()
bool     ck_none()
pointer  qp_open()
int	 clgeti()
int      open()

begin

        call fseti (STDOUT, F_FLUSHNL, YES)

	call smark (sp)
	call salloc (evlist,   SZ_EXPR, TY_CHAR)
#	call salloc (filter,   SZ_LINE, TY_CHAR)
	call salloc (qpfile,   SZ_PATHNAME, TY_CHAR)
	call salloc (qproot,   SZ_PATHNAME, TY_CHAR)
	call salloc (tempname, SZ_PATHNAME, TY_CHAR)
	call salloc (tofile,   SZ_PATHNAME, TY_CHAR)

#	call clgstr (FILTER, Memc[filter], SZ_LINE) 
#	if (!streq("", Memc[filter]) ) {
#	   call error(1, "filters other than NULL not currently accepted")
#       }
	merge = clgetb(MERGE)
	display = clgeti(DISPLAY)
	clobber = clgetb(CLOBBER)
	
#   Get input QPOE filename
	call clgstr (QPFNAME, Memc[qpfile], SZ_PATHNAME)
  	call rootname(Memc[qpfile],Memc[qpfile],EXT_QPOE,SZ_PATHNAME)
        if ( ck_none(Memc[qpfile]) ) {
	   call error(1, "requires *.qp file as input")
        }
        call qpparse (Memc[qpfile], Memc[qproot], SZ_PATHNAME,
                      Memc[evlist], SZ_EXPR)

	qp = qp_open (Memc[qproot], READ_ONLY, NULL)
	call get_qphead(qp, qphead)

#   Get output ASCII filename
	mklst = true
	call clgstr (TIMOUTNAME, Memc[tofile], SZ_PATHNAME)
        if ( ck_none(Memc[tofile]) ) {
	   mklst = false
        }

        if ( display > 0) {
          call printf ("\nReading from Qpoe file: %s\n")
          call pargstr (Memc[qpfile])
        }

        if (mklst) {
  	   call rootname(Memc[qpfile],Memc[tofile],".lis", SZ_PATHNAME)
           call clobbername(Memc[tofile],Memc[tempname],clobber,SZ_PATHNAME)
#  First works on VAX, second works on Sun,  need to fix
#	   fd = open (Memc[tempname], NEW_FILE, TEXT_FILE)
	   fd = open (Memc[tempname], WRITE_ONLY, TEXT_FILE)
           if ( display > 0) {
              call printf ("Writing to Time Filter list: %s\n")
              call pargstr (Memc[tofile])
           }
	}


#   Retrieve the good time intervals from the qpoe file
#	call get_gdtimes (qp, Memc[filter], gintvs, num_gintvs, duration)
	call get_goodtimes (qp, Memc[evlist], display, gbegs, gends,
                            num_gintvs, duration)

	if ( display >= 3 ) {
	   call printf ("# Gintvs = %d, Duration = %14.3f\n")
	     call pargi (num_gintvs)
	     call pargd (duration)
	}

#  2 decimal places is enough precision for this output ( %.2f)
	call output_gtis (Memd[gbegs], Memd[gends], num_gintvs, "%.2f", 
			  display, fd, merge, mklst)

	call qp_close (qp)
	
	if (mklst) {
 	   call finalname (Memc[tempname], Memc[tofile])
	}

	call mfree (gbegs, TY_DOUBLE)
	call mfree (gends, TY_DOUBLE)
	call sfree (sp)
end
