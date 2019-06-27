#$Header: /home/pros/xray/xspectral/qpspec/RCS/qpspec.h,v 11.0 1997/11/06 16:43:33 prosb Exp $
#$Log: qpspec.h,v $
#Revision 11.0  1997/11/06 16:43:33  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:31:53  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:36:24  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:58:30  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:54:01  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:46:57  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  15:29:23  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  92/03/05  12:57:07  orszak
#jso - new version for qpspec upgrade.
#
#Revision 3.0  91/08/02  01:59:01  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:06:57  pros
#General Release 1.0
#
#
# qpspec.h
#
# binning structure
#


define	N_OAHBINS	65
define	SZ_BINNING	(19 + N_OAHBINS*2)

define BN_INST		Memi[$1 + 0]		# instrument
define BN_FULL		Memi[$1 + 1]
define BN_XREF		Memi[$1 + 2]		# the optical axis
define BN_YREF		Memi[$1 + 3]
define BN_BOFF		Memi[$1 + 4]		# binning offset 
define BN_XOFF		Memi[$1 + 5]		# x offset
define BN_YOFF		Memi[$1 + 6]		# y offset
define BN_INDICES	Memi[$1 + 7]		# source indices
define BN_GOODTIME	Memd[P2D(($1)+8)]	# good time from qpoe
define BN_UNORM		Memr[$1 + 10]		# user norm factor
define BN_TNORM		Memr[$1 + 11]		# time norm factor
define BN_NORMFACTOR	Memr[$1 + 12]		# normalization factor
define BN_RADIUS	Memr[$1 + 13]		# inst. radius
define BN_LTCOR		Memr[$1 + 14]		# instr. live time corr.
define BN_ARCFRAC      	Memr[$1 + 15]		# instr. arcing frac.
define BN_NOAH		Memi[$1 + 16]		# number of offaxis bins
define BN_OAHAN		Memr[$1 + 17 + $2]	# inner raduis of bin
define BN_OAH		Memr[$1 + 18 + N_OAHBINS + $2]	# histogram bins
