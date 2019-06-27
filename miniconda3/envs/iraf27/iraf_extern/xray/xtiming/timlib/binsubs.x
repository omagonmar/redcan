#$Header: /home/pros/xray/xtiming/timlib/RCS/binsubs.x,v 11.0 1997/11/06 16:45:01 prosb Exp $
#$Log: binsubs.x,v $
#Revision 11.0  1997/11/06 16:45:01  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:34:47  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:42:04  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:02:45  prosb
#General Release 2.3
#
#Revision 6.1  93/07/02  14:56:26  mo
#MC	7/2/93		Correct int->double conversion from double -> dfloat
#
#Revision 6.0  93/05/24  16:58:55  prosb
#General Release 2.2
#
#Revision 5.1  93/05/20  10:06:57  janet
#made bin_length a double in all timing procedures.
#
#Revision 5.0  92/10/29  23:05:32  prosb
#General Release 2.1
#
#Revision 4.3  92/10/08  09:13:03  mo
#MC	10/1/92		Added a routine 'tim_cktime' to return the offset
#			to the specified event attribute.
#
#Revision 4.2  92/09/29  14:06:46  mo
#MC	9/29/92		Updated calling sequence for begs and ends rather				than 2 dimensional GTI's
#
#Revision 4.1  92/09/28  16:26:31  janet
#+1 to display level for gintvs
#
#Revision 4.0  92/04/27  15:35:43  prosb
#General Release 2.0:  April 1992
#
#Revision 3.4  92/04/23  17:49:13  mo
#MC	4/23/92		Remove the code that modifies the GTIS with
#			the user filter since this is done automatically
#			by IRAF now.
#			Make it a fatal error if there are no GTIS
#			and get_gintvs is set to yes
#
#Revision 3.3  92/02/20  17:44:57  mo
#MC	2/20/92		Oops - wrong include file path
#
#Revision 3.2  92/02/20  15:39:39  mo
#MC	2/20/92		Make reading the numbins and binlength
#			parameters conditional, so that summed
#			FFT won't read on every segment.
#
#Revision 3.1  91/09/24  14:42:00  janet
# added exposure screens made available in iraf 2.9.3
#
#Revision 2.1  91/06/26  17:24:00  pros
#MC	6/26/91		Merged the private fft copy with the lib
#			copy and corrected the calling sequence for all
#			the sprintf calls
#
#Revision 2.0  91/03/06  22:50:13  pros
#General Release 1.0
# -------------------------------------------------------------------------
# Module:	binsubs.x
# Project:	PROS -- ROSAT RSDC
# Purpose:	Library routines to Bin Src & Bkgd time data and 
#		compute count rates. 
# Description:	
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989.  You may do anything you like with this
#		file except remove this copyright
# Modified:	{0} Adam Szczypek -- initial version  -- Jan 1987	
#		{1} Janet DePonte -- updated version  -- April 1989
#		{2} M. Conroy -- increased modularity for library 
#						      --  Sept 1990
#		{3} JD -- Jul 1992 - +1 to display level for gintvs
#		{n} <who> -- <does what> -- <when>
#
# -------------------------------------------------------------------------
include  <tbset.h>
include	 <gset.h>
include  <qpset.h>
include  <qpioset.h>
include  <qpoe.h>
include  <ext.h>
include  <mach.h>
include  "timing.h"


# -------------------------------------------------------------------------
#
# Function:	tim_openqp
# Purpose:	Open a requested qpoe file and its event list
# Uses:		Uses the IRAF/QPOE library routines
# Pre-cond:	The input filename can be a path or any abbreviation of
#		None ( in any combination of caps and lower case )
# Post-cond:	The qp and qpio file handles are returned OR
#		The none boolean is set to TRUE if a 'None' input was
#		recognized.
#
# -------------------------------------------------------------------------
procedure tim_openqp( param, ext, file_name, evlist, none, qp, qpio )

char	param[ARB]	# i: pointer to parameter name string
char	ext[ARB]	# i: pointer to required file extension string
char    file_name[ARB]  # i/o: name of qpoe file to open
char    evlist[ARB]  	# i/o: name of qpoe file user filter
bool	none		# o: was none the input filename
pointer	qp		# o: returned qpoe file handle
pointer	qpio		# o: returned qpoe file handle

pointer	sp		# l: stack pointer
#pointer	evlist		# l: name of evlist to open
pointer	file_root	# l: root name of input file
pointer	sbuf
pointer qp_open()
pointer qpio_open()
bool	ck_none()
bool	streq()

begin
	call smark (sp)
#	call salloc (evlist,    SZ_EXPR,     TY_CHAR)
	call salloc (sbuf,      SZ_LINE,     TY_CHAR)
	call salloc (file_root, SZ_PATHNAME, TY_CHAR) 

	call clgstr (param, file_name, SZ_PATHNAME)
	call rootname (file_name,file_name,ext,SZ_PATHNAME)
	none = ck_none( file_name )
	if (streq("", file_name) ) {
	    call sprintf(sbuf,SZ_LINE,"requires *%s file as input\n")
	    call pargstr(ext)
	    call error(1, sbuf) 
        }
	if ( !none ) {
	    call qpparse (file_name, Memc[file_root], SZ_PATHNAME,
                          evlist, SZ_EXPR)
	    qp = qp_open (Memc[file_root], READ_ONLY, NULL)
	    qpio = qpio_open( qp, evlist, READ_ONLY)
	}
	else
#	    call strcpy( file_name, evlist, SZ_PATHNAME)
	    call strcpy( "", evlist, SZ_PATHNAME)
	call sfree(sp)
end

#--------------------------------------------------------------------
#
# Function:	tim_getarea
# Purpose:	Get the total area of all the regions used in creating this QPOE
# Uses:		 /pros library
# Pre-cond:	Needs a file handle to a main QPOE file
# Post-cond:	Returns the total area
#
# -------------------------------------------------------------------------
procedure tim_getarea( qp, area)
pointer	qp			# i: input qp handle
double	area			# o: total area of all selected regions

pointer	areas			# l: pointer to individual region areas
int	indices			# l: index for set of regions
int	i			# l: loop index

begin
	area = 0.0D0
	call get_qparea(qp,areas,indices)
	do i=1,indices
	    area = area + Memi[areas+i-1]
end

# -------------------------------------------------------------------------
#
# Function:	ltc_setbins
# Purpose:	Determine the length and duration of timing bins for ltcurv
# Uses:		/pros library
# Pre-cond:	An active file handle to both the main QPOE file and the event
#		list.  The bins will cover the whole of times in the QPOE file
# Post-cond:	The start and stop times of the good intervals and the bin
#		lengths
#
# Method:	If requested, the good intervals are not used, just the
#		min and max times in the file
# -------------------------------------------------------------------------
procedure ltc_setbins(display,start,stop,numbins,bin_length)

int	display		# i: display level
double	start		# i: start time in secs
double	stop		# i: stop time in secs
int	numbins		# o: returned number of bins
double  bin_length	# o: seconds per bin
#int	offset

int	clgeti()
double  clgetd()

begin
#	call tim_getss (display,qpio,offset,start,stop)

#   Compute Number and Length of Bins
#   If both of these values are already set, we don't need to redo
#	this ( summed FFT case )
        if( (numbins == 0) || (bin_length < EPSILOND) ) {
	    numbins = clgeti(NUMOFBINS)
        } else {
	    numbins = 0
	}
	if ( numbins > 0 ) {
	   bin_length  = (stop-start)/double(numbins)
	}  else {
    	   if(  (bin_length < EPSILOND) )
	       bin_length = clgetd (NUMOFSECS)
	   numbins = int ((stop-start)/bin_length) + 1
	}
	if ( display > 1 ) {
	   call printf("binlen = %12.3f & num_bins = %d\n")
	     call pargd(bin_length)
	     call pargi(numbins)
	}
end

# -------------------------------------------------------------------------
#
# Function:	fld_setbins
# Purpose:	Determine the length and duration of timing bins for fold
# Uses:		/pros library
# Pre-cond:	An active file handle to both the main QPOE file and the event
#		list.  The bins will cover the whole of times in the QPOE file
# Post-cond:	The start and stop times of the good intervals and the bin
#		lengths
#
# Method:	If requested, the good intervals are not used, just the
#		min and max times in the file
# -------------------------------------------------------------------------
procedure fld_setbins (display, period, numbins, bin_length)

int	display		# i: display level
double  period     	# o: period in secs to fold data
int	numbins		# o: returned number of bins
double  bin_length	# o: seconds per bin

int	clgeti()

begin

	numbins = clgeti(NUMOFBINS)
 	if (numbins > MAX_BINS) {
           call error (1,"Exceeded Max # Bins - requested %d when max is %d\n")
             call pargi(numbins)
             call pargi(MAX_BINS)
        } else if ( numbins <= 0 ) {
	   numbins = 1
        }

#   Compute Number and Length of Bins
        bin_length = period / numbins

        if ( display > 1 ) {
           call printf("binlen= %12.3f & num_bins= %d & period= %12.3f\n")
             call pargd(bin_length)
             call pargi(numbins)
             call pargd(period)
        }
end

# -------------------------------------------------------------------------
#
# Function:	tim_gintvs
# Purpose:	Retrieve the good time intervals
# Uses:		/pros library
# Pre-cond:	An active file handle to both the main QPOE file and the event
#		list. 
# Post-cond:	The start and stop times of the good intervals 
#
# -------------------------------------------------------------------------
procedure tim_gintvs (display, qp, qpio, offset, filter, start, stop,
                      gbegs, gends, num_gintvs, duration)

int	display		# i: display level
pointer	qp		# i: qp file handle
pointer	qpio		# i: qpio event handle
int	offset		# i: offset 
char	filter[ARB]	# i: user specified QPOE filter string
double	start		# i: start time in secs
double	stop		# i: stop time in secs
pointer	gbegs		# i/o: pointer to good interval records
pointer	gends		# i/o: pointer to good interval records
int	num_gintvs      # o: number of gintvs
double	duration        # o: sum of gtis

bool	get_gintvs	# l: logical - read Good Interval Records?
bool	clgetb()
int     i

#bool    in_intv
#int     i, good_gintvs
#double  beg_gintv
#double  end_gintv
#bool    streq()

double	get_filttimes()

begin

# Get the times of first and last photon
	call tim_getss (display, qpio, offset, start, stop)

        if ( display >= 2 ) {
           call printf ("filter=%s\n")
             call pargstr (filter)
        }

# Shall we get the first and last times?
	get_gintvs = clgetb(GETGOODINTV)

# retrieve gintvs from qpoe file
	if ( get_gintvs ) {

# Compare the filter to the gtis and return only the gtis within the 
# filter time specification
	   duration = get_filttimes (qp,filter,display,gbegs,gends,num_gintvs)

# In the case when no filter is used, get_filttimes returns all the gtis 
# for the qpoe.  We have to compare that list against the 1st and last
# qpoe time to determine the appropriate gintvs to keep.
###  MC  We think this is obsolete with IRAF 2.10/PROS 2.0
#           if ( streq("", filter) ) {
#              good_gintvs=0
#              in_intv=false
#	      do i = 1, num_gintvs {
#                  beg_gintv=Memd[gintvs+((i-1)*2)]
#                  end_gintv=Memd[gintvs+((i-1)*2)+1]
#	 	   if ( (start >= beg_gintv) && (start <= end_gintv) ) {
#			in_intv = true
#		     }
#                     if (stop >= beg_gintv && in_intv ) {
#                        good_gintvs = good_gintvs+1
#                        Memd[gintvs+((good_gintvs-1)*2)]=beg_gintv
#                        Memd[gintvs+((good_gintvs-1)*2)+1]=end_gintv
#	             }
#              }
#              num_gintvs=good_gintvs
#	   }
### end of IRAF 2.10/PROS 2.0 change

#  Display the Final Gintvs
           if ( display >= 4 ) {
              call printf ("Final Num_gintvs=%d\n")
                 call pargi (num_gintvs)
              if ( num_gintvs > 0 ) {
                 do i = 1, num_gintvs {
                   call printf ("gintvs[%d]=%f, %f\n")
                    call pargi (i)
                    call pargd (Memd[gbegs+i-1])
                    call pargd (Memd[gends+i-1])
                 }
	      }
           }

	}
# either there are none in qpoe or we don't want to use them - set to
# start & stop
	if ( !get_gintvs ){
	   call malloc (gbegs, 1, TY_DOUBLE)
	   call malloc (gends, 1, TY_DOUBLE)
	   num_gintvs = 1
	   Memd[gbegs] = start
	   Memd[gends] = stop
           duration = stop - start
	}
# Reset the start and stop to be start and stop of current specified intvs
	else{
	   if( num_gintvs == 0){
	       call eprintf("**** No good time intervals found - recheck your input ****\n")
	       call error(1,"Rerun with 'get_gintvs=no' to override")
	   }
	   start = Memd[gbegs]
	   stop = Memd[gends+num_gintvs-1]
	}

end

# -------------------------------------------------------------------------
#
# Function:	tim_outtable
# Purpose:	Read filename and clobber parameters and create output filename
# Uses:		clobbername, rootname, etc.
# Pre-cond:	Needs the template to build the output filename
# Post-cond:	The temporary and final output filename
# Method:	Uses the standard PROS rootname,clobbername
# -------------------------------------------------------------------------
procedure tim_outtable(param,ext,master_name,output_name,tempname,clobber)

char	param[ARB]		# i: parameter name
char	ext[ARB]		# i: output file extension
pointer	master_name		# i: input template name
pointer	output_name		# o: output filename
pointer	tempname		# o: temp filename


bool	clobber			# o: clobber value

pointer	sp
bool	streq()

begin

#   Get input/output filenames
	call smark(sp)
	call clgstr (param, Memc[output_name], SZ_PATHNAME)
	call rootname(Memc[master_name],Memc[output_name], ext, SZ_PATHNAME)
	if (streq("NONE", Memc[output_name]) ) {
	   call error(1, "requires table file as output")
        }
	call clobbername(Memc[output_name],Memc[tempname],clobber,SZ_PATHNAME)
	call sfree(sp)
end

# -------------------------------------------------------------------------
#
# Function:	tim_qpclose
# Purpose:	Close the main QPOE file and its event list
# Uses:		QPOE library
# Pre-cond:	Active QPOE and QPIO file handles	
# Post-cond:	Inactive handles
# -------------------------------------------------------------------------
procedure tim_qpclose(qp,qpio)
pointer	qp			# i: qp file handel
pointer	qpio			# i: qp event list handle

begin
	call qpio_close(qpio)
	call qp_close(qp)
end

# -------------------------------------------------------------------------
#
# Function:	tim_getss
# Purpose:	Retrieve the min and max for the event time attribute from 
#		the QPOE file
# Uses:		QPIO library
# Pre-cond:	An active qpoe file handle
# Post-cond:	The min and max of time
# Notes:	This will return the static min and max as recorded in
#		the QPOE file, and will not reflect a revised min and max
#		which may be the result of any time filtering applied to the 
#		file
# -------------------------------------------------------------------------
procedure tim_getss (display,qp,offset,start,stop)

int	display			# i: display level
pointer	qp			# i: input qpoe handle
int	offset			# i: offset
double	start			# o: start time of photons
double	stop			# o: stop time of photons

pointer	ev			# l
pointer	qpio_stati(),coerce()
begin
#  The coerce function seems to be needed now for this to work on sparcs
#     coerce syntax taken from zzdebug/dumpevl
        ev = qpio_stati(qp, QPIO_MINEVP)
        start = Memd[coerce(ev+offset,TY_SHORT,TY_DOUBLE)]
#        start = Memd[(ev+offset-1)/SZ_DOUBLE+1]
        ev = qpio_stati(qp, QPIO_MAXEVP)
#        stop = Memd[(ev+offset-1)/SZ_DOUBLE+1]
        stop = Memd[coerce(ev+offset,TY_SHORT,TY_DOUBLE)]
        if ( display >= 2 ) {
           call printf ("Data start = %14.3f & stop = %14.3f\n")
             call pargd (start)
             call pargd (stop)
        }
end

# -------------------------------------------------------------------------
#
# Function:	tim_tbhd
# Purpose:	Copy standard QPOE header parameters to the output table file
# Uses:		/pros library
# Pre-cond:	An active qpoe file handle and table file handle
# Post-cond:	An table file with PROS standard header

# -------------------------------------------------------------------------
procedure tim_hdr (tp,sqp,bqp,photon_file,bkgd_file,dobkgd)

pointer	tp		# i: output table file handle
pointer	sqp		# i: input source qpoe handle
pointer	bqp		# i: input bkgd qpoe handle
char	photon_file[ARB]# i: input source qpoe filename
char	bkgd_file[ARB]	# i: input bkgd qpoe filename
bool	dobkgd		# i: do background?

pointer	qphd		# l: qpoe header structure

begin
        call get_qphead (sqp, qphd)
        call put_tbhead (tp, qphd)
        call tim_addmsk(tp, sqp, photon_file, "s")
        if ( dobkgd ) {
           call tim_addmsk (tp, bqp, bkgd_file, "b")
        }
	call mfree(qphd, TY_STRUCT)
end

# -------------------------------------------------------------------------
#
# Function:	tim_initbin
# Purpose:	Set up the first time bin and zero the total exposure
# Uses:		tim_initmm
# Pre-cond:	Needs a starting point and bin length
# Post-cond:	Returns the bin limits and exposure
#
# -------------------------------------------------------------------------
procedure tim_initbin(start,bin_length,minmax,start_bin,stop_bin,exposure)

double	start		# i: start of data
double  bin_length	# i: length of bin
pointer	minmax		# o: min and max values
double	start_bin	# o: start time of bin
double	stop_bin	# o: stop time of bin
real	exposure	# o: total_exposure
 
begin
        call tim_initmm (minmax)
        start_bin = start
        stop_bin = start_bin + bin_length
        exposure = 0.0E0
end

# -------------------------------------------------------------------------
#
# Function:	tim_openqpf
# Purpose:	Open the qpoe file
#
# -------------------------------------------------------------------------
procedure tim_openqpf( file_name, evlist, ext, none, qp, qpio )
 
char    file_name[ARB]  # i/o: name of qpoe file to open
char	evlist[ARB]     # l: name of evlist to open
char    ext[ARB]        # i: pointer to required file extension string
bool    none            # o: was none the input filename
pointer qp              # o: returned qpoe file handle
pointer qpio            # o: returned qpoe file handle

pointer sp              # l: stack pointer
pointer file_root       # l: root name of input file
pointer sbuf
pointer qp_open()
pointer qpio_open()
bool    ck_none()
bool    streq()
 
begin
        call smark (sp)
#        call salloc (evlist,    SZ_EXPR,     TY_CHAR)
        call salloc (sbuf,      SZ_LINE,     TY_CHAR)
        call salloc (file_root, SZ_PATHNAME, TY_CHAR)
 
#       call clgstr (param, file_name, SZ_PATHNAME)
#       call rootname (file_name,file_name,ext,SZ_PATHNAME)
        none = ck_none( file_name )
        if (streq("", file_name) ) {
            call sprintf(sbuf,SZ_LINE,"requires *%s file as input\n")
            call pargstr(ext)
            call error(1, sbuf)
        }
        if ( !none ) {
            call qpparse (file_name, Memc[file_root], SZ_PATHNAME,
                          evlist, SZ_EXPR)
            qp = qp_open (Memc[file_root], READ_ONLY, NULL)
            qpio = qpio_open( qp, evlist, READ_ONLY)
        }
        else
#            call strcpy( file_name, Memc[evlist], SZ_PATHNAME)
            call strcpy( "", evlist, SZ_PATHNAME)
        call sfree(sp)
end
 

