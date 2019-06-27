# $Header: /home/pros/xray/xspatial/eintools/src_cnts/RCS/sc_tools.x,v 11.0 1997/11/06 16:31:23 prosb Exp $
# $Log: sc_tools.x,v $
# Revision 11.0  1997/11/06 16:31:23  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:49:23  prosb
# General Release 2.4
#
#Revision 1.2  1994/08/04  14:43:46  dvs
#We don't really need the exposure maximum for these calculations;
#removed!  Thus the user could input an exposure image as opposed
#to a mask.
#
#Revision 1.1  94/03/15  09:10:18  prosb
#Initial revision
#
#
#--------------------------------------------------------------------------
# Module:       sc_tools.x
# Project:      PROS -- EINSTEIN TOOLS
# External:     src_cnts
# Internal:     sc_filtfile, sc_src_cts, ccc_calc
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1994.  You may do anything you like with this
#               file except remove this copyright.
# Modified:     {0} David Van Stone -- 3/94 -- initial version 
#               {n} <who> -- <when> -- <does what>
#--------------------------------------------------------------------------

include <regparse.h>
include <imhdr.h>

include "../tables/src.h"
include "../source/array.h"
include "../source/et_err.h"

#--------------------------------------------------------------------------
# Procedure:    src_cnts()
#
# Purpose:      Make source counts from QPOE file
#
# Input variables:
#               qpoe_name       input qpoe file name
#               qpoe_evlist     associated event list (e.g. "[time=10:50]")
#		src_name	input source file name
#               exp_name        input exposure mask name
#		pi_range	PI range to make counts for
#               br_edge_filt    filter to use to remove bright edge
#               src_rad         source radius
#               bkgd_ann_in     inner radius of bkgd annulus
#               bkgd_ann_out    outer radius of bkgd annulus
#               s_cmsc          circle mirror scat. corr. for soft band
#               s_cprc          circle point resp. corr. for soft band
#               h_cmsc          circle mirror scat. corr. for hard band
#               h_cprc          circle point resp. corr. for hard band
#               display         display level
#
# Output variables:
#		tot_counts	total counts in QPOE file from sources
#
# Description:  This is the main routine for the task src_cnts.
#		It will loop through all the sources in the source
#		table and find the counts in the image due to that
#		source, then return the final total.
#
#		If a source has negative counts, it will not count
#		towards the total.
#
#		There's some special maneuvering involving filter
#		files for this task.  There is a limit to the length
#		of a filter placed on a image file in the immap()
#		routine. (Currently limited to SZ_FNAME=64 chars.)
#		Thus we need to create a temporary file 
#		(tempfiltfile) to hold our filter and use "[@filename]"
#		as our filter to our QPOE file.
#
#		Do we need to consider the input file as a QPOE 
#		instead of an image?  We only open it with immap()
#		and use it as an image...but the bright edge filter
#		and the PI range are filters specifically for a
#		QPOE file.
#
#		The "ccc" is the circle composite correction, which
#		depends only on the PI band.  The "ccc" is the 
#		product of the cmsc and the cprc.  We choose either
#		the soft or hard band, based on the input pi_range.
#		If the pi_range includes hard values, (5 or above),
#		we use the hard ccc; otherwise we use the soft ccc.
#
# Algorithm:    * Create filter file and QPOE filter
#		* Open QPOE as image and open exposure file
#		* Open source file
#		* calculate the ccc
#		* Set aside space for data
#		* For each source, do the following
#		  * Read in source data
#		  * Calculate source counts for this source
#		  * Add to total counts
#		* Release memory and close files
#
# Note:		The exposure mask can be either a PL mask or an image.
#		The "exp_max" doesn't matter, since it is used on
#		both sides of the fraction during sc_src_cnts.
#--------------------------------------------------------------------------
procedure src_cnts(qpoe_name,qpoe_evlist,src_name,exp_name,
		      pi_range,br_edge_filt, src_rad, bkgd_ann_in,
		      bkgd_ann_out,s_cmsc, s_cprc, h_cmsc,
		      h_cprc, tot_counts,display )
char	qpoe_name[ARB]	  # i: input qpoe file name
char	qpoe_evlist[ARB]  # i: associated event list (e.g. "[time=10:50]")
char	src_name[ARB]	  # i: input source file name
char	exp_name[ARB]	  # i: input exposure mask name
char	pi_range[ARB]	  # i: PI range to make counts for
char	br_edge_filt[ARB] # i: filter to use to remove bright edge
double	src_rad		  # i: source radius
double	bkgd_ann_in	  # i: inner radius of bkgd annulus
double	bkgd_ann_out	  # i: outer radius of bkgd annulus
double	s_cmsc		  # i: circle mirror scat. corr. for soft band
double	s_cprc		  # i: circle point resp. corr. for soft band
double	h_cmsc		  # i: circle mirror scat. corr. for hard band
double	h_cprc		  # i: circle point resp. corr. for hard band
double	tot_counts	  # o: total number of counts due to sources
int     display           # i: display level (0-5)

### LOCAL VARS ###

double	ccc		# circle composite correction
pointer	col_ptr[N_COL_SRC]  # column pointers for source file
pointer	ip_qpoe		# image pointer to input qpoe
pointer ip_exp		# image pointer to exposure file
pointer	p_qpfilter     # filter to apply to QPOE upon opening
pointer	p_reg		# pointer to memory set aside for region strings
pointer	sp		# stack pointer
int	n_src		# number of rows of source table
int	i_src		# current row of source table
pointer	p_src		# pointer to source table
pointer p_src_info	# pointer to source table info (see gt_info.x)
double	src_counts	# counts due to current source
pointer	p_tempfiltfile  # pointer to filename for temporary filter
pointer	tp		# source table pointer

### EXTERNAL FUNCTION DECLARATIONS ###

double	ccc_calc() # returns circle composite correction [local]
int     gt_open()  # returns number of rows in table [../tables/gt_file.x]
pointer immap()    # returns pointer to image [sys/imio]
double	sc_src_cts() # returns number of counts due to source [local]

### BEGINNING OF PROCEDURE ###
	
begin
        #----------------------------------------------
        # set aside space for stack
        #----------------------------------------------
	call smark(sp)

        #--------------------------------------------------
        # create QPOE filter (pointing to temp filter file)
        #--------------------------------------------------
	call sc_filtfile(qpoe_name,qpoe_evlist,pi_range,br_edge_filt,
			    p_tempfiltfile,p_qpfilter,display)


        #--------------------------------------------------
        # open QPOE (as image) and exposure file
        #--------------------------------------------------
        ip_qpoe = immap(Memc[p_qpfilter], READ_ONLY, 0)
	ip_exp=immap(exp_name, READ_ONLY, 0)

        #----------------------------------------------
        # open source table
        #----------------------------------------------
        call src_setup(p_src_info)
        n_src = gt_open(src_name,READ_ONLY,tp,col_ptr,p_src_info)

        #----------------------------------------------
        # calculate ccc
        #----------------------------------------------
	ccc=ccc_calc(s_cmsc,s_cprc,h_cmsc,h_cprc,pi_range,display)

        #------------------------------------------------
        # set aside memory for source row & region string
        #------------------------------------------------
	call salloc(p_src,SZ_SRC,TY_STRUCT)
	call salloc(p_reg,SZ_REGINPUTLINE,TY_CHAR)

        #----------------------------------------------
        # loop through sources
        #----------------------------------------------
	tot_counts=0.0D0
	do i_src=1,n_src
	{
            #----------------------------------------------
            # get source position
            #----------------------------------------------
	    call gt_get_row(tp,p_src_info,col_ptr,i_src,true,p_src)

            #----------------------------------------------
            # calculate source counts
            #----------------------------------------------
	    src_counts=sc_src_cts(p_src,ip_qpoe,ip_exp,src_rad,
				bkgd_ann_in,bkgd_ann_out,ccc,
				Memc[p_reg],display)
	    if (display>1)
	    {
		call printf("Source (%.2f,%.2f) had %.2f counts.\n")
		 call pargd(SRC_X(p_src))
		 call pargd(SRC_Y(p_src))
		 call pargd(src_counts)
		if (src_counts<0.0D0)
		{
		   call printf("(Ignoring source because of negative counts.)\n")
		}
	    }

            #----------------------------------------------
            # add to running total
            #----------------------------------------------
	    tot_counts=tot_counts+MAX(0.0D0,src_counts)
	}

        #----------------------------------------------
        # delete temporary filter file
        #----------------------------------------------
	call delete(Memc[p_tempfiltfile])

        #----------------------------------------------
        # free memory and close files
        #----------------------------------------------
        call gt_free_info(p_src_info)
        call tbtclo(tp)
		
	call mfree(p_tempfiltfile,TY_CHAR)
	call mfree(p_qpfilter,TY_CHAR)
	call sfree(sp)
end

#--------------------------------------------------------------------------
# Procedure:    sc_filtfile
#
# Purpose:      Create temporary filter file and qpoe filter
#
# Input variables:
#               qpoe_name       input qpoe file name
#               qpoe_evlist     associated event list (e.g. "[time=10:50]")
#               pi_range        PI range to make counts for
#               br_edge_filt    filter to use to remove bright edge
#               display         display level
#
# Output variables:
#		p_tempfiltfile  filter file name
#		p_qpfilter	qpoe filter to use on opening qpoe
#
# Description:  This routine creates the qpoe filter to use on
#		opening the QPOE file as an image file.  It uses
#		mk_qpfilter (in ../source/bkmap.x) which creates
#		a qpoe filter used for eintools (using the event
#		list, PI range, and bright edge filter).
#
#		However, since we're opening the QPOE as an image
#		and there is a size restriction on the filter length,
#		we must instead write the filter to a file and
#		create a qpoe filter which reads in the filter
#		from the file.
#
#		The final filter will be of the form 
#		"[@'tempfilename']".  (Why are there single quotes
#		around the file name?  In case there is a pathname.)
#
# Notes:	We use "fprintf" to write the original qpoe filter
#		to the file.  The pargstr has a built in string
#		limit (of SZ_OBUF -- see sys/fmtio/pargstr.x), but
#		I believe this is overriden if we use "%.####s" as
#		the format string in fprintf, where #### is the
#		length of the string.
#--------------------------------------------------------------------------

procedure sc_filtfile(qpoe_name,qpoe_evlist,pi_range,br_edge_filt,
			    p_tempfiltfile,p_qpfilter,display)

char    qpoe_name[ARB]    # i: input qpoe file name
char    qpoe_evlist[ARB]  # i: associated event list (e.g. "[time=10:50]")
char    pi_range[ARB]     # i: PI range to make counts for
char    br_edge_filt[ARB] # i: filter to use to remove bright edge
pointer	p_tempfiltfile    # o: temporary filter file name
pointer p_qpfilter	  # o: final qpoe filter
int	display		  # i: display level

### LOCAL VARS ###

pointer	fd_temp		  # file descriptor for temporary file
int	filtname_len	  # length of final qpoe filter
char	format[SZ_LINE]	  # format string used in fprintf
pointer p_orig_qpfilter   # qpoe filter we need to write to file

### EXTERNAL FUNCTION DECLARATIONS ###

int     strlen() # returns length of string [sys/fmtio]
pointer	open()	 # returns pointer to new file descriptor [sys/fio]

### BEGINNING OF PROCEDURE ###

begin

        #----------------------------------------------
	# make temporary filter file.
        #----------------------------------------------
	call malloc(p_tempfiltfile,SZ_PATHNAME,TY_CHAR)	
	call mktemp("sctemp", Memc[p_tempfiltfile], SZ_PATHNAME )
	fd_temp=open(Memc[p_tempfiltfile],WRITE_ONLY,TEXT_FILE)

        #----------------------------------------------
	# make original qpoe filter
        #----------------------------------------------

	call mk_qpfilter(qpoe_evlist,br_edge_filt,pi_range,
			p_orig_qpfilter,display)

        #----------------------------------------------
	# creates string of form "%.###s\n", 
        #            where ### is length of qp filter.
        #----------------------------------------------
	call sprintf(format,SZ_LINE,"%%.%ds\n")
	 call pargi(strlen(Memc[p_orig_qpfilter]))

        #----------------------------------------------
        # Write filter to temporary file
        #----------------------------------------------
	call fprintf(fd_temp,format)
	 call pargstr(Memc[p_orig_qpfilter])

        #----------------------------------------------
	# close file and free space from filter
        #----------------------------------------------
	call close(fd_temp)
	call mfree(p_orig_qpfilter,TY_CHAR)
	 
        #----------------------------------------------
	# set aside space for new filter.
	# The extra 5 characters are [@''].
        #----------------------------------------------
	filtname_len=strlen(qpoe_name)+strlen(Memc[p_tempfiltfile])+5
	call malloc(p_qpfilter,filtname_len,TY_CHAR)

        #----------------------------------------------
	# create new filter
        #----------------------------------------------
	call strcpy(qpoe_name,Memc[p_qpfilter],filtname_len)
        call strcat("[@'",Memc[p_qpfilter],filtname_len)
        call strcat(Memc[p_tempfiltfile],Memc[p_qpfilter],filtname_len)
        call strcat("']",Memc[p_qpfilter],filtname_len)

	if (display>4)
	{
	   call printf("New qpoe filter:%s.\n")
	    call pargstr(Memc[p_qpfilter])
	}
end

#--------------------------------------------------------------------------
# Procedure:    sc_src_cts
#
# Purpose:      Find the number of counts due to source in image
#
# Input variables:
#		p_src		pointer to source record [see src.h]
#		ip_image	image pointer for image
#		ip_exp		image pointer for exposure file
#               src_rad         source radius
#               bkgd_ann_in     inner radius of bkgd annulus
#               bkgd_ann_out    outer radius of bkgd annulus
#		ccc 		circle composite correction
#		reg		string set aside for region
#               display         display level
#
# Return value: Returns number of counts due to source
#
# Description:  This procedure finds the number of counts for the
#		passed in source using the following formula:
#
#		cts = ccc * (src_cts - bkgd_cts*(src_area/bkgd_area))
#
#		The "ccc" is the circle composite correction, which
#		accounts for scattering and point response corrections.
#
#		The src_cts is the number of counts in the circle
#		(of radius src_rad) in the image.
#
#		The bkgd_cts is the number of counts in the annulus
#		in the image.
#
#		In order to find the source and background areas, we
#		use the exposure mask.  For instance, the src_area
#		is the number of counts in the exposure mask in
#		the source circle divided by exp_max.  (Thus if
#		there is full exposure in the circle, src_area will
#		be the number of pixels in the source circle times
#		the maximum exposure level.)
#
#		If the background area is 0.0, we set the number of
#		counts to 0.0 and display a warning.
#
#		We expect the variable "reg" to be a string of size
#		SZ_REGINPUTLINE with memory already set aside for it.
#
# Note:		We don't need to know the maximum exposure level
#		because we only need to know the ratio between the
#		source and bkgd areas.
#--------------------------------------------------------------------------

double procedure sc_src_cts(p_src,ip_image,ip_exp,
		src_rad,bkgd_ann_in,bkgd_ann_out,ccc,reg,display)
pointer	p_src		# i: pointer to source record
pointer	ip_image	# i: image pointer for image
pointer	ip_exp		# i: image pointer for exposure
double  src_rad         # i: source radius
double  bkgd_ann_in     # i: inner radius of bkgd annulus
double  bkgd_ann_out    # i: outer radius of bkgd annulus
double	ccc		# i: circle composite correction
char    reg[SZ_REGINPUTLINE]  # i: string for region descriptor
int     display         # i: display level (0-5)

### LOCAL VARS ###

double	area		# temporary value for im_cts()
double	ann_exp_counts  # annulus exp counts [bkgd_area]
double	ann_im_counts   # annulus image counts [bkgd_cts]
double	cir_exp_counts  # circle exp counts [src_area]
double	cir_im_counts   # circle image counts [src_cts]
double	final_src_cts   # source counts for the source

### EXTERNAL FUNCTION DECLARATIONS ###

double	im_cts()	# returns number of counts in image 
			# [lib/pros/im_cts.x]
bool	fp_equald()	# returns true if doubles are equal [sys/gio]

### BEGINNING OF PROCEDURE ###

begin
        #---------------------------------------------------
        # find counts and exposure for CIRCLE around source
        #---------------------------------------------------
        call sprintf(reg,SZ_REGINPUTLINE,"circle %.2f %.2f %.2f")
         call pargd(SRC_X(p_src))
         call pargd(SRC_Y(p_src))
         call pargd(src_rad)

	cir_im_counts=im_cts(ip_image,reg,area)
	cir_exp_counts=im_cts(ip_exp,reg,area)

	if (display>4)
	{
	   call printf("Using region=%s, imcts=%.2f, expcts=%.2f.\n")
	    call pargstr(reg)
	    call pargd(cir_im_counts)
	    call pargd(cir_exp_counts)
	   call flush(STDOUT)
	}

        #---------------------------------------------------
        # find counts and exposure for ANNULUS around source
        #--------------------------------------------------
        call sprintf(reg,SZ_REGINPUTLINE,"ann %.2f %.2f %.2f %.2f")
         call pargd(SRC_X(p_src))
         call pargd(SRC_Y(p_src))
         call pargd(bkgd_ann_in)
         call pargd(bkgd_ann_out)

	ann_im_counts=im_cts(ip_image,reg,area)
	ann_exp_counts=im_cts(ip_exp,reg,area)
	
	if (display>4)
	{
	   call printf("Using region=%s, imcts=%.2f, expcts=%.2f.\n")
	    call pargstr(reg)
	    call pargd(ann_im_counts)
	    call pargd(ann_exp_counts)
	   call flush(STDOUT)
	}

        #-----------------------------------------------
	# Find final source cts.  If annulus exposure
	# is 0.0, set src_cts to 0.0.  Else use formula.
        #-----------------------------------------------
	if (fp_equald(ann_exp_counts,0.0D0))
	{
	    final_src_cts=0.0D0
	    if (display>0)
	    {
	    	call printf("\nWARNING: The annulus around the source at (%.2f,%.2f) had no\n")
		 call pargd(SRC_X(p_src))
		 call pargd(SRC_Y(p_src))
		call printf("counts in the exposure file.  We will not use this source.\n")
		call flush(STDOUT)
	    }
	}
	else
	{
	    final_src_cts=ccc*(cir_im_counts-
				ann_im_counts*cir_exp_counts/ann_exp_counts)
	}
	
        #----------------------------------------------
	# return final source counts
        #----------------------------------------------
	return final_src_cts
end


#--------------------------------------------------------------------------
# Procedure:    ccc_calc
#
# Purpose:      Calculate circle composite correction
#
# Input variables:
#               s_cmsc          circle mirror scat. corr. for soft band
#               s_cprc          circle point resp. corr. for soft band
#               h_cmsc          circle mirror scat. corr. for hard band
#               h_cprc          circle point resp. corr. for hard band
#		pi_range	PI range of QPOE
#               display         display level
#
# Returns value: returns circle composite correction!
#
# Description:  The circle composite correction has a simple
#		formula:
#			ccc = cmsc * cprc
#
#		We simply have to decide which cmsc & cprc values
#		to use: hard or soft.  We use the PI range to make
#		this decision.  If any of the range values fall in
#		the hard band, we use the hard cmsc & cprc; else
#		we use the soft cmsc & cprc.
#--------------------------------------------------------------------------

double procedure ccc_calc(s_cmsc,s_cprc,h_cmsc,h_cprc,pi_range,display)

double  s_cmsc            # i: circle mirror scat. corr. for soft band
double  s_cprc            # i: circle point resp. corr. for soft band
double  h_cmsc            # i: circle mirror scat. corr. for hard band
double  h_cprc            # i: circle point resp. corr. for hard band
char	pi_range[ARB]     # i: PI range
int	display		  # i: display level (0-5)

### LOCAL VARS ###

double 	ccc 	   # ccc to return
int	last_pi    # highest PI value in range
int	n_pi	   # number of PI values in range
pointer	p_pi_list  # pointer to list of PI values from range

### BEGINNING OF PROCEDURE ###

begin
        #----------------------------------------------
	# convert PI range into a list of values
	# (code in ../source/pirange.x)
        #----------------------------------------------
	call range2list(pi_range,n_pi,p_pi_list)

	if (n_pi==0)
	{
	    call errori(1,"PI range is empty")
	}

        #----------------------------------------------
	# Find the highest (i.e. last) value in range
        #----------------------------------------------
	last_pi=ARRELE_I(p_pi_list,n_pi)

        #----------------------------------------------
	# Determine if last PI is still soft; if so,
	# use soft cmsc & cprc, else use hard.
        #----------------------------------------------
	if (last_pi<5)  # magic number: pi's below 5 are SOFT.
	{
	    ccc=s_cmsc*s_cprc
	    if (display>3)
	    {
		call printf("All PI values are soft -- using soft CCC.\n")
	    }
	}
	else
	{
	    ccc=h_cmsc*h_cprc
	    if (display>3)
	    {
		call printf("Some PI values are hard -- using hard CCC.\n")
	    }
	}
	
        #----------------------------------------------
	# clear memory for PI list
        #----------------------------------------------
	call mfree(p_pi_list,TY_INT)

        #----------------------------------------------
	# return final circle composite correction
        #----------------------------------------------
	return ccc
end
