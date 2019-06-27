# $Header: /home/pros/xray/xtiming/kspltab/RCS/kspltab.x,v 11.0 1997/11/06 16:46:03 prosb Exp $
# $Log: kspltab.x,v $
# Revision 11.0  1997/11/06 16:46:03  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 19:36:32  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  17:44:51  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:06:28  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  17:01:30  prosb
#General Release 2.2
#
#Revision 1.1  93/05/20  10:21:35  janet
#Initial revision
#
#
# -------------------------------------------------------------------------
# Module:	kspltab
# Project:	PROS -- ROSAT RSDC
# Purpose:	Task reformats the vartst output table and and outputs
#	        a table that will be input to a 'step' plot command.
# Description:	
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989.  You may do anything you like with this
#		file except remove this copyright
# Modified:	{0} JD - Mar 1993 - Initial Version
#
# -------------------------------------------------------------------------
include  <ext.h>
include  <tbset.h>

procedure  t_kspltab ()

bool     clobber		 # clobber old file

int      display		 # display level (0-5)
int      rowin			 # input row counter
int      num_rows		 # num rows in input file
int      rowout			 # output row counter
 
pointer  icolptr[10]             # output column pointer
pointer  ocolptr[10]             # output column pointer
pointer	 tempname 		 # temp name of output file
pointer  rtp, otp		 # table ptr 
pointer  sp			 # allocation pointer
pointer  var_file		 # input vartst table file
pointer  ks_tab			 # output ksplot table file

double   acctime		 # sum of gti's
double	 time, ptime 		 # input time and prev time

real     dist, pdist 		 # input dist and prev dist
real     cdf,  pcdf 		 # input cdf and prev cdf
real     cdfp, pcdfp		 # input cdfplus and prev cdfplus
real	 cdfm, pcdfm 		 # input cdfminus and prev cdfminus

bool	 clgetb()		 
int	 clgeti()

pointer  tbtopn()
double   tbhgtd()

begin
	call smark (sp)
	call salloc (var_file, SZ_PATHNAME, TY_CHAR)
	call salloc (ks_tab,   SZ_PATHNAME, TY_CHAR)
	call salloc (tempname, SZ_PATHNAME, TY_CHAR)

	display = clgeti("display")
	clobber = clgetb("clobber")

#   Open the vartst file for reading 
      	call clgstr ("vartst", Memc[var_file], SZ_PATHNAME)
      	call rootname (Memc[var_file], Memc[var_file],EXT_VAR, SZ_PATHNAME)
      	rtp = tbtopn (Memc[var_file], READ_ONLY, 0)

#   Open output best positions table
      	call clgstr ("ksplt_tab", Memc[ks_tab], SZ_PATHNAME)
      	call rootname (Memc[var_file], Memc[ks_tab], "_ksp.tab", SZ_PATHNAME)
      	call clobbername(Memc[ks_tab],Memc[tempname],clobber,SZ_PATHNAME)
      	otp = tbtopn (Memc[tempname], NEW_FILE, 0)

#   Init the input and output table columns
      	call init_outtab (otp, ocolptr)
      	call init_intab (rtp, icolptr, num_rows)

        if ( display >= 2 ) {
           call printf (" Number of Input rows = %d\n")
              call pargi (num_rows)
           call flush (STDOUT)
	}

#   Init the table variables
        ptime = 0.0d0
        pdist = 0.0
        pcdf  = 0.0
        pcdfp = 0.0
        pcdfm = 0.0

#   Reading and writing the tables begins here ...

#       the 1st row get 0's
        rowout = 1
        call wr_ksplt (otp, ocolptr, rowout, ptime, pdist, pcdf, pcdfp, pcdfm)

#       For every input row we write 2 output rows.
      	do rowin = 1, num_rows {

#	   Read an input row
	   call rd_var (rtp, icolptr, rowin, time, dist, cdf, cdfp, cdfm)

#          Write a row with current time and previous data
           rowout=rowout + 1
           call wr_ksplt (otp, ocolptr, rowout, time, pdist, pcdf, pcdfp, pcdfm)

#          Write a row with current time and current data
           rowout=rowout + 1
           call wr_ksplt (otp, ocolptr, rowout, time, dist, cdf, cdfp, cdfm)

#          save current as previous for next loop
           pdist = dist
           pcdf = cdf
           pcdfp = cdfp
           pcdfm = cdfm

	}

#       The end of the step is at the accepted time ...write with last 
#       set of input values
        iferr ( acctime = tbhgtd (rtp, "VAL_SECS") ) {
               acctime = time
        }
        rowout=rowout + 1
        call wr_ksplt (otp, ocolptr, rowout, acctime, dist, cdf, cdfp, cdfm)

#   ... and ends here
        if ( display >= 2 ) {
           call printf (" Number of Output rows (2*in_rows + 2) = %d\n")
              call pargi (rowout)
           call flush (STDOUT)
	}
	
# Close the output file
	call tbtclo (rtp)
	call tbtclo (otp)

# Finalize the names
#	if ( display >= 1 ) {
#	   call printf ("Creating KS plot file: %s\n")
#	      call pargstr (Memc[ks_tab])
#	}
	call finalname (Memc[tempname], Memc[ks_tab])

# Free the space
	call sfree (sp)
end
