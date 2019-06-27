#$Header: /home/pros/xray/xtiming/fft/RCS/xtiming.h,v 11.0 1997/11/06 16:44:45 prosb Exp $
#$Log: xtiming.h,v $
#Revision 11.0  1997/11/06 16:44:45  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:34:08  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:40:50  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:01:43  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:57:47  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:49:20  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  15:33:32  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  02:01:43  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  22:44:55  pros
#General Release 1.0
#
#        XTIMING.H
#
#        parameters used by the timing tasks

define	 SOURCEFILENAME	     "source_file"
define	 BKGRDFILENAME	     "background_file"
define   TGRFILENAME	     "interval_data"
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
define	 STARTTIME	     "start_time"
define   STOPTIME            "stop_time"
define	 NUMOFBINS           "bins"
define   FFTBINS             "fft_bins"
define   DISTRIBBINS         "distribution_bins"
define   ENERGY_RANGE        "energy_range"
define   HARD_ENERGY_RANGE   "hard_energy_range"
define   SOFT_ENERGY_RANGE   "soft_energy_range"

define	 DEVICE		     "device"
define   PLOT_FLAG           "plot"
define   TYPEPLOT            "type_plot"
define   PLOT_TITLE          "plot_title"
define   X_AXIS_TITLE        "x_axis_title"
define   Y_AXIS_TITLE        "y_axis_title"
define   CURSOR              "cursor"

define   RATES               "rates"
define	 SUBBKGRD	     "bkgrd_subtraction"
define	 DEBUGGING	     "debug_flag"


#  ---------------------------------------------------------------
#

define   DIST_SCALE          2.0


#  ---------------------------------------------------------------
#
#        Array Lengths

define   MAX_PHA_RANGES       16


#  ------------------------------------------------------------------------------

#             -----    Plotting parameters

define  PLOTNUM                  3
define  PLOT_TYPES               "|bins|frequency|distribution|"
define  SPECTRUM_BINS            1
define  SPECTRUM_FREQ            2
define  DISTRIBUTION_PLOT        3

define  FFT_PLOT_HELP  "timingdir$fft_plot.key"
define  FFT_CMD_KEYS   "|xlog|xlinear|ylog|ylinear|xmin|xmax|ymin|ymax|"
define  FFT_CMD_XLOG             1
define  FFT_CMD_XLINEAR          2
define  FFT_CMD_YLOG             3
define  FFT_CMD_YLINEAR          4
define  FFT_CMD_XMIN             5
define  FFT_CMD_XMAX             6
define  FFT_CMD_YMIN             7
define  FFT_CMD_YMAX             8

define  SZ_PLOT_TITLE           25           # length of title string
define  SZ_AXIS_TITLE           18           # length of axis title string
define  SZ_CUR_RESPONSE         12           # length of cursor command

define  LEN_PLOTSTRUCT        1+17*PLOTNUM

define  PL_TYPE                 Memi[$1]
define  PL_TITLE                Memi[$1+$2]
define  PL_XTITLE               Memi[$1+$2+PLOTNUM]
define  PL_YTITLE               Memi[$1+$2+2*PLOTNUM]
define  PL_ERRORS               Memi[$1+$2+3*PLOTNUM]
define  PL_ERRSTEP              Memi[$1+$2+4*PLOTNUM]
define  PL_XTRAN                Memi[$1+$2+5*PLOTNUM]
define  PL_YTRAN                Memi[$1+$2+6*PLOTNUM]
define  PL_CURSORX              Memr[$1+$2+7*PLOTNUM]
define  PL_CURSORY              Memr[$1+$2+8*PLOTNUM]
define  PL_XMIN                 Memr[$1+$2+9*PLOTNUM]
define  PL_XMAX                 Memr[$1+$2+10*PLOTNUM]
define  PL_YMIN                 Memr[$1+$2+11*PLOTNUM]
define  PL_YMAX                 Memr[$1+$2+12*PLOTNUM]
define  PL_XUNITS               Memr[$1+$2+13*PLOTNUM]
define  PL_YUNITS               Memr[$1+$2+14*PLOTNUM]
define  PL_CURSORX              Memr[$1+$2+15*PLOTNUM]
define  PL_CURSORY              Memr[$1+$2+16*PLOTNUM]
