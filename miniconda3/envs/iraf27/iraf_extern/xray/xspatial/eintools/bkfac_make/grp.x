# $Header: /home/pros/xray/xspatial/eintools/bkfac_make/RCS/grp.x,v 11.0 1997/11/06 16:30:47 prosb Exp $
# $Log: grp.x,v $
# Revision 11.0  1997/11/06 16:30:47  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:48:31  prosb
# General Release 2.4
#
#Revision 1.1  1994/03/23  08:54:06  prosb
#Initial revision
#
#
#--------------------------------------------------------------------------
# Module:       grp.x
# Project:      PROS -- EINSTEIN TOOLS
# External:     group_asp
# Local:        match_asp, asp_off_diff, mk_new_grp
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1994.  You may do anything you like with this
#               file except remove this copyright.
# Modified:     {0} David Van Stone -- 2/94 -- initial version 
#               {n} <who> -- <when> -- <does what>
#--------------------------------------------------------------------------
#
#  GRP.X contains the main routine group_data which will group
#  together aspect data which are "close" enough.  Though this routine
#  has a similar purpose to the routines in BIN.X (which is more
#  general), the purpose of this code is to duplicate the routines
#  in the Einstein Level One Processing in IBKGD_MAP/GROUP_HUTS.
#
#--------------------------------------------------------------------------

include "../source/array.h"
include "../source/asp.h"
include <mach.h>

#--------------------------------------------------------------------------
# Procedure:    group_asp
#
# Purpose:      Group together aspect data which are "close".
#
# Input variables:
#               n_asp           number of aspect records to group
#               p_asp           aspect data (see asp.h for structure)
#		max_off_diff	maximum offset difference (in pixels)
#		dist_to_edge	how far away is the edge of the field?
#				(in pixels)
#               display         text display level (0=none, 5=full)
#
# Output variables:
#               n_grp		number of groups
#		p_grp		pointer to output data 
#               p_asp2grp       integer index mapping aspect to group
#				data
#
# Description:  This routine will search through each aspect record
#		and place it into an already formed group whose aspect
#		is "close" to this aspect record.  If there is no such
#		group, a new group is formed with this record.
#
#		The concept of "close" is adjusted by the input
#		variable "max_off_diff" which indicates the number
#		of pixels which the edge of the field is allowed
#		to move (in pixels).  Two aspect records are 
#		automatically considered not "close" if their
#		nominal roll's differ.
#
#		See the routine "asp_off_diff" for more specifics
#		on how two sets of aspect values are considered close.
#
#		On output, the pointer p_grp will point to the grouped
#		data (stored in the same data structure as aspect data).
#		The aspect information is copied from the first aspect
#		record which was considered to be part of the group.
#
#		The index "p_asp2grp" shows where aspect record was
#		placed in the group data structure.
#
# Algorithm:    * Set aside space for arrays, structures
#               * For each aspect record, do the following:
#		  * Check if current record matches any previous group
#		  * If so, adjust asp2grp array to indicate this.
#		  * If not, create a new group:
#		    * If we need more memory, reallocate group structure
#		    * Make a new group with this aspect record.
#
# Note:         The constant GRP_MEM_BUF is the size we initially allocate
#               to the GRP structure.  If we need more memory, we
#               allocate an additional GRP_MEM_BUF records.
#--------------------------------------------------------------------------



define GRP_MEM_BUF 20

procedure group_asp(p_asp,n_asp,max_off_diff,dist_to_edge,  
		    p_grp, n_grp, p_asp2grp, display)

int     p_asp           # i: pointer to ASP info
int     n_asp           # i: number of ASP records
double 	max_off_diff    # i: maximum offset difference (in pixels)
double 	dist_to_edge	# i: how far away is the edge of the field?
pointer p_grp           # o: pointer to output grouped data 
int     n_grp           # o: number of groups
pointer p_asp2grp       # o: index between asp and group structures
int     display         # i: text display level (0=none, 5=full)

### LOCAL VARS ###

int 	i_asp		# aspect structure index
pointer c_asp		# pointer to current aspect record
int 	i_grp		# group structure index
int 	m_grp		# current max. size of groups structure

### EXTERNAL FUNCTION DECLARATIONS ###

bool 	match_asp()	# returns true if aspect is in a group [local]

### BEGINNING OF PROCEDURE ###

begin
        #----------------------------------------------
        # Set aside space for structures
        #----------------------------------------------
    	call malloc (p_asp2grp, n_asp, TY_INT)
    	m_grp=GRP_MEM_BUF
    	call malloc (p_grp, m_grp*SZ_ASP, TY_DOUBLE)
 
        #----------------------------------------------
        # loop on ASP records
        #----------------------------------------------
    	n_grp=0
    	do i_asp=1,n_asp
    	{
	    c_asp=ASP(p_asp,i_asp)

            #----------------------------------------------
            # is ASP record close to a group?
            #----------------------------------------------
	    if (match_asp(c_asp,max_off_diff,dist_to_edge,
			p_grp,n_grp,i_grp))
	    {
                #----------------------------------------------
                # update asp2grp array!
                #----------------------------------------------
		ARRELE_I(p_asp2grp,i_asp]=i_grp

	    	if (display>4)
	    	{
		    call printf("Added asp to grp %d.\n")
		     call pargi(i_grp)
	        }
	    }
	    else
	    {
                #----------------------------------------------
                # We must add a new group.  Increment n_grp
                #----------------------------------------------
	   	n_grp=n_grp+1

                #----------------------------------------------
                # update asp2grp array!
                #----------------------------------------------
 	   	ARRELE_I(p_asp2grp,i_asp)=n_grp

	        #----------------------------------------------
        	# Check if we need to add more memory.
        	#----------------------------------------------
	   	if (n_grp>m_grp)
	   	{
	      	    m_grp=m_grp+GRP_MEM_BUF
	      	    call realloc(p_grp, m_grp*SZ_ASP, TY_DOUBLE)
	   	}

                #----------------------------------------------
                # fill in data for new group
                #----------------------------------------------
	   	call mk_new_grp(c_asp,ASP(p_grp,n_grp))

	   	if (display>4)
	   	{
		    call printf("Creating grp %d.\n")	
		     call pargi(n_grp)
	   	}
	    }
    	}
end



#--------------------------------------------------------------------------
# Procedure:    match_asp
#
# Purpose:      Determine if aspect matches any already created group
#
# Input variables:
#               p_asp           aspect data to check
#               max_off_diff    maximum offset difference (in pixels)
#               dist_to_edge    how far away is the edge of the field?
#                               (in pixels)
#               n_grp           number of groups already created
#               p_grp           pointer to group data
#
# Output variables:
#               i_grp           index of group which matched aspect
#
# Return value:
#		Returns TRUE if a match was found, FALSE otherwise
#
#
# Description:  This routine will loop through the structure of groups
#		to find a match with the passed in aspect record.  A
#		"match" occurs if the aspect in the group and the passed
#		in aspect are "close", i.e., if the difference in
#		aspects (from asp_off_diff) is less than "max_off_diff".
#
#--------------------------------------------------------------------------

bool procedure match_asp(p_asp,max_off_diff,dist_to_edge,
			  p_grp,n_grp,i_grp)
int     p_asp           # i: pointer to ASP info
double  max_off_diff    # i: maximum offset difference (in pixels)
double  dist_to_edge    # i: how far away is the edge of the field?
pointer p_grp           # i: pointer to grouped data 
int     n_grp           # i: number of groups
int 	i_grp		# o: index of group which matched aspect

### LOCAL VARS ###

pointer c_grp		# pointer to current group record
bool 	is_match	# TRUE if match is found, FALSE otherwise

### EXTERNAL FUNCTION DECLARATIONS ###

double 	asp_off_diff()	# returns distance between aspects [local]
bool    fp_equald()     # returns true if doubles are equal [sys/gio]

### BEGINNING OF PROCEDURE ###

begin
        #-----------------------------------------------------
        # Loop over groups.  Stop looping if a match is found.
        #-----------------------------------------------------
   	is_match=false
   	for (i_grp=1; !(is_match) && i_grp<=n_grp; i_grp=i_grp+1)
   	{	
            #----------------------------------------------
            # Check if aspect matches this group
            #----------------------------------------------
       	    c_grp=ASP(p_grp,i_grp)

       	    is_match=((fp_equald(ASP_ROLL(c_grp),ASP_ROLL(p_asp))) &&
		     (asp_off_diff(p_asp,c_grp,
				dist_to_edge)<=max_off_diff))
   	}

        #-----------------------------------------------------
        # Note that we will always go one group too far in our
	# search -- decrement i_grp to compensate.
        #-----------------------------------------------------
   	i_grp=i_grp-1

        #-----------------------------------------------------
        # Return TRUE if match was found, FALSE otherwise
        #-----------------------------------------------------
   	return is_match
end

#--------------------------------------------------------------------------
# Procedure:    asp_off_diff
#
# Purpose:      Returns difference between two sets of aspect offsets
#
# Input variables:
#               p_asp1          first aspect record
#               p_asp2          second aspect record
#               dist_to_edge    how far away is the edge of the field?
#                               (in pixels)
#
# Return value:
#               Returns distance between aspects
#
# Description:  This routine will find the "distance" between two
#		aspect records.  This "distance" is supposed to be
#		the number of pixels the edge of the field moves between
#		these two pixels.
#
#		More explicitly, we find the difference between the
#		two aspect roll offsets and see how that effects the
#		edge of the field:
#
#		    edge_pix = dist_to_edge * tan (aspect_roll diff)
#
#		We then add the square of the difference in aspect x
#		and aspect y:
#
#		    off_diff = (aspect_x diff)^2 + (aspect_y diff)^2 +
#				edge_pix 
#
#		This is what we consider the difference.
#
# Note:		If the aspect_roll difference is some odd multiple of
#		pi/2 then the "tangent" will be undefined.  This is
#		considered to be a case in which the aspects are
#		definitely different -- thus we return a large double,
#		1E99.
#
#--------------------------------------------------------------------------

double procedure asp_off_diff(p_asp1,p_asp2,dist_to_edge)
pointer p_asp1		# i: first aspect record
pointer p_asp2		# i: second aspect record
double  dist_to_edge	# i: how far away is the edge of the field?

### LOCAL VARS ###

double 	edge_pix	# number of pixels the edge of field moves
double 	off_diff	# total difference

### BEGINNING OF PROCEDURE ###

begin

        #----------------------------------------------
        # Is the aspect roll difference a multiple of
	# pi/2?  If so, set off_diff to 1E99.
        #----------------------------------------------

	if (dcos(ASP_ASPR(p_asp1)-ASP_ASPR(p_asp2))<EPSILOND)
	{
	    off_diff=1E99
	}
	else
	{
            #----------------------------------------------
            # set edge_pix and off_diff
            #----------------------------------------------
   	    edge_pix=abs(dist_to_edge*dtan(ASP_ASPR(p_asp1)-ASP_ASPR(p_asp2)))

   	    off_diff=(ASP_ASPX(p_asp1)-ASP_ASPX(p_asp2))**2 + 
                     (ASP_ASPY(p_asp1)-ASP_ASPY(p_asp2))**2 + edge_pix

	}

   	return off_diff
end

#--------------------------------------------------------------------------
# Procedure:    mk_new_grp
#
# Purpose:      Copies aspect information into new group
#
# Input variables:
#               p_asp           aspect record
#
# Output variables:
#		p_grp		output group data
#
#--------------------------------------------------------------------------

procedure mk_new_grp(p_asp,p_grp)
pointer p_asp
pointer p_grp

begin
        ASP_ROLL(p_grp)=ASP_ROLL(p_asp)
        ASP_ASPX(p_grp)=ASP_ASPX(p_asp)
        ASP_ASPY(p_grp)=ASP_ASPY(p_asp)
        ASP_ASPR(p_grp)=ASP_ASPR(p_asp)
end

