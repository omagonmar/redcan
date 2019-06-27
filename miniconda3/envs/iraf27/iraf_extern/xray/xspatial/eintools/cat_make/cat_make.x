# $Header: /home/pros/xray/xspatial/eintools/cat_make/RCS/cat_make.x,v 11.0 1997/11/06 16:30:41 prosb Exp $
# $Log: cat_make.x,v $
# Revision 11.0  1997/11/06 16:30:41  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:48:21  prosb
# General Release 2.4
#
#Revision 1.1  1994/03/15  09:09:15  prosb
#Initial revision
#
#
#--------------------------------------------------------------------------
# Module:       cat_make.x
# Project:      PROS -- EINSTEIN TOOLS
# External:     t_cat_make
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1994.  You may do anything you like with this
#               file except remove this copyright.
# Modified:     {0} David Van Stone -- 3/94 -- initial version 
#               {n} <who> -- <when> -- <does what>
#--------------------------------------------------------------------------

include <qpc.h>
include <ext.h>

#--------------------------------------------------------------------------
# Procedure:    t_cat_make()
#
# Purpose:      Main procedure call for the task cat_make
#
# Input parameters:
#               qpoefile        input qpoe file 
#               catfile         output constant aspect table
#               aspx_res        aspect X resolution (in pix)
#               aspy_res        aspect Y resolution (in pix)
#               aspr_res        aspect roll resolution (in radians)
#               display         display level
#               clobber         overwrite output file?
#
# Description:  This procedure reads in the appropriate parameters and
#               calls the routine "cat_make" which creates a constant
#		aspect table from the BLT and GTI information in the
#		passed qpoe file.
#--------------------------------------------------------------------------
procedure t_cat_make()
pointer p_qpoe_expr	 # pointer to input qpoe expression 
			 #   (e.g., "i2060.qp[time=1000000:2000000]")
pointer p_cat_name	 # pointer to output CAT name
double	aspx_res	 # aspect X resolution (in pix)
double	aspy_res	 # aspect Y resolution (in pix)
double	aspr_res	 # aspect roll resolution (in radians
bool    clobber          # flag: should we allow clobbering of output?
int     display          # display level (0-5)

### LOCAL VARS ###

int	n_cat		# number of rows in output constant aspect table
pointer p_cat_name_temp # pointer to temporary name for output file
pointer sp        	# stack pointer
pointer p_qpoe_evlist   # pointer to event list portion of qpoe expression
pointer p_qpoe_name     # pointer to qpoe filename

### EXTERNAL FUNCTION DECLARATIONS ###

bool    clgetb()  # returns boolean CL parameter [sys/clio]
int     clgeti()  # returns integer CL parameter [sys/clio]
double	clgetd()  # returns double CL parameter [sys/clio]

### BEGINNING OF PROCEDURE ###

begin

        #----------------------------------------------
        # allocate space on stack & set aside memory
        #   for strings
        #----------------------------------------------
        call smark(sp)
        call salloc( p_qpoe_expr, SZ_PATHNAME, TY_CHAR)
        call salloc( p_cat_name, SZ_PATHNAME, TY_CHAR)
        call salloc( p_cat_name_temp, SZ_PATHNAME, TY_CHAR)
        call salloc( p_qpoe_name, SZ_PATHNAME, TY_CHAR)
        call salloc( p_qpoe_evlist, SZ_EXPR, TY_CHAR)
	
        #----------------------------------------------
        # read in parameters
        #----------------------------------------------
        call clgstr("qpoefile",Memc[p_qpoe_expr],SZ_PATHNAME)
        call clgstr("catfile",Memc[p_cat_name],SZ_PATHNAME)
	aspx_res=clgetd("aspx_res")
	aspy_res=clgetd("aspy_res")
	aspr_res=clgetd("aspr_res")
	display=clgeti("display")
	clobber=clgetb("clobber")

        #----------------------------------------------
        # massage the input parameter filenames:
        #    remove white space around filenames
	#    add roots to names
        #----------------------------------------------
        call strip_whitespace(Memc[p_qpoe_expr])
        call strip_whitespace(Memc[p_cat_name])
	call rootname(Memc[p_qpoe_expr],Memc[p_qpoe_expr],
		      EXT_QPOE,SZ_PATHNAME) 
	call rootname(Memc[p_qpoe_expr],Memc[p_cat_name],
		      EXT_CAT,SZ_PATHNAME) 

        #----------------------------------------------
        # seperate qpoe expression into name & evlist
        #----------------------------------------------
	call qp_parse(Memc[p_qpoe_expr], Memc[p_qpoe_name], SZ_PATHNAME,
		      Memc[p_qpoe_evlist], SZ_EXPR)

	if (display>3)
	{
	    call printf("Using qpoe file %s with event list \"%s\"\n")
	     call pargstr(Memc[p_qpoe_name])
	     call pargstr(Memc[p_qpoe_evlist])
	    call printf("to create constant aspect table %s\n")
	     call pargstr(Memc[p_cat_name])
	}

        #----------------------------------------------
        # check if output file already exists
        #----------------------------------------------
	call clobbername(Memc[p_cat_name],Memc[p_cat_name_temp],
			 clobber,SZ_PATHNAME)

        #----------------------------------------------
        # make constant aspect table!
        #----------------------------------------------
	call cat_make(Memc[p_qpoe_name],Memc[p_qpoe_evlist],
 		      Memc[p_cat_name_temp],Memc[p_cat_name],
		      aspx_res,aspy_res,aspr_res,n_cat,display )

        #----------------------------------------------
        # rename temp file to output file
        #----------------------------------------------
	call finalname(Memc[p_cat_name_temp],Memc[p_cat_name])

	if (display>0)
	{
	   call printf("\nCreated constant aspect table %s with %d row(s).\n")
	     call pargstr(Memc[p_cat_name])
	     call pargi(n_cat)
	}

        #----------------------------------------------
        # free stack
        #----------------------------------------------
        call sfree (sp)
end
