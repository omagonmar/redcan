# $Header: /home/pros/xray/xtiming/timplot/RCS/timsetup.x,v 11.0 1997/11/06 16:44:52 prosb Exp $
# $Log: timsetup.x,v $
# Revision 11.0  1997/11/06 16:44:52  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 19:34:24  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  17:41:20  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:02:09  prosb
#General Release 2.3
#
#Revision 6.1  93/07/02  15:02:01  mo
#Mc	7/2/93	Correct int->double converstion from double to dfloat
#		and remove redundant == TRUE
#
#Revision 6.0  93/05/24  16:58:16  prosb
#General Release 2.2
#
#Revision 1.1  93/05/20  10:32:18  janet
#Initial revision
#
# -----------------------------------------------------------------------
#
# Module:	TIMSETUP.X
# Project:	PROS -- ROSAT RSDC
# Purpose:	Routines to setup data and axes for plotting
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989.  You may do anything you like with this
#		file except remove this copyright
# Modified:	{0} Janet DePonte initial version Dec 1992
#
# -----------------------------------------------------------------------

include  <gset.h>
include  <mach.h>
include  <tbset.h>
include  "timplot.h"

# -----------------------------------------------------------------------
#
# Function:	xaxis_setup
# Purpose:	X-axis Label: determine x axis label
#    		-- set defplt to true if we change the x-axis because 
#	 	   params do not exist in header ... we will write the 
#                  default xaxis label for the x-axis type
#
# -----------------------------------------------------------------------
procedure xaxis_setup (const, tp, xlabel)

pointer const           # i: constant struct pointer
pointer tp              # i: table handle
char    xlabel[ARB]

bool    defplt          # l: indicated whether the plot will be default
int     cycles          # l: number of cycles in table for phase plot

pointer sp		# l: space allocation pointer
pointer xaxis		# l: xaxis units  

bool    ck_empty()	# l: check for empty string
bool    ck_none()	# l: check for none string
bool    streq()		
int     tbhgti()
real    tbhgtr()
double  tbhgtd()

begin

        call smark (sp)
        call salloc (xaxis, SZ_LINE, TY_CHAR)

        defplt = FALSE
        call clgstr (XUNITS, Memc[xaxis], SZ_LINE)
        XOFFSET(const)=0.0d0

        if ( ck_none (Memc[xaxis]) | ck_empty(Memc[xaxis]) ) {
           call error (1,
                "requires X-axis Label input: BIN, SECONDS, FREQ | PHASE")
#    BIN axis
        } else if ( streq("BIN", Memc[xaxis]) |
                    streq("bin", Memc[xaxis]) ) {
               BINLEN(const) = 1.0d0
               PTYPE(const) = XBIN
#    SECONDS axis
        } else if ( streq("SECONDS", Memc[xaxis]) |
                    streq("seconds", Memc[xaxis] ) ) {
#    --- read period increment for bin length
               iferr ( BINLEN(const) = tbhgtd (tp, "PERINCR") ) {
#    --- it could be called binlen
                  iferr ( BINLEN(const) = tbhgtd (tp, "BINLEN") ) {
                    call printf("\n** Hdr parameter BINLEN not found - will assume 1**\n")
                    defplt = TRUE
                    PTYPE(const) = XBIN
                    BINLEN(const)= 1.0d0
                    call sprintf(Memc[xaxis], SZ_LINE, "bin")
                  } else {
                    PTYPE(const) = XSEC
                  }
#    --- if BINLEN is 0, then we better plot bins
                } else if ( BINLEN(const) < EPSILOND ) {
#                   call printf ("binlen=%f\n")
#                     call pargd (BINLEN(const))
                    call printf ("\n** Period Increment NOT constant - will plot bins **\n")
                    defplt = TRUE
                    PTYPE(const) = XBIN
                    BINLEN(const)= 1.0d0
                    call sprintf(Memc[xaxis], SZ_LINE, "bin")
                } else {
                  PTYPE(const) = XSEC
                }
                if ( PTYPE(const) == XSEC ) {
                   iferr ( XOFFSET(const) = tbhgtd (tp, "BEG_PER") ) {
                      XOFFSET(const)=0.0d0
                   }
                }
#    FREQ axis
        } else if ( streq("FREQ", Memc[xaxis]) |
                    streq("freq", Memc[xaxis] ) ) {
               iferr ( BINLEN(const) = double( tbhgtr (tp, "FREQFAC") ) ) {
                   call printf ("\n** Header parameter FREQFAC not found - will plot bins **\n")
                   defplt=TRUE
                   PTYPE(const) = XBIN
                   BINLEN(const)=1.0d0
                   call sprintf(Memc[xaxis], SZ_LINE, "bin")
                } else {
                  PTYPE(const) = XFREQ
                }
#    PHASE axis
        } else if ( streq("PHASE", Memc[xaxis]) |
                    streq("phase", Memc[xaxis] ) ) {
               iferr ( cycles = tbhgti (tp, "CYCLES") ) {
                   call printf ("\n ** Header parameter CYCLES not found - will plot bins **\n")
                   defplt = TRUE
                   PTYPE(const) = XBIN
                   BINLEN(const)=1.0d0
                   call sprintf(Memc[xaxis], SZ_LINE, "bin")
               } else {
                   BINLEN(const) = double (cycles / NUMBINS(const))
                   PTYPE(const) = XPHASE
               }
        } else {
           call error (1, "Choose BIN | SECONDS | FREQ | PHASE for x-axis")
        }
        call flush (STDOUT)
        call clgstr (XLABEL, xlabel, SZ_LINE)
        if ( ck_none(xlabel) || ck_empty(xlabel) || defplt ) {
           call sprintf (xlabel, SZ_LINE, "%s" )
              call pargstr (Memc[xaxis])
        }

        call sfree(sp)
end

# -----------------------------------------------------------------------
#
# Function:	ptype_setup
# Purpose:	Plot type Setup: Determine whether the plot is a 
#		bar plot or histogram, set plotting keys in struct
#
# -----------------------------------------------------------------------
procedure ptype_setup (pltype)

int      pltype         #o: plot type indicator

pointer parbuf		#l: plot type buffer
pointer sp		#l: space allocation pointer

bool    ck_empty()	# check for empty string
bool    ck_none()	# check for none string
bool    streq()

begin
        call smark (sp)
        call salloc (parbuf, SZ_LINE, TY_CHAR)

        call clgstr (PLOTYPE, Memc[parbuf], SZ_LINE)
        call rootname("", Memc[parbuf], "", SZ_LINE)

        if ( ck_none(Memc[parbuf]) | ck_empty(Memc[parbuf]) ) {
           call error (1, "requires Plot Type input: HISTO or BAR")
        } else if ( streq("HISTO", Memc[parbuf]) |
                    streq("histo", Memc[parbuf]) ) {
           pltype = TY_HISTO
        } else if ( streq("BAR", Memc[parbuf]) |
                    streq("bar", Memc[parbuf] ) ) {
           pltype = TY_BAR
        } else {
           call error (1, "Choose HISTO or BAR for Plot Type")
        }

        call sfree (sp)
end

# -----------------------------------------------------------------------
#
# Function:	pdata_setup
# Purpose:	Plot Data Setup: determine the table column for
#		input data, init table column.	
#
# -----------------------------------------------------------------------
procedure pdata_setup (tp, ycolumn, ycol, ylabel)

pointer tp		#i: table i/o pointer
char    ycolumn[ARB]	#i: column to be plotted from table
pointer ycol		#o: handle to y table column
char    ylabel[ARB]	#o: y-axis label

bool    ck_empty()	# check for empty string
bool    ck_none()	# check for none string

begin

        call clgstr (PLOTCOLUMN, ycolumn, SZ_LINE)
        if ( ck_none(ycolumn) | ck_empty(ycolumn) ) {
           call error (1, "requires y column for histogram")
        } else {
           call tim_initcol (tp, ycolumn, ycol)
        }
        call clgstr (YLABEL, ylabel, SZ_LINE)
        if ( ck_none(ylabel) | ck_empty(ylabel) ) {
           call sprintf (ylabel, SZ_LINE, "%s" )
              call pargstr (ycolumn)
        }
end


# -----------------------------------------------------------------------
#
# Function:	edata_setup
# Purpose:	Error Data Setup: determine the table column for
#		error data, init table column.	
#
# -----------------------------------------------------------------------
procedure edata_setup (tp, ecolumn, ecol, ebar)

pointer tp		#i: table i/o pointer
char    ecolumn[ARB]	#i: error column to be plotted from table
pointer ecol		#o: handle to error table column
bool    ebar		#o: indicated whether there is error bars

bool    ck_empty()	# check for empty string
bool    ck_none()	# check for none string

begin
        ebar = false
        call clgstr (ERRCOLUMN, ecolumn, SZ_LINE)
        if ( !(ck_none(ecolumn) | ck_empty(ecolumn) ) ) {
           ebar = true
           call tim_initcol (tp, ecolumn, ecol)
        }
end

