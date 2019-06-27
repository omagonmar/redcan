#$Header: /home/pros/xray/lib/RCS/ext.h,v 11.0 1997/11/06 16:25:00 prosb Exp $
#$Log: ext.h,v $
#Revision 11.0  1997/11/06 16:25:00  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:25:26  prosb
#General Release 2.4
#
#Revision 8.1  1994/09/07  17:55:00  janet
#jd - added EXT_ANG & EXT_OBI
#
#Revision 8.0  94/06/27  13:42:59  prosb
#General Release 2.3.1
#
#Revision 7.1  94/02/23  13:29:58  prosb
#Added three extensions
#
#Revision 7.0  93/12/27  18:21:58  prosb
#General Release 2.3
#
#Revision 6.4  93/12/22  17:26:57  mo
#add RDF extensions
#
#Revision 6.3  93/11/02  16:49:00  mo
#MC	11/2/93		Add 'MODEL' extension (mdl) to be different than SMOOTH
#
#Revision 6.2  93/09/02  18:13:38  dennis
#Changed EXT_OAH and EXT_BOA to EXT_SOH and EXT_BOH, respectively, 
#to show their parallelism.
#
#Revision 6.1  93/08/23  19:06:55  dennis
#Changed extension for fit's chi-square table file from EXT_CHI to EXT_CSQ, 
#to avoid naming collision with period's EXT_CHI file.
#Also created new extensions EXT_OAH, EXT_BOA, EXT_BAL in preparation for 
#xspectral's use of RDF.
#
#Revision 6.0  93/05/24  15:36:42  prosb
#General Release 2.2
#
#Revision 5.2  93/05/20  11:43:34  mo
#MC	5/20/93		Add match srcs and bary extensions
#
#Revision 5.1  93/05/07  15:35:55  janet
#added _var.tab, ks-test task extension.
#
#Revision 5.0  92/10/29  21:22:51  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:06:32  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  92/02/13  10:08:17  janet
#added defaults for detect and isoreg.
#
#Revision 3.0  91/08/02  00:46:24  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:02:27  pros
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

define EXT_BKGD         "_bkg.imh"      # background image
define EXT_ERROR	"_err.imh"	# error array
define EXT_MDL		"_mdl.imh"	# modeled image
define EXT_SMOOTH	"_smo.imh"	# smoothed image
define EXT_SNR		"_snr.imh"	# detect snr map image extension

define EXT_EXPOSURE	"_exp.pl"	# exposure plio file
define EXT_ISO		"_iso.pl"	# iso intensity region mask file
define EXT_VIGNETTING	"_vig.pl"	# vignetting plio file

define EXT_BAR		"_bar.qp"	# bary-center corrected QPOE file
define EXT_BTI		"_bti.qp"	# timing background timing file
define EXT_STI		"_sti.qp"	# timing source timing file


define EXT_ANG		"_ang.tab"	# orbit angles output from from evalvg
define EXT_BAL		"_bal.tab"	# spectral BAL histogram file
define EXT_BKFAC        "_bkfac.tab"    # eintools bkgd factors table
define EXT_BOH		"_boh.tab"	# spectral background offaxis histogram
define EXT_CAT          "_cat.tab"      # eintools constant aspect table
define EXT_CHI		"_chi.tab"	# timing chi square file
define EXT_CNTS		"_cnt.tab"	# imcnts output in table format
define EXT_COR		"_cor.tab"	# calc bary output table 
define EXT_CSQ		"_csq.tab"	# spectral chi square file
define EXT_EPH		"_eph.tab"	# ephemeris table
define EXT_EPHEM	"_ephem.tab"	# copy of ephemeris table (rdf)
define EXT_FFT		"_fft.tab"      # fft table output file
define EXT_FLD		"_fld.tab"	# fold table output file
define EXT_FTP		"_ftp.tab"      # fft power histogram output file
define EXT_GRD		"_grd.tab"	# spectral grid search table file
define EXT_IMDISP	"_imd.tab"	# imdisp output in table format
define EXT_INT		"_int.tab"	# spectral intermediate table file
define EXT_LTC		"_ltc.tab"	# light curve in table format
define EXT_MCH          "_mch.tab"      # lmatchsrc table match output
define EXT_OBI		"_obi.tab"	# observation-interval times and pos
define EXT_OBS		"_obs.tab"	# spectral observed data table file
define EXT_POS		"_pos.tab"	# imbepos max. likelihood position
define EXT_PRD		"_prd.tab"	# spectral predicted data table file
define EXT_PROJ		"_prj.tab"	# projection file in table format
define EXT_PWR		"_pwr.tab"	# fft significant power table
define EXT_QPDISP	"_qls.tab"	# qpdisp output in table format
define EXT_REG		"_reg.tab"	# imdetect rough positions region output
define EXT_RUF		"_ruf.tab"	# imdetect rough positions output
define EXT_SOH		"_soh.tab"	# spectral source offaxis histogram
define EXT_SOURCE	"_sdf.tab"	# source file in table format
define EXT_UNQ          "_unq.tab"      # lmatchsrc unique source list output
define EXT_UTC		"_utc.tab"	# scc_utc correction tables
define EXT_VAR          "_var.tab"      # ks-test variability test output table

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

