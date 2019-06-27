#$Header: /home/pros/xray/xtiming/fft/RCS/fft.h,v 11.0 1997/11/06 16:44:30 prosb Exp $
#$Log: fft.h,v $
#Revision 11.0  1997/11/06 16:44:30  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:33:41  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:40:00  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:00:57  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:56:53  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:48:41  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  15:32:19  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  91/12/18  15:18:48  mo
#MC	12/18/91	Add identifier for LIST input type
#
#Revision 3.0  91/08/02  02:01:22  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  22:43:33  pros
#General Release 1.0
#
define  L2NEL	9		# for the for2d disk file storage
define	NELEM	2**L2NEL	# 2 ** L2NEL
#define	HALFNELEM	NELEM/2	# NELEM / 2	
define	HALFNELEM	2**(L2NEL-1)

define	 SOURCEFILENAME	     "source_file"
define   BKGRDFILENAME		"background_file"
define   FFTFILENAME         "fft_file"
define   SCRATCHFILENAME     "scratch_file"
#
# ltcurv output table header parameters
#
define	 SRCAREA	     "SRCAREA"
define	 BINLEN		     "BINLEN"


define	 DATATYPE	     "column_name"
define	 DISPLAY	     "display"
define	 FFTCONFIDENCE	     "fft_confidence"
define	 CLOBBER	     "clobber"
define	 NUMOFBINS           "bins"
define   FFTBINS             "fft_bins"
define	 FILLMODE	     "gap_fillmode"
define	 BINSPERSEGMENT	     "bins_per_segment"
define	 PHISTBINSIZE	     "histogram_bin_size"
define	 PHISTBINNO	     "histogram_no_bins"
define	 POWERTHRESH	     "power_threshold"
define	 FILLCONSTANT	     "gapfill_constant"
define	 NO_FILL			0
define	 INTERP			1
define	 MEAN			2

define	FFT_ERROR		1
define	FFT_FATAL		1

define	TABLE			0
define	QPOE			1
define	LIST			2

