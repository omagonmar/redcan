# $Header: /home/pros/xray/xspatial/eintools/source/RCS/bkmap.x,v 11.0 1997/11/06 16:31:32 prosb Exp $
# $Log: bkmap.x,v $
# Revision 11.0  1997/11/06 16:31:32  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:49:41  prosb
# General Release 2.4
#
#Revision 1.4  1994/10/06  13:12:49  dvs
#Reduced sensitivity for comparison of nominal ra & dec between
#QPOE and BKFAC table.
#
#Revision 1.3  94/09/08  11:37:36  dvs
#Changed pirange to pi_range to be consistent.
#
#Revision 1.2  94/08/04  14:13:29  dvs
#Made check_nom routine less sensitive.
#
#Revision 1.1  94/03/15  09:13:05  prosb
#Initial revision
#
#
#--------------------------------------------------------------------------
# Module:       bkmap.x
# Project:      PROS -- EINSTEIN TOOLS
# External:     get_dstime,range2band,beds_param,
#		beds_check_pi,check_nom,mk_qpfilter,get_wld_center
# Local:	get_pirange
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1994.  You may do anything you like with this
#               file except remove this copyright.
# Modified:     {0} David Van Stone -- 2/94 -- initial version
#               {n} <who> -- <when> -- <does what>
#--------------------------------------------------------------------------
#
#  This module is for general routines which are used throughout the
#  background map making code in EINTOOLS.  Anything which didn't
#  fit anywhere else ended up in here.
#
#--------------------------------------------------------------------------

include "band.h"
include "pirange.h"
include "../tables/bkfac.h"
include <qpoe.h>

#--------------------------------------------------------------------------
# Procedure:    get_dstime
#
# Purpose:      Returns the deep survey live time from image.
#
# Input variables:
#               ip		deep survey image pointer
#
# Return value:
#		(double)	deep survey live time
#
# Description:  This procedure will check that the deep survey map
#		has a livetime keyword, then return that value.
#		
#		The livetime can not be 0.0
#--------------------------------------------------------------------------

define DSTIME_KYWD "LIVETIME"

double procedure get_dstime(ip)
pointer ip		# i: DS image

### LOCAL VARS ###

double	dstime          # DS livetime

### EXTERNAL FUNCTION DECLARATIONS ###

int     imaccf()        # returns YES/NO if image has keyword [SYS/IMIO]
double	imgetd()	# returns image keyword [SYS/IMIO]
bool	fp_equald()	# returns true if doubles are equal [sys/gio]

### BEGINNING OF PROCEDURE ###

begin
	if (imaccf(ip,DSTIME_KYWD)==NO)
	{
	   call errstr(1,
		"DS map does not contain livetime keyword",DSTIME_KYWD)
	}

	dstime=imgetd(ip,DSTIME_KYWD)

	if (fp_equald(dstime,0.0D0))
	{
	   call error(1,"Deep survey map livetine is 0.0")
	}

	return dstime
end

#--------------------------------------------------------------------------
# Procedure:    get_pirange
#
# Purpose:      Returns the pi band from the image
#
# Input variables:
#               ip              deep survey image pointer
#		piband_len	length of piband string.
#
# Output variables:
#               piband          pi band from image
#
# Description:  This routine will fill in the passed in piband
#		string with the value from the header keyword
#		in the (assumed to be deep survey map) image.
#		
#		(Note that in this case, "piband" is just the
#		 header keyword value.  It will actually appear
#		 as a range, such as "2:4" or "6:7,9:10".)
#--------------------------------------------------------------------------
define PIRANGE_KYWD "PIBAND"

procedure get_pirange(ip,pi_range,pi_range_len)
pointer ip              # i: DS image
char	pi_range[ARB]	# o: returned pi-band
int	pi_range_len	# i: length set aside for pi_range string.

int     imaccf()        # returns YES/NO if image has keyword [SYS/IMIO]

begin
	if (imaccf(ip,PIRANGE_KYWD)==NO)
	{
	   call errstr(1,
		"DS map does not contain pirange keyword",PIRANGE_KYWD)
	}
	call imgstr(ip,PIRANGE_KYWD,pi_range,pi_range_len)
end

#--------------------------------------------------------------------------
# Procedure:    range2band
#
# Purpose:      Converts a PI range into set of possible bands
#
# Input variables:
#               pi_range	input PI range (e.g. "2:5", "0:15", etc.)
#
# Output variables:
#               band		integer index of bands (see band.h)
#
# Description:  This routine will describe whether the passed in
#		range is either SOFT, HARD, BROAD, or OTHER.
#--------------------------------------------------------------------------

procedure range2band(pi_range,band)
char	pi_range[ARB]	# i: input PI range
int	band		# o: output band
bool	streq()		# TRUE if strings are equal [sys/fmtio]
begin
	if (streq(pi_range,EIN_SOFT_RANGE))
	{
	   band=SOFT_BAND
	}
	else if (streq(pi_range,EIN_HARD_RANGE))
	{
	   band=HARD_BAND
	}
	else if (streq(pi_range,EIN_BROAD_RANGE))
	{
	   band=BROAD_BAND
	}
	else
	{
	   band=OTHER_BAND
	}
end

#--------------------------------------------------------------------------
# Procedure:    beds_param
#
# Purpose:      Reads in the appropriate bright Earth or 
#		deep survey parameter given the PI band
#
# Input variables:
#               band		integer index of bands (see band.h)
#
# Output variables:
#               bemap, dsmap	file names of the appropriate bright
#				Earth and deep survey maps            
#
# Description:  If the user requests default bright Earth or deep
#		survey maps to be used AND the band is one of SOFT,
#		HARD, or BROAD, then this routine will read in from
#		the appropriate default be & ds parameters for the
#		filenames.  Otherwise it reads in from the standard
#		"bemap" and "dsmap" parameters.
#
#		To use this routine, the parameters must be EXACTLY
#		as they are in this routine.  The default file names
#		should be hidden parameters, while "bemap" and "dsmap"
#		should be automatic.
#
# Note:		The variables bemap and dsmap should be at least
#		SZ_PATHNAME in length
#--------------------------------------------------------------------------
procedure beds_param(band,bemap,dsmap)
int	band		    # i: which band (soft, hard, broad, other)
char	bemap[SZ_PATHNAME]  # o: bright Earth filename
char	dsmap[SZ_PATHNAME]  # o: deep survey filename

bool	defmaps		# Should we use default maps?

bool	clgetb()	# returns boolean parameter [sys/clio]

begin
        #----------------------------------------------
        # Set defmaps
        #----------------------------------------------
	if (band!=OTHER_BAND)
	{
	   defmaps=clgetb("defmaps")	   
	}
	else
	{
	   defmaps=false
	}

        #----------------------------------------------
        # If we're using default maps, read them in!
	# Otherwise, read in from automatic params.
        #----------------------------------------------
	if (defmaps)
	{
	    switch(band)
	    {
		case SOFT_BAND:
        	 call clgstr("def_be_soft",bemap,SZ_PATHNAME)
        	 call clgstr("def_ds_soft",dsmap,SZ_PATHNAME)
		case HARD_BAND:
        	 call clgstr("def_be_hard",bemap,SZ_PATHNAME)
        	 call clgstr("def_ds_hard",dsmap,SZ_PATHNAME)
		case BROAD_BAND:
        	 call clgstr("def_be_broad",bemap,SZ_PATHNAME)
        	 call clgstr("def_ds_broad",dsmap,SZ_PATHNAME)
		default:
		 call error(1,"Unknown band")
	    }
	}
	else
	{
           call clgstr("bemap",bemap,SZ_PATHNAME)
           call clgstr("dsmap",dsmap,SZ_PATHNAME)
	}


end

#--------------------------------------------------------------------------
# Procedure:    beds_check_pi
#
# Purpose:      This will check that the PI ranges within the bright
#		Earth and deep survey maps match the passed in range.
#
# Input variables:
#               ip_be,ip_ds	bright Earth and deep survey maps
#		pi_range	PI range to check
#               display         text display level (0=none, 5=full)
#
# Description:  Displays a warning if the PI range doesn't match
#		between the passed in PI range and the header keyword
#		stored in either the bright Earth or deep survey maps.
#
#		(This helps prevent users from mistakenly using the
#		 wrong set of DS and BE maps.)
#--------------------------------------------------------------------------

procedure beds_check_pi(ip_be,ip_ds,pi_range,display)
pointer	ip_be		# i: bright Earth map
pointer	ip_ds		# i: deep survey map 
char	pi_range[ARB]	# i: PI range to check
int	display		# i: display

pointer	p_im_pirange	# pointer to PI range read from image

bool	streq()		# TRUE if strings are equal [sys/fmtio]

begin
        #----------------------------------------------
        # Set aside memory for image PI range
        #----------------------------------------------
 	call malloc(p_im_pirange,SZ_LINE,TY_CHAR)

	#----------------------------------------------
        # Check PI range in bright Earth map!
        #----------------------------------------------
	call get_pirange(ip_be,Memc[p_im_pirange],SZ_LINE)
        call strip_whitespace(Memc[p_im_pirange])
	
	if (!streq(pi_range,Memc[p_im_pirange]) && display>0)
	{
	    call printf("\nWARNING: Bright Earth PI band differs:\n")
	    call printf("Found (%s), expected (%s).\n")
	     call pargstr(Memc[p_im_pirange])
	     call pargstr(pi_range)
	    call flush(STDOUT)
	}
	
	#----------------------------------------------
        # Check PI range in deep survey map!
        #----------------------------------------------
	call get_pirange(ip_ds,Memc[p_im_pirange],SZ_LINE)
        call strip_whitespace(Memc[p_im_pirange])

	if (!streq(pi_range,Memc[p_im_pirange]) && display>0)
	{
	    call printf("\nWARNING: Deep survey PI band differs:\n")
	    call printf("Found (%s), expected (%s).\n")
	     call pargstr(Memc[p_im_pirange])
	     call pargstr(pi_range)
	    call flush(STDOUT)
	}

        #----------------------------------------------
        # Free memory
        #----------------------------------------------
 	call mfree(p_im_pirange,TY_CHAR)
end


#--------------------------------------------------------------------------
# Procedure:    check_nom
#
# Purpose:      This will check that the background factors table
#		has the same nominal RA and DEC as the QPOE file.
#
# Input variables:
#               qphead		QPOE header structure
#		tp_bkf		BKFAC table
#               display         text display level (0=none, 5=full)
#
# Description:  Displays a warning if the nominal RA or DEC doesn't
#		match between the BKFAC table and the QPOE file.
#
#		The BKFAC table stores these values in header keywords
#		when it is created.  (See bkfac.h)
#
#		(Hence, this helps prevent against a BKFAC table
#		 being used for the wrong QPOE file.)
#--------------------------------------------------------------------------
procedure check_nom(qphead,tp_bkf,display)
pointer qphead		# i: QPOE header
pointer tp_bkf		# i: BKFAC table
int     display		# i: display value

real    nomra		# nominal RA from BKFAC table
real    nomdec		# nominal DEC from BKFAC table

real    tbhgtr()	# returns "real" table header parameter [tables]

begin
        #----------------------------------------------
        # Read in nominal RA and DEC from table
        #----------------------------------------------
        nomra=tbhgtr(tp_bkf,BK_NOMRA)
        nomdec=tbhgtr(tp_bkf,BK_NOMDEC)

        #----------------------------------------------
        # Compare against QPOE file.
        #----------------------------------------------
        if (display>0 && !((abs(nomra-QP_RAPT(qphead))<0.001) &&
                           abs(nomdec-QP_DECPT(qphead))<0.001) )
        {
            call printf("\nWARNING: Nominal RA & DEC don't match between BKFAC table and QPOE files.\n")
            call flush(STDOUT)
        }       
end     


#--------------------------------------------------------------------------
# Procedure:    mk_qpfilter
#
# Purpose:      To create a string filter for a QPOE file for eintools
#
# Input variables:
#               qpoe_evlist	QPOE event list [output from qp_parse]
#		br_edge_filt	bright edge filter 
#		pi_range	range of PI values
#               display         text display level (0=none, 5=full)
#
# Output variables:
#		p_qpfilter	pointer to output QPOE filter [no brackets]
#
# Description:  This is a routine specific to the EINTOOLS package.  It
#		will create a string filter to be used in filtering the
#		QPOE file.  [See lib/pros/strfilter.x]
#
#		The qpoe_evlist is the user-defined event list for the
#		QPOE file.  (This is assumed to have brackets still.)
#		The string "br_edge_filt" is a filter for removing the
#		bright edge on the QPOE file.  (It should have 
#		no brackets.)  And "pi_range" is a range of PI values, in
#		the form "2:4" or "5:6,8:12".
#
#		This routine will return a filter (without brackets) which
#		will filter the QPOE file using the event list, the bright
#		edge filter and the PI range.
#
#		For example, if the event list is "time=8000:9000", the
#		bright edge filter is "detx=287:738,dety=287:738" and
#		the PI range is "2:4", the final filter will be:
#		  "time=8000:9000,detx=287:738,dety=287:738,pi=2:4".
#
#		Memory is set aside for the output filter.
#--------------------------------------------------------------------------
procedure mk_qpfilter(qpoe_evlist,br_edge_filt,pi_range,p_qpfilter,display)
char	qpoe_evlist[ARB]	# i: QPOE event list
char	br_edge_filt[ARB]	# i: bright edge filter
char	pi_range[ARB]		# i: PI range
pointer	p_qpfilter		# o: pointer to QPOE filter
int	display			# i: display level

### LOCAL VARS ###

int	filter_len		# string length of output filter

### EXTERNAL FUNCTION DECLARATIONS ###

int     strlen()        # returns length of string [sys/fmtio]

### BEGINNING OF PROCEDURE ###

begin
        #----------------------------------------------
        # Remove bracket from QPOE eventlist
        #----------------------------------------------
	call rm_brack(qpoe_evlist,p_qpfilter)

        #---------------------------------------------------------
	# Find the filter length by summing the lengths of the
	# components and adding "7" for the number of extra
	# characters we will be adding (",pi=(),")
        #---------------------------------------------------------
	filter_len=strlen(pi_range)+
			strlen(br_edge_filt)+strlen(Memc[p_qpfilter])+7

        #----------------------------------------------
        # Reallocate space in p_qpfilter for this.
        #----------------------------------------------
	call realloc(p_qpfilter,filter_len,TY_CHAR)

        #---------------------------------------------------------
        # qp_filter = event_filter + br_edge_filt + pi_range!
	# (Note: can't use sprintf because strings may be too
	#  long!)
        #---------------------------------------------------------
        call strcat(",pi=(",Memc[p_qpfilter],filter_len)
        call strcat(pi_range,Memc[p_qpfilter],filter_len)
	call strcat("),",Memc[p_qpfilter],filter_len)
        call strcat(br_edge_filt,Memc[p_qpfilter],filter_len)

	if (display>4)
	{
	   call printf("QPOE filter: %s.\n")
	    call pargstr(Memc[p_qpfilter])
	# NOTE: if string is over 1024 chars, this print will not work!
	}
end


#--------------------------------------------------------------------------
# Procedure:    get_wld_center
#
# Purpose:      returns world coordinates of point of rotation for 
#		aspecting routines
#
# Input variables:
#               r_qp            reference point of QPOE file
#               ct		coordinate transformation descriptor
#		roll		nominal roll
#		aspx,aspy	aspect x,y
#               display         text display level (0=none, 5=full)
#
# Output variables:
#		wldx,wldy	output world coordinates
#
# Description:  This routine is a very specifically for converting
#		aspect information into RCRVL1 and RCRVL2 WCS values
#		for the CAT and BKFAC tables.
#
#		The variable r_qp stores the reference point of the
#		QPOE file, i.e., the x and y locations of the center
#		of the image (given by the WCS values CRPIX1 & CRPIX2).
#
#		The pointer "ct" is the coordinate transformation
#		descriptor obtained by mw_sctran [sys/mwcs], for 
#		example.  We expect the transformation to be
#		between the logical and world coordinates:
#		    mw = qp_loadwcs(qp)
#		    ct = mw_sctran(mw,"logical","world",3B)
#		We can thus use mw_c2trand to map between logical
#		coordinates and world coordinates.
#
#		roll, aspx, and aspy are the nominal roll and aspect
#		x and y offsets readable from the BLT records of the
#		qpoe file.  The aspect x and y offsets must first
#		be rotated by the nominal roll before they are applied
#		to the final mapping.
#
#		Let rot_aspx and rot_aspy be the rotated values of
#		these aspect offsets.  Then this routine returns the
#		offsets added to the center of the image mapped into
#		world coordinates.
#
#		This point describes where CRPIX1 and CRPIX2 will be
#		mapped into by the linear transformation described
#		by the aspect values.
#
# Note:		We lose precision in this routine because the
#		pros library routine asp_rotcoords only uses
#		real (and not double-precision) values.
#--------------------------------------------------------------------------

procedure get_wld_center(r_qp,ct,roll,aspx,aspy,wldx,wldy,display)
double  r_qp[2]		# i: reference point of QPOE file
pointer	ct		# i: coordinate transformation descriptor
double	roll		# i: nominal roll
double	aspx		# i: aspect x offset
double	aspy		# i: aspect y offset
double	wldx		# o: output world coordinate, x
double	wldy		# o: output world coordinate, y
int     display         # i: text display level (0=none, 5=full)

### LOCAL VARS ###
real	rot_aspx	# rotated aspect x offset
real	rot_aspy	# rotated aspect y offset

### BEGINNING OF PROCEDURE ###

begin
        #----------------------------------------------
        # rotate the aspect offsets
        #----------------------------------------------
        call asp_rotcoords(real(aspx),real(aspy),real(roll),rot_aspx,rot_aspy)

        #----------------------------------------------
        # find the world coordinates
        #----------------------------------------------
        call mw_c2trand(ct,double(rot_aspx)+r_qp[1],double(rot_aspy)+r_qp[2],
			wldx,wldy)

	if (display>4)
	{
	   call printf("\nRotated aspx,aspy=%f,%f.\n")
	    call pargd(rot_aspx+r_qp[1])
	    call pargd(rot_aspy+r_qp[2])
	   call printf("World coords=%f,%f.\n")
	    call pargd(wldx)
	    call pargd(wldy)
	}
end
