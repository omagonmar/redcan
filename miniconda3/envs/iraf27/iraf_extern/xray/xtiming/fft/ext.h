#$Header: /home/pros/xray/xtiming/fft/RCS/ext.h,v 11.0 1997/11/06 16:44:29 prosb Exp $
#$Log: ext.h,v $
#Revision 11.0  1997/11/06 16:44:29  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:33:39  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:39:55  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:00:54  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:56:51  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:48:39  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  15:32:16  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  02:01:22  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  22:43:30  pros
#General Release 1.0
#
#
#  EXT.H -- commonly used extensions
#  NB: these should be kept in lower case
#

#
# PROS compound extensions
#
# NB: If you add or delete an extension to this list, you must change
# the following routines in lib/pros/fnames.x:
#
# fn_fullextname	(2 places)
#

define EXT_BTI		"_bti.qp"	# timing background timimg file
define EXT_CNTS		"_cnt.tab"	# imcnts output in table format
define EXT_ERROR	"_err.imh"	# error array
define EXT_FFT		"_fft.tab"      # fft table output file
define EXT_FTP		"_ftp.tab"      # fft table output file of power hist
define EXT_SMOOTH	"_smo.imh"	# smoothed image
define EXT_EXPOSURE	"_exp.pl"	# exposure plio file
define EXT_IMDISP	"_imd.tab"	# imdisp output in table format
define EXT_LTC		"_ltc.tab"	# light curve in table format
define EXT_PROJ		"_prj.tab"	# projection file in table format
define EXT_PWR		"_pwr.tab"      # fft table output file of sign power
define EXT_QPDISP	"_qls.tab"	# qpdisp output in table format
define EXT_SOURCE	"_sdf.tab"	# source file in table format
define EXT_STI		"_sti.qp"	# timing source timimg file
define EXT_VIGNETTING	"_vig.pl"	# vignetting plio file
#
# standard iraf extensions
#
# NB: If you add or delete an extension to this list, you must change
# the following routines in lib/pros/fnames.x:
#
# fn_getexttype
#
define EXT_IMG		".imh"		# IRAF image
define EXT_PL		".pl"		# generic plio file
define EXT_QPOE		".qp"		# X-ray image file
define EXT_STIMG	".stf"		# STScI image
define EXT_TABLE	".tab"		# generic STScI table
define EXT_EINEXP	".exp"		# Einstein exposure file
#
# define known file types
# these are related to the standard file extensions, but are not
# identical, since, for example, IMG and STIMG are the same type
#
define TY_IM	1
define TY_QPOE	2
define TY_TAB	3
define TY_PL	4
# unknown file type
define TY_DEF	-1

