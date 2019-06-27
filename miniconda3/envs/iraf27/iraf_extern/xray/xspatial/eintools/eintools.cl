# $Header: /home/pros/xray/xspatial/eintools/RCS/eintools.cl,v 11.0 1997/11/06 16:31:02 prosb Exp $
# $Log: eintools.cl,v $
# Revision 11.0  1997/11/06 16:31:02  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:47:45  prosb
# General Release 2.4
#
#Revision 8.1  1994/08/04  13:41:47  dvs
#Added header & log
#
#
#  eintools.cl
#
#  CL script task for eintools package

# Load necessary packages

print("")

# Define eintools package

package eintools

set eintools="xspatial$eintools/"
set eintoolsdata="eintools$data/"

task 	rbkmap_make 	= "eintools$rbkmap_make.cl"
task 	exp_make 	= "eintools$exp_make.cl"

task 	cat_make 	= "eintools$x_eintools.e"
task 	cat2exp 	= "eintools$x_eintools.e"
task	be_ds_rotate	= "eintools$x_eintools.e"
task	src_cnts	= "eintools$x_eintools.e"
task	bkfac_make	= "eintools$x_eintools.e"
task	calc_factors	= "eintools$x_eintools.e"

task	_band2range	= "eintools$x_eintools.e"

type eintools$eintools_motd

clbye()
