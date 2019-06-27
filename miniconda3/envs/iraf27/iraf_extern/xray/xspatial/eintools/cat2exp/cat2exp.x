# $Header: /home/pros/xray/xspatial/eintools/cat2exp/RCS/cat2exp.x,v 11.0 1997/11/06 16:31:04 prosb Exp $
# $Log: cat2exp.x,v $
# Revision 11.0  1997/11/06 16:31:04  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:48:53  prosb
# General Release 2.4
#
#Revision 1.2  1994/08/04  13:58:33  dvs
#No change.
#
#Revision 1.1  94/03/15  09:09:49  prosb
#Initial revision
#
#
#--------------------------------------------------------------------------
# Module:       cat2exp.x
# Project:      PROS -- EINSTEIN TOOLS
# External:     t_cat2exp
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1994.  You may do anything you like with this
#               file except remove this copyright.
# Modified:     {0} David Van Stone -- 3/94 -- initial version 
#               {n} <who> -- <when> -- <does what>
#--------------------------------------------------------------------------
include <qpc.h>
include <ext.h>
 

#--------------------------------------------------------------------------
# Procedure:    t_cat2exp()
#
# Purpose:      Main procedure call for the task cat2exp
#
# Input parameters:
#               qpoefile        input qpoe file 
#               catfile         input constant aspect table
#		expfile		output exposure file
#		full_exp	are we making full exposure?
#		cell_size	exposure cell size
#		exp_max		(for PL files) integer max
#		geom_bounds	name of IPC geometry file
#               display         display level
#               clobber         overwrite output file?
#
# Description:  This procedure reads in the appropriate parameters and
#               calls the routine "cat2exp" which actually creates
#		the exposure file from the constant aspect table and
#		the QPOE file.
#--------------------------------------------------------------------------
procedure t_cat2exp()
pointer p_qpoe_expr	# pointer to input qpoe expression 
			#   (e.g., "i2060.qp[time=1000000:2000000]")
pointer p_cat_name	# pointer to input CAT
pointer p_exp_name	# pointer to output exposure filename
bool	full_exp	# are we using full exposure
int	cell_size	# cell size of exposure mask
int	exp_max		# maximum value of exposure mask
pointer p_geom_name	# name of IPC geometry file
bool    clobber         # flag: should we allow clobbering of output?
int     display         # display level (0-5)

### LOCAL VARS ###

pointer p_qpoe_evlist   # pointer to event list portion of qpoe expression
pointer p_qpoe_name     # pointer to qpoe filename
pointer p_exp_name_temp # pointer to temporary name for output file.
pointer sp		# stack pointer

### EXTERNAL FUNCTION DECLARATIONS ###

bool    clgetb()  # returns boolean CL parameter [sys/clio]
int     clgeti()  # returns integer CL parameter [sys/clio]

### BEGINNING OF PROCEDURE ###

begin

        #----------------------------------------------
        # allocate space on stack & set aside memory
        #   for strings
        #----------------------------------------------
        call smark(sp)
        call salloc( p_cat_name, SZ_PATHNAME, TY_CHAR)
        call salloc( p_exp_name, SZ_PATHNAME, TY_CHAR)
        call salloc( p_exp_name_temp, SZ_PATHNAME, TY_CHAR)
	call salloc( p_geom_name, SZ_PATHNAME, TY_CHAR)
        call salloc( p_qpoe_expr, SZ_PATHNAME, TY_CHAR)
        call salloc( p_qpoe_name, SZ_PATHNAME, TY_CHAR)
        call salloc( p_qpoe_evlist, SZ_EXPR, TY_CHAR)

        #----------------------------------------------
        # read in parameters
        #----------------------------------------------
 
        call clgstr("qpoefile",Memc[p_qpoe_expr],SZ_PATHNAME)
        call clgstr("catfile",Memc[p_cat_name],SZ_PATHNAME)
        call clgstr("expfile",Memc[p_exp_name],SZ_PATHNAME)
	full_exp=clgetb("full_exp")
	cell_size=clgeti("cell_size")
	exp_max=clgeti("exp_max")
	call clgstr("geom_bounds",Memc[p_geom_name], SZ_PATHNAME)
	display=clgeti("display")
	clobber=clgetb("clobber")

        #----------------------------------------------
        # massage the input parameter filenames:
        #    remove white space around strings
        #    add roots to names
        #----------------------------------------------
        call strip_whitespace(Memc[p_qpoe_expr])
        call strip_whitespace(Memc[p_cat_name])
        call strip_whitespace(Memc[p_exp_name])
	call rootname(Memc[p_qpoe_expr],Memc[p_qpoe_expr],
		      EXT_QPOE,SZ_PATHNAME) 
	call rootname(Memc[p_qpoe_expr],Memc[p_exp_name],
		      EXT_EXPOSURE,SZ_PATHNAME) 
	call rootname(Memc[p_qpoe_expr],Memc[p_cat_name],
		      EXT_CAT,SZ_PATHNAME) 

        #----------------------------------------------
        # seperate qpoe expression into name & evlist
	# [note that we don't actually use the evlist.]
        #----------------------------------------------
	call qp_parse(Memc[p_qpoe_expr], Memc[p_qpoe_name], SZ_PATHNAME,
		      Memc[p_qpoe_evlist], SZ_EXPR)

	if (display>3)
	{
	    call printf("Using CAT file %s to create exposure file %s,\n")
	     call pargstr(Memc[p_cat_name])
	     call pargstr(Memc[p_exp_name])
	    call printf("with header info copied from %s.\n")
	     call pargstr(Memc[p_qpoe_name])
	}

        #----------------------------------------------
        # check if output file already exists
        #----------------------------------------------
	call clobbername(Memc[p_exp_name],Memc[p_exp_name_temp],
			 clobber,SZ_PATHNAME)

        #----------------------------------------------
        # make exposure file!
        #----------------------------------------------
	call cat2exp(Memc[p_qpoe_name],Memc[p_cat_name],
		      Memc[p_exp_name_temp],
		      Memc[p_exp_name],Memc[p_geom_name],
		      full_exp,cell_size,exp_max,display )

        #----------------------------------------------
        # rename temp file to output file
        #----------------------------------------------
	call finalname(Memc[p_exp_name_temp],Memc[p_exp_name])

	if (display>0)
	{
	   call printf("\nCreated exposure file %s.\n")
	     call pargstr(Memc[p_exp_name])
	}

        #----------------------------------------------
        # free stack
        #----------------------------------------------
        call sfree (sp)
end
