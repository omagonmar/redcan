# $Header: /home/pros/xray/xspatial/eintools/RCS/exp_make.cl,v 11.0 1997/11/06 16:31:07 prosb Exp $
# $Log: exp_make.cl,v $
# Revision 11.0  1997/11/06 16:31:07  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:47:50  prosb
# General Release 2.4
#
#Revision 1.1  1994/03/15  09:16:02  prosb
#Initial revision
#
#
#--------------------------------------------------------------------------
# Module:       exp_make.cl
# Project:      PROS -- EINSTEIN CDROM
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1994.  You may do anything you like with this
#               file except remove this copyright.
# Modified:     {0} David Van Stone -- 3/94 -- initial version 
#               {n} <who> -- <when> -- <does what>
#--------------------------------------------------------------------------

#--------------------------------------------------------------------------
# Task:         exp_make
#
# Purpose:      To create an exposure mask for an Einstein QPOE file
#
# Input parameters:
#               qpoefile	input QPOE file
#		expfile		output exposure file name
#		catfile		intermediate constant aspect table
#		full_exp	should we create full exposure?
#               aspx_res        aspect X resolution (in pix)
#               aspy_res        aspect Y resolution (in pix)
#               aspr_res        aspect roll resolution (in radians)
#               cell_size       exposure cell size
#               exp_max         (for PL files) integer max
#		geom_bounds	name of IPC geometry file
#               display         display level
#               clobber         overwrite output file?
#
# Description:  This script simply calls the two tasks cat_make and
#		cat2exp to create a constant aspect table then use
#		it to create an exposure file.
#
# Note:		Because the constant aspect table is an intermediate
#		file, we allow it to be clobbered EVEN IF "clobber" is
#		set to "no".
#
#		We don't bother adding the file name extensions --
#		this should be taken care of within the tasks
#		themselves.  By leaving this to the tasks, we won't
#		have as much of a maintenance hastle.
#
#		The parameter file is separate and in the same format
#		as the SPP tasks -- this makes them easier to update.
#
#--------------------------------------------------------------------------

procedure exp_make (qpoefile,expfile)

### PARAMETERS ###

file	qpoefile	# i: input QPOE file
file	expfile		# i: output exposure file name
file	catfile		# i: intermediate constant aspect table
bool	full_exp	# i: should we create full exposure?
real	aspx_res	# i: aspect X resolution (in pix) 
real	aspy_res	# i: aspect Y resolution (in pix)
real	aspr_res	# i: aspect roll resolution (in radians)
int	cell_size	# i: exposure cell size
int	exp_max		# i: (for PL files) integer max
string	geom_bounds	# i: name of IPC geometry file
bool	clobber		# i: display level
int	display		# i: overwrite output file?

begin

### LOCAL VARS ###

        file	c_qpoefile	# local copy of QPOE file name
	file	c_expfile	# local copy of exposure file name

### BEGINNING OF CL SCRIPT ###

        #----------------------------------------------
        # copy automatic parameters into local vars
        #----------------------------------------------
        c_qpoefile  = qpoefile
        c_expfile   = expfile

        #----------------------------------------------
        # call cat_make and cat2exp
        #----------------------------------------------
	cat_make (c_qpoefile,catfile,
		aspx_res=aspx_res, aspy_res=aspy_res, aspr_res=aspr_res, 
		clobber=yes, display=display)

	cat2exp (c_qpoefile,catfile,c_expfile,
		full_exp=full_exp, cell_size=cell_size, exp_max=exp_max,
		geom_bounds=geom_bounds, clobber=clobber, display=display)
end
