#$Header: /home/pros/xray/lib/vvms/RCS/timfilter.x,v 11.0 1997/11/06 16:25:34 prosb Exp $
#$Log: timfilter.x,v $
#Revision 11.0  1997/11/06 16:25:34  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:32:19  prosb
#General Release 2.4
#
#Revision 1.2  1995/08/24  15:21:16  prosb
#JCC - Updated for VAX version.
#
#Revision 1.1  1995/08/08  15:02:05  prosb
#Initial revision
# JCC - copied from /pros/xray/xtiming/timfilter/timfilter.x & modified for
#     - VAX/VMS version.
#     - (./xray/xtiming/timfilter/timfilter.x - Rev8.0,94/06/27 - pros2.3.1)
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
	   fd = open (Memc[tempname], NEW_FILE, TEXT_FILE)
#	   fd = open (Memc[tempname], WRITE_ONLY, TEXT_FILE)
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
           call close(fd)
	}

	call mfree (gbegs, TY_DOUBLE)
	call mfree (gends, TY_DOUBLE)
	call sfree (sp)
end
