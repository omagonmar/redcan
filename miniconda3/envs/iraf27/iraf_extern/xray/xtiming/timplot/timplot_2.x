#$Header: /home/pros/xray/xtiming/timplot/RCS/timplot_2.x,v 11.0 1997/11/06 16:44:51 prosb Exp $
#$Log: timplot_2.x,v $
#Revision 11.0  1997/11/06 16:44:51  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:34:23  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:41:17  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:02:07  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:58:13  prosb
#General Release 2.2
#
#Revision 5.2  93/05/20  10:31:17  janet
#jd - restructured main program, added set up subroutine.
#
#Revision 5.1  92/12/18  10:09:28  janet
#changed internal storage and use of BINLEN to double.
#
#Revision 5.0  92/10/29  22:49:44  prosb
#General Release 2.1
#
#Revision 4.1  92/09/28  17:03:58  janet
# change phase from 0-360 to 0-1.
#
#Revision 4.0  92/06/26  14:22:33  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  92/06/17  11:21:26  janet
#added PHASE plot option.
#
#Revision 3.0  91/08/02  02:02:43  prosb
#General Release 1.1
#
#Revision 2.1  91/07/21  14:25:50  janet
#added quit message.
#
#Revision 2.0  91/03/06  22:51:44  prosb
#General Release 1.0
#
# ---------------------------------------------------------------------------
# Module:	TIMPLT.X
# Project:	PROS -- ROSAT RSDC
# Purpose:	Task to plot timing data from table input
# Description:
# Copyright:	Property of Smithsonians Astrophysical Observatory
# 		1989.  You may do anything you like to this file 
#		except remove this copyright
# Modified:     {0} Janet DePonte inital version  Jul 1989 
#		{1} -- JD -- Oct 1991 -- updated x axis for chisq plot to
#                                        read perincr for binlen and bst_per 
#                                        for offset.
#		{2} -- JD -- Dec 1991 -- added phase plot
#		{3} -- JD -- Jul 1992 -- change phase from 0-360 to 0-1
#		{4} -- JD -- Dec 1992 -- change internal storage and use of
#					 BINLEN to double.
#		{5} -- JD -- Dec 1992 -- restructured main program, added 
#					 setup subrouitnes.
#
# ---------------------------------------------------------------------------

include  <mach.h>
include  <tbset.h>
include  <gset.h>
include  <ext.h>
include  "timplot.h"

procedure  t_timplot ()

bool     cgraph                 # indicates if graph windo gets closed
bool     ebar			# error bars (y/n)

pointer  const			# constant struct pointer
pointer  ecol			# error col pointer
pointer  ecolumn		# error column name
pointer	 gp			# graphics device handle 
pointer  limits			# limits struct pointer
pointer  buff			# parameter input buffer
pointer  sp			# space allocation ptr
pointer  tbl_fname		# table file name fro input data
pointer  tp			# table handle
pointer  xaxis			# x-axis units
pointer  xlabel			# x-axis label 
pointer  ylabel			# y-axis label 
pointer  ycol			# ypos col pointer
pointer  ycolumn		# ydata column name

int      i                      # loop counter
int	 key			# keystroke returned from clgcur
int	 pltype			# plot type indicator
int      wcs			# world coords for clgcur

real     wx, wy			# position reutrned from clgcur
real	 xlims[2]		# X-axis min & max
real	 ylims[2]		# Y-axis min & max

bool     ck_empty()		# check for empty string
bool 	 ck_none()		# check for none string
bool	 clgetb()		# cl get boolean param function
pointer  tbtopn()		# table open function
int	 tbpsta()		# table function
int      clgcur()               # retrieve cursor position from graphics
real     clgetr()		# cl get real param function

begin

#   Allocate space for arrays
	call smark(sp)
	call salloc (ecolumn, SZ_LINE, TY_CHAR)
	call salloc (buff, SZ_LINE, TY_CHAR)
	call salloc (xaxis, SZ_LINE, TY_CHAR)
	call salloc (xlabel, SZ_LINE, TY_CHAR)
	call salloc (ylabel, SZ_LINE, TY_CHAR)
	call salloc (ycolumn, SZ_LINE, TY_CHAR)
	call salloc (tbl_fname, SZ_PATHNAME, TY_CHAR)
	call malloc (const, LEN_CONST, TY_STRUCT)
	call malloc (limits, LEN_LIMITS, TY_STRUCT)

#  Table File:  Retrieve name & open the file 
	call clgstr (TBLFILENAME, Memc[tbl_fname], SZ_PATHNAME)
	call rootname("", Memc[tbl_fname], EXT_TABLE, SZ_PATHNAME)
	if ( ck_none(Memc[tbl_fname]) | ck_empty(Memc[tbl_fname]) ) {
	   call error (1, "requires *.tab file as input")
	}
	tp = tbtopn (Memc[tbl_fname], READ_ONLY, 0)
	if ( tbpsta (tp, TBL_NROWS) <= 0 ) {
	   call error (1, "Table File empty!!")
	}

#   Retrieve the number of rows from table
	NUMBINS(const) = tbpsta (tp, TBL_NROWS)

#   Setup x-axis units and constants
        call xaxis_setup (const, tp, Memc[xlabel])

#   Plot Type: Histogram or connected points
        call ptype_setup (pltype)

#   Plot data:  Retrieve Histo name and init column pointer
        call pdata_setup (tp, Memc[ycolumn], ycol, Memc[ylabel])

#   Error bars:  optional with histogram  - retrieve error column name 
#					    & init pointer
	call edata_setup (tp, Memc[ecolumn], ecol, ebar)

#   Retrieve rest of parameters from user
        cgraph = clgetb (GRQUIT)
	NUM_PLOTS(const) = clgetr(NUMPLOTS)
	XTICS(const) = clgetr (NUMXTICS)
	YTICS(const) = clgetr (NUMYTICS)
	LABSIZE(const) = clgetr (LABEL_SIZE)
	TICSIZE(const) = clgetr (TIC_SIZE)

#   Get X & Y axis limits
	call tim_xaxlims (tp, const, limits, xlims)
	call tim_yaxlims (tp, ebar, Memc[ycolumn], Memc[ecolumn], ylims)

#    Flush print buffers before graphics is opened
        call flush (STDOUT)

#   Init graphics device and set plot constants and limits
        call tim_ginit(gp, const, limits)

#   Label the plot with a header and X & Y axis identifiers
	call tim_labels (gp, tp, Memc[tbl_fname], Memc[xlabel], 
                         Memc[ylabel], const)

#   Plot the data 
	call tim_mkplt (gp, tp, ecol, ycol, const, limits, ebar,
			pltype, xlims, ylims)

        call gflush(gp)
	if ( !cgraph ) {
           do i= 1, 30 {
             call printf ("\n")
           }
           call printf ("TYPE 'q' to QUIT\n")
	   while (clgcur("cursor",wx,wy,wcs,key,Memc[buff],SZ_LINE) != EOF) {
		if ( key == 'q') {
		   break
		}
	   }
	}
 	call gclose (gp)
	call tbtclo (tp)
	call sfree(sp)

end
