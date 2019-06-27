# $Header: /home/pros/xray/xtiming/kspltab/RCS/ksp_subs.x,v 11.0 1997/11/06 16:46:02 prosb Exp $
# $Log: ksp_subs.x,v $
# Revision 11.0  1997/11/06 16:46:02  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 19:36:29  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  17:44:48  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:06:25  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  17:01:27  prosb
#General Release 2.2
#
#Revision 1.1  93/05/20  10:22:18  janet
#Initial revision
#
#
# -------------------------------------------------------------------------
# Module:	ksp_subs
# Project:	PROS -- ROSAT RSDC
# Purpose:	Subroutines to kspltab	
# Description:	init_outtab(), init_intab(), rd_var(), wr_ksplt()
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1993.  You may do anything you like with this
#		file except remove this copyright
# Modified:	{0} JD - Mar 1993 - Initial Version
#
# -------------------------------------------------------------------------
include  <ext.h>
include  <tbset.h>

# ------------------------------------------------------------------------
# init_outtab - initialize the output table
# -------------------------------------------------------------------------
procedure init_outtab (otp, ocolptr)

pointer otp		# output table pointer
pointer ocolptr[ARB]	# output table column pointer

begin

#     Initialize the output table columns
      call tbcdef(otp,ocolptr[1],"time","","%14.5f",TY_DOUBLE,1,1)
      call tbcdef(otp,ocolptr[2],"dist","","%12.5f",TY_REAL,1,1)
      call tbcdef(otp,ocolptr[3],"cdf","","%12.5f",TY_REAL,1,1)
      call tbcdef(otp,ocolptr[4],"cdfplus","","%12.5f",TY_REAL,1,1)
      call tbcdef(otp,ocolptr[5],"cdfminus","","%12.5f",TY_REAL,1,1)

      call tbtcre(otp)

end

# ------------------------------------------------------------------------
# init_intab - initialize the input rough positions table
# ------------------------------------------------------------------------
procedure init_intab (rtp, icolptr, num_rows)

pointer rtp             # i: input table handle
pointer icolptr[ARB]    # i: column pointer
int     num_rows        # i: number of input rows

int     tbpsta()

begin

      # get the number of ruf positions
      num_rows = tbpsta (rtp, TBL_NROWS)

      # init the columns we expect in this file
      call tbcfnd (rtp, "time", 	icolptr[1], 1)
      call tbcfnd (rtp, "dist", 	icolptr[2], 1)
      call tbcfnd (rtp, "cdf", 		icolptr[3], 1)
      call tbcfnd (rtp, "cdfplus", 	icolptr[4], 1)
      call tbcfnd (rtp, "cdfminus", 	icolptr[5], 1)
end

# ------------------------------------------------------------------------
# rd_var - read a row of vartst table data
# ------------------------------------------------------------------------
procedure rd_var (rtp, icolptr, rowin, time, dist, cdf, cdfp, cdfm)

pointer	rtp		# i: input table pointer
pointer icolptr[ARB]	# i: input column pointer
int	rowin		# i: current row to read
double	time		# o: input event time
real	dist		# o: input dist
real 	cdf		# o: input cdf
real	cdfp		# o: input cdf plus
real	cdfm		# o: input cdf minus

bool   nullflag[25]

begin
	   call tbrgtd (rtp, icolptr[1], time, nullflag, 1, rowin)
           call tbrgtr (rtp, icolptr[2], dist, nullflag, 1, rowin)
           call tbrgtr (rtp, icolptr[3], cdf,  nullflag, 1, rowin)
           call tbrgtr (rtp, icolptr[4], cdfp, nullflag, 1, rowin)
           call tbrgtr (rtp, icolptr[5], cdfm, nullflag, 1, rowin)
end

# ------------------------------------------------------------------------
# wr_ksplt - write the current row to the step plot table
# ------------------------------------------------------------------------
procedure wr_ksplt (otp, ocolptr, rowout, time, dist, cdf, cdfp, cdfm)

pointer	otp		# i: output table pointer
pointer ocolptr[ARB]	# i: output column pointer
int	rowout		# i: current row to write
double  time            # i: output event time
real    dist            # i: output dist
real    cdf             # i: output cdf
real    cdfp            # i: output cdf plus
real    cdfm            # i: output cdf minus

begin
        call tbrptd (otp, ocolptr[1], time, 1, rowout)
        call tbrptr (otp, ocolptr[2], dist, 1, rowout)
        call tbrptr (otp, ocolptr[3], cdf,  1, rowout)
        call tbrptr (otp, ocolptr[4], cdfp, 1, rowout)
        call tbrptr (otp, ocolptr[5], cdfm, 1, rowout)

end
