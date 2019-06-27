# $Header: /home/pros/xray/xspatial/eintools/cat_make/RCS/cm_tools.x,v 11.0 1997/11/06 16:30:42 prosb Exp $
# $Log: cm_tools.x,v $
# Revision 11.0  1997/11/06 16:30:42  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:48:23  prosb
# General Release 2.4
#
#Revision 1.1  1994/03/15  09:09:24  prosb
#Initial revision
#
#
#--------------------------------------------------------------------------
# Module:       cm_tools.x
# Project:      PROS -- EINSTEIN TOOLS
# External:     cat_make
# Internal:     bin_asp, mk_cat_data, cm_sum_times, cat_head, cat_hist
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1994.  You may do anything you like with this
#               file except remove this copyright.
# Modified:     {0} David Van Stone -- 3/94 -- initial version 
#               {n} <who> -- <when> -- <does what>
#--------------------------------------------------------------------------

include "../source/et_err.h"
include "../source/array.h"
include "../source/asp.h"
include "../tables/cat.h"
include <math.h>
include <qpoe.h>
include <qpc.h>

#--------------------------------------------------------------------------
# Procedure:    cat_make()
#
# Purpose:      Make constant aspect table from qpoe file
#
# Input variables:
#               qpoe_name       input qpoe file name
#               qpoe_evlist     associated event list (e.g. "[time=10:50]")
#               cat_name        output constant aspect table
#		final_cat_name  name of final CAT [for history]
#               aspx_res        aspect x resolution
#               aspy_res        aspect y resolution
#               aspr_res        aspect roll resolution
#               n_cat		number of rows in output CAT
#               display         display level
#
# Description:  This is the main routine for the task cat_make.  It's
#		purpose is to group together the aspect information
#		in the BLT records of the QPOE file [intersecting the
#		times with the current GTI and the passed in event
#		list], then write the groups out to the table in
#		WCS format.
#
#		For instance, if the QPOE contains one BLT record from
#		time 1000 to 2000, where the current GTI [deffilt] is
#		the filter [995:1500] and furthermore the user puts
#		in the event list "time=(1200:1300,1450:1800)", then
#		the final time associated with that one BLT record
#		will be [1200:1300,1450:1500].  There would be one
#		row in the CAT with a livetime of 150 seconds times
#		the dead-time correction in the QPOE header.
#
#		What's the difference between cat_name and final_cat_name?
#		The first is the name of the actualy file we will be
#		writing to.  However, since the user may be clobbering
#		another file, this "cat_name" may be pointing to a
#		temporary file.  The "final_cat_name" is the actual
#		file that "final_name" will convert "cat_name" to.
#		(Isn't that clear?)
#
# Algorithm:    * Open QPOE file and read in the header
#		* Open output CAT
#		* Create list of aspect records
#		* Place aspect into bins
#		* Fill output table with binned aspect, converted to WCS
#		* Write out header and history to CAT
#		* Release memory
#
#--------------------------------------------------------------------------
procedure cat_make(qpoe_name,qpoe_evlist,cat_name,final_cat_name,
			aspx_res,aspy_res,aspr_res,n_cat,display )
char 	qpoe_name[ARB]	      # i: name of input QPOE file
char 	qpoe_evlist[SZ_EXPR]  # i: QPOE event list (e.g. "[time=10:50]")
char 	cat_name[ARB]	      # i: output file name for CAT
char 	final_cat_name[ARB]   # i: actual output file name
double 	aspx_res	    # i: Aspect x resolution (for binning)
double	aspy_res	    # i: Aspect y resolution (for binning)
double	aspr_res	    # i: Aspect roll resolution (for binning)
int	n_cat		    # o: number of rows in CAT
int 	display		    # i: display level

### LOCAL VARS ###

int	n_asp	           # number of aspect records (before binning)
pointer p_asp		   # pointer to aspect data
int	n_bin		   # number of binned aspect records
pointer p_bin		   # pointer to binned aspect data
pointer p_asp2bin	   # pointer to integer index describing which
			   #  aspect record corresponds to which 
			   #  binned aspect record.
pointer p_aspqual	   # pointer to aspect quality record (unused)
pointer p_cat_info	   # pointer to CAT info (see gt_info.x)
pointer p_cat_data	   # pointer to data to write to CAT
pointer col_ptr[N_COL_CAT] # column pointers for CAT
pointer qp		   # QPOE file
pointer qphead		   # QPOE header
int	n_times		   # number of TIMES records
pointer p_times		   # pointer to TIMES structure (see asp.h)
pointer p_times2asp        # pointer to integer index between TIMES & ASP
pointer tp		   # table pointer (to CAT)

### EXTERNAL FUNCTION DECLARATIONS ###

pointer qp_open()  # returns pointer to QPOE [sys/qpoe]

### BEGINNING OF PROCEDURE ###

begin
        #----------------------------------------------
        # Open QPOE file and read in header
        #----------------------------------------------
 	qp=qp_open(qpoe_name,READ_ONLY,0)
	call get_qphead(qp,qphead)

        #----------------------------------------------
        # Set up CAT data and create new table
        #----------------------------------------------
        call cat_setup(p_cat_info)
	call gt_new(cat_name,tp,col_ptr,p_cat_info)


        #----------------------------------------------
        # Set up aspect list
        #----------------------------------------------
 	call qp2asp(qp,qpoe_evlist,p_asp,n_asp,p_times,n_times,
				p_times2asp,p_aspqual,display) 

        #----------------------------------------------
	# bin aspect list
        #----------------------------------------------
	call bin_asp(p_asp,n_asp,aspx_res,aspy_res,aspr_res,p_bin,n_bin,
			p_asp2bin,display)

        #----------------------------------------------
	# fill table data
        #----------------------------------------------
	call mk_cat_data(qp,qphead,p_bin,n_bin,p_asp2bin,p_times,n_times,
			p_times2asp,p_cat_data,n_cat,display) 

	if (display>4)
	{
	   call printf("CAT contents:\n")
	   call gt_print_rows(p_cat_data,p_cat_info,n_cat)
	}

        #----------------------------------------------
	# write out cat data
        #----------------------------------------------
	call gt_put_rows(p_cat_data,tp,p_cat_info,col_ptr,1,n_cat)

        #----------------------------------------------
	# write header and history to CAT
        #----------------------------------------------
	call cat_head(qp,qphead,tp,aspx_res,aspy_res,aspr_res)
	call cat_hist(qpoe_name,final_cat_name,tp)

        #----------------------------------------------
	# close CAT
        #----------------------------------------------
	call tbtclo(tp)

        #----------------------------------------------
        # clear CAT info
        #----------------------------------------------
        call gt_free_info(p_cat_info)

        #----------------------------------------------
	# free up all other pointers
        #----------------------------------------------
	call mfree(p_aspqual,TY_INT)
	call mfree(p_times2asp,TY_INT)   
	call mfree(p_times,TY_DOUBLE)
	call mfree(p_asp,TY_DOUBLE)
	call mfree(p_bin,TY_DOUBLE)
	call mfree(p_asp2bin,TY_INT)
	call mfree(p_cat_data,TY_STRUCT)
	call mfree(qphead,TY_STRUCT)

        #----------------------------------------------
	# close qpoe file
        #----------------------------------------------
	call qp_close(qp)
end


#--------------------------------------------------------------------------
# Procedure:    bin_asp
#
# Purpose:      Creates binned aspect data structure
#
# Input variables:
#		p_asp		pointer to aspect structure [see asp.h]
#		n_asp		number of aspect records
#               aspx_res        aspect x resolution
#               aspy_res        aspect y resolution
#               aspr_res        aspect roll resolution
#               display         display level
#
# Output variables:
#               p_bin           pointer to binned aspect
#		n_bin		number of binned aspect records
#               p_asp2bin       index between ASP and binned ASP
#
# Description:  This procedure uses the binning routines in bin.x to
#		create a binned aspect structure.  The input aspect
#		must have all records be of type double [requisite
#		for the binning routines].  The binning will be
#		performed using the passed in resolutions.
#		
#		This is the only routine which cares about the order
#		of the ASP data structure.  We have to specify which
#		one is which to match up the appropriate resolutions.
#		We also pass in a resolution of 0.0 for the nominal
#		roll, to indicate that two aspect records with different
#		nominal rolls should be placed in separate bins.
#--------------------------------------------------------------------------

procedure bin_asp(p_asp,n_asp,aspx_res,aspy_res,aspr_res,
			  p_bin,n_bin,p_asp2bin,display)

pointer p_asp	   # i: pointer to aspect data
int	n_asp	   # i: number of aspect records
double 	aspx_res   # i: Aspect x resolution 
double	aspy_res   # i: Aspect y resolution 
double	aspr_res   # i: Aspect roll resolution
pointer p_bin	   # o: pointer to binned aspect data
int	n_bin	   # o: number of binned aspect records
pointer p_asp2bin  # o: pointer to index between aspect and bins.
int 	display	   # i: display level

double	res[4]   # resolutions array for binning
int	asp_dim  # number of dimensions of aspect & resolutions array

begin

        #----------------------------------------------
	# make resolution table
        #----------------------------------------------
	res[1]=0.0   # nominal roll resolution -- should keep 0.
	res[2]=aspx_res
	res[3]=aspy_res
	res[4]=aspr_res

        #----------------------------------------------
	# Bin the aspects!
        #----------------------------------------------
	asp_dim=4
	call bin_data(asp_dim,n_asp,Memd[p_asp],
				res,n_bin,p_bin,p_asp2bin,display)
end

#--------------------------------------------------------------------------
# Procedure:    mk_cat_data()
#
# Purpose:      To create the rows of the CAT from the binned aspect info
#
# Input variables:
#		qp		QPOE file
#		qphead		QPOE header
#		p_bin		pointer to binned aspect structure [asp.h]
#		n_bin		number of binned aspect records
#               p_asp2bin	index between unbinned & binned aspect
#		p_times		pointer to TIMES array
#		n_times		number of TIMES elements
#		p_times2asp     index between TIMES and [unbinned] aspect
#               display         display level
#
# Output variables:
#		p_cat_data	filled in CAT structures [cat.h]
#               n_cat		number of rows in CAT
#
# Description:  This routine will convert the binned aspect data into
#		WCS format and fill in the CAT data structure.  (Memory
#		is set aside for the CAT data.)
#
#		The WCS information for each row of the CAT is as follows:
#
#		RCRVL1,RCRVL2: where the reference point in the QPOE
#			      gets mapped to on the sky
#		RCROT2: (clockwise) rotation of image
#
#		These keywords, combined with the CAT header keywords
#		RCRPX1,RCRPX2,RCDLT1,RCDLT2 describe a transformation 
#		between the detector coordinates and the sky coordinates.
#		(See documentation for WCS for more info.)
#
#		Each CAT also has an associated duration, a.k.a. 
#		LIVETIME.  It represents how much time the satellite
#		was at a certain aspect.  We have the start and stop
#		times in the TIMES structure, which can be mapped to
#		the unbinned aspect via the TIMES2ASP index, then
#		mapped to the binned aspect via ASP2BIN.
#
#		For example, there may be five aspect records, mapped
#		to two binned aspect records as follows:
#
#		aspect 1      ---->  bin 1
#		aspect 2      ---->  bin 2
#		aspect 3      ---->  bin 2
#		aspect 4      ---->  bin 1
#		aspect 5      ---->  bin 2
#
#		(Hence ASP2BIN[1]=1, ASP2BIN[2]=2, ASP2BIN[3]=2, etc.)
#
#		We may have six sets of times for the five unbinned
#		aspects:
#
#		times 1  --> aspect 1
#		times 2  --> aspect 1
#		times 3  --> aspect 2
#		times 4  --> aspect 3
#		times 5  --> aspect 4
#		times 6  --> aspect 4
#		times 7  --> aspect 5
#
#		The first row of the CAT corresponds to bin 1, and
#		will have times 1,2,5, and 6, while the second row
#		(for bin 2) will have times 3,4, and 7.
#
#		We total the times for each row, then multiply by
#		the dead time correction in the QPOE header to
#		find the final livetime for that row.
#
# Algorithm:    * Load in WCS info from QPOE
#		* Make TIMES2BIN index array
#		* For each row of the binned aspect structure,
#		  * calculate livetime for this row
#		  * if the livetime is positive [above 0],
#		    * fill in CAT structure
#		* Release memory
#
#--------------------------------------------------------------------------
procedure mk_cat_data(qp,qphead,p_bin,n_bin,p_asp2bin,p_times,n_times,
			p_times2asp,p_cat_data,n_cat,display)
pointer qp	   # i: QPOE file
pointer qphead	   # i: QPOE header
pointer p_bin	   # i: pointer to binned aspect data
int	n_bin	   # i: number of binned aspect records
pointer p_asp2bin  # i: pointer to index between aspect and bins.
pointer p_times    # i: pointer to TIMES structure (see asp.h)
int	n_times	   # i: number of TIMES records
pointer p_times2asp  # i: pointer to integer index between TIMES & ASP
pointer p_cat_data # o: pointer to final CAT data
int	n_cat      # o: number of CAT rows
int	display    # i: display level

### LOCAL VARS ###

int	i_bin     # index into binned aspect structure
pointer c_bin     # pointer to current binned aspect record
pointer c_cat_data # pointer to current CAT record
pointer ct	  # coordinate transformation descriptor
double  livetime  # livetime for a CAT row
pointer	mw	  # MWCS descriptor (for QPOE)
double  r_qp[2]   # reference point for QPOE
double  w_qp[2]   # world reference point (unused)
double  arc_qp[2] # scale factors for X&Y (unused)
double  roll_qp   # QPOE roll (unused)
pointer p_times2bin # index between TIMES and BIN
double	wldx	  # temporary world reference point, X
double	wldy	  # temporary world reference point, Y

### EXTERNAL FUNCTION DECLARATIONS ###

double	cm_sum_times()  # total time for a bin [local]
pointer	qp_loadwcs()    # pointer to MWCS descriptor [sys/qpoe]
pointer	mw_sctran()	# pointer to CT descriptor [sys/mwcs]

### BEGINNING OF PROCEDURE ###

begin
        #----------------------------------------------
        # Find MW, CT, and ref. points from QPOE file
        #----------------------------------------------
        mw=qp_loadwcs(qp)
        call bkwcs(mw,r_qp,w_qp,arc_qp,roll_qp)
        ct=mw_sctran(mw,"logical","world",3B)

        #----------------------------------------------
	# set aside memory for CAT.
        #----------------------------------------------
	call malloc(p_cat_data,SZ_CAT*n_bin,TY_STRUCT)

        #----------------------------------------------
	# make times2bin table
        #----------------------------------------------
	call malloc(p_times2bin,n_times,TY_INT)
	call a2b2c(n_times,Memi[p_times2asp],Memi[p_asp2bin],
					Memi[p_times2bin])

        #----------------------------------------------
	# loop through each bin row
        #----------------------------------------------
	n_cat=0
	do i_bin=1,n_bin
	{
           #----------------------------------------------
	   # Calculate livetime
           #----------------------------------------------
	   livetime=QP_DEADTC(qphead)*
			cm_sum_times(p_times,n_times,Memi[p_times2bin],i_bin)

           #----------------------------------------------
	   # Only continue if livetime for row is > 0
           #----------------------------------------------
	   if (livetime>0.0)
	   {
	        #----------------------------------------------
        	# Increment number of CAT rows
	        #----------------------------------------------
	      	n_cat=n_cat+1

	        #----------------------------------------------
        	# Set current pointers in BIN & CAT arrays
	        #----------------------------------------------
	      	c_bin=ASP(p_bin,i_bin)
	      	c_cat_data=CAT(p_cat_data,n_cat)

	        #----------------------------------------------
        	# Calculate RCRVL1 & RCRVL2
	        #----------------------------------------------
		call get_wld_center(r_qp,ct,ASP_ROLL(c_bin),
			ASP_ASPX(c_bin),ASP_ASPY(c_bin),wldx,wldy,
			display)
	      	CAT_RCRVL1(c_cat_data)=wldx   
		CAT_RCRVL2(c_cat_data)=wldy   

	        #----------------------------------------------
        	# Calculate RCROT2
	        #----------------------------------------------
	      	CAT_RCROT2(c_cat_data)=
			RADTODEG(ASP_ROLL(c_bin)+ASP_ASPR(c_bin))

	        #----------------------------------------------
        	# Fill in livetime
	        #----------------------------------------------
   	      	CAT_LIVETIME(c_cat_data)=livetime
	   }
	}

	if (display>2)
	{
	   call printf("Number of rows in CAT: %d.\n")
	    call pargi(n_cat)
	}

        #----------------------------------------------
	# Free memory
        #----------------------------------------------
	call mfree(p_times2bin,TY_INT)
        call mw_ctfree(ct)
        call mw_close(mw)

end

#--------------------------------------------------------------------------
# Procedure:    cm_sum_times
#
# Purpose:      Sum the times associated with a particular binned
#		aspect record
#
# Input variables:
#               p_times		pointer to TIMES record [see asp.h]
#		n_times		number of TIMES records
#		times2bin	integer array linking times to bin data
#		i_bin		which bin to calculate for
#
# Return value: Returns the number of seconds at that binned aspect
#
# Description:  This procedure sums together all time durations which
#		fall in the passed in bin.  This does not calculate
#		livetime -- just total duration (in seconds).  It
#		does so by simply summing the duration of each
#		TIMES record corresponding to the passed in bin.
#--------------------------------------------------------------------------

double procedure cm_sum_times(p_times,n_times,times2bin,i_bin)
pointer p_times		   # i: pointer to TIMES record
int	n_times		   # i: number of TIMES records
int	times2bin[n_times] # i: integer array linking times to bin
int	i_bin		   # i: which bin

pointer c_times	    # pointer to current TIMES record
int	i_times     # index into TIMES record
double	total_time  # total time (returned value)
begin
	total_time=0.0D0

        #----------------------------------------------
	# loop over TIMES records
        #----------------------------------------------
	do i_times=1,n_times
	{
	   if (times2bin[i_times]==i_bin)
	   {
	      c_times=TM(p_times,i_times)
	      total_time=total_time+TM_STOP(c_times)-TM_START(c_times)
	   }
	}

        #----------------------------------------------
        # return total time
        #----------------------------------------------
	return total_time
end


#--------------------------------------------------------------------------
# Procedure:    cat_head
#
# Purpose:      Fill in header keywords in CAT
#
# Input variables:
#               qp		input QPOE
#		qphead		QPOE header
#		tp		CAT pointer
#               aspx_res        aspect x resolution
#               aspy_res        aspect y resolution
#               aspr_res        aspect roll resolution
#
# Description:  Fills in the following header keywords in the CAT:
#
#	CAT_NOMRA, CAT_NOMDEC:  nominal RA&DEC for QPOE.
#				(this is used as an identifier)
#	RCTYP1,RCTYP2,RCRPX1,RCRPX2,RCDLT1,RCDLT2:  WCS info for CAT
#	ASPX_RES,ASPY_RES,ASPR_RES: what resolutions were used
#				    to make CAT.
#		
#		Also writes out comments to CAT.
#--------------------------------------------------------------------------

procedure cat_head(qp,qphead,tp,aspx_res,aspy_res,aspr_res)
pointer qp	 # i: QPOE file
pointer qphead	 # i: QPOE header
pointer	tp	 # io: table pointer for CAT 
double 	aspx_res # i: Aspect x resolution (for binning)
double	aspy_res # i: Aspect y resolution (for binning)
double	aspr_res # i: Aspect roll resolution (for binning)

### LOCAL VARS ###

pointer	mw	  # MWCS descriptor (for QPOE)
double  r_qp[2]   # reference point for QPOE
double  w_qp[2]   # world reference point (unused)
double  arc_qp[2] # scale factors for X&Y (unused)
double  roll_qp   # QPOE roll (unused)

### EXTERNAL FUNCTION DECLARATIONS ###

pointer	qp_loadwcs()  # pointer to MWCS descriptor [sys/qpoe]

### BEGINNING OF PROCEDURE ###

begin
        #------------------------------------------------
	# write out nominal RA & DEC to identify this CAT.
        #------------------------------------------------
	call tbhadr(tp,CAT_NOMRA,QP_RAPT(qphead))
	call tbhadr(tp,CAT_NOMDEC,QP_DECPT(qphead))

        #----------------------------------------------
	# load in some WCS info from QPOE
        #----------------------------------------------
        mw=qp_loadwcs(qp)
        call bkwcs(mw,r_qp,w_qp,arc_qp,roll_qp)
        call mw_close(mw)

        #----------------------------------------------
	# write out some WCS info to table.
        #----------------------------------------------
	call tbhadt(tp,"RCTYP1","RA--TAN")
	call tbhadt(tp,"RCTYP2","DEC-TAN")

	call tbhadd(tp,CAT_RCRPX1,r_qp[1])
	call tbhadd(tp,CAT_RCRPX2,r_qp[2])
	call tbhadd(tp,CAT_RCDLT1,arc_qp[1])
	call tbhadd(tp,CAT_RCDLT2,arc_qp[2])

        #----------------------------------------------
	# write out other resolutions
        #----------------------------------------------
	call tbhadd(tp,"ASPX_RES",aspx_res)
	call tbhadd(tp,"ASPY_RES",aspy_res)
	call tbhadd(tp,"ASPR_RES",aspr_res)

        #----------------------------------------------
        # Write comments about CAT
        #----------------------------------------------
 	call tbhadt(tp,"COMMENT1",
	     "This constant aspect table is an intermediate file used")
	call tbhadt(tp,"COMMENT2",
	     "in creating an exposure mask in the EINTOOLS package.")
	call tbhadt(tp,"COMMENT3",
	     "The aspect of the input qpoe file has been grouped according")
	call tbhadt(tp,"COMMENT4",
	     "to the input resolutions, then converted into WCS format.")
	call tbhadt(tp,"COMMENT5",
	     "See the help page for CAT_MAKE for more information.")
end
 
#--------------------------------------------------------------------------
# Procedure:    cat_hist
#
# Purpose:      Fill in history header keywords in CAT
#
# Input variables:
#               qpoe_name	file name of input QPOE
#               cat_name	file name of output CAT
#               tp              CAT pointer
#
# Description:  Writes history to CAT.
#--------------------------------------------------------------------------
procedure cat_hist(qpoe_name,cat_name,tp)
char 	qpoe_name[ARB]  # i: QPOE file name
char 	cat_name[ARB]   # i: CAT file name
pointer	tp		# io: table pointer for CAT 

### LOCAL VARS ###

pointer sp       # stack pointer
pointer p_hist   # pointer to history string
int     len      # length of history string

### EXTERNAL FUNCTION DECLARATIONS ###

int     strlen() # returns length of string [sys/fmtio]

### BEGINNING OF PROCEDURE ###

begin   
        #----------------------------------------------
        # Set aside space for filter string
        #----------------------------------------------
        call smark(sp)
        len = strlen(cat_name)+
              strlen(qpoe_name)+
              SZ_LINE
        call salloc(p_hist, len, TY_CHAR)

        #----------------------------------------------
        # Create main history string
        #----------------------------------------------
        call sprintf(Memc[p_hist], len, "CAT_MAKE: %s -> %s")
         call pargstr(qpoe_name)
         call pargstr(cat_name)

        #----------------------------------------------
        # Write history string to file
        #----------------------------------------------
 	call tbhadt(tp,"HISTORY",Memc[p_hist])

        #----------------------------------------------
        # Free up memory
        #----------------------------------------------
        call sfree(sp)
end

