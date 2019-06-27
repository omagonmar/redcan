#$Header: /home/pros/xray/lib/RCS/srg.h,v 11.0 1997/11/06 16:25:43 prosb Exp $ 
#$Log: srg.h,v $
#Revision 11.0  1997/11/06 16:25:43  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:25:50  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:43:41  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:22:39  prosb
#General Release 2.3
#
#Revision 1.1  93/12/22  17:26:44  mo
#Initial revision
#
#
#
# Module:       SODART.H
# Project:      PROS -- ROSAT RSDC
# Purpose:      Define ROSAT parameters for QPOE header, however, whenever
#		possible these will be acquired from the individual observation
#		input files
# External:     NONE
# Local:        NONE
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1993.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} MC	  -- initial version	-- 1993
#

#
# SODART PARAMETERS
#

# the following are assigned and must not be changed:
define SODART		50			# mission number
define SRG		50			# mission number
# ROSAT instruments
define SRG_LEPC1	51
define SRG_LEPC2	52
define SRG_HEPC1	53
define SRG_HEPC2	54

define LEPC1_CODE       1
define LEPC2_CODE       2 
define HEPC1_CODE       3
define HEPC2_CODE       4
