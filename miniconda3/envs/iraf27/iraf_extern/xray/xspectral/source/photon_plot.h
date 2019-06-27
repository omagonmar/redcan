#$Header: /home/pros/xray/xspectral/source/RCS/photon_plot.h,v 11.0 1997/11/06 16:43:04 prosb Exp $
#$Log: photon_plot.h,v $
#Revision 11.0  1997/11/06 16:43:04  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:30:44  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:34:08  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:57:15  prosb
#General Release 2.3
#
#Revision 6.1  93/10/22  15:16:42  dennis
#Added HEPC1, LEPC1 definitions, for DSRI.
#
#Revision 6.0  93/05/24  16:52:04  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:45:49  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  18:17:17  prosb
#General Release 2.0:  April 1992
#
#Revision 3.2  92/04/07  16:15:15  prosb
#jso - added min and max parameters for both HRI's.
#
#Revision 3.1  92/04/06  15:11:00  jmoran
#JMORAN no changes
#
#Revision 3.0  91/08/02  01:58:53  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:06:30  pros
#General Release 1.0
#
# definitions for plot_counts

define  PLOT_TITLE      "plot_title"
define  X_AXIS_TITLE    "x_axis_title"
define  Y_AXIS_TITLE    "y_axis_title"
define  IPC_MIN_E	"ipc_minimum_energy"
define  IPC_MAX_E	"ipc_maximum_energy"
define  HRI_MIN_E	"ein_hri_minimum_energy"
define  HRI_MAX_E	"ein_hri_maximum_energy"
define  MPC_MIN_E	"mpc_minimum_energy"
define  MPC_MAX_E	"mpc_maximum_energy"
define  PSPC_MIN_E	"pspc_minimum_energy"
define  PSPC_MAX_E	"pspc_maximum_energy"
define  RHRI_MIN_E	"ros_hri_minimum_energy"
define  RHRI_MAX_E	"ros_hri_maximum_energy"
define  HEPC1_MIN_E	"hepc1_minimum_energy"
define  HEPC1_MAX_E	"hepc1_maximum_energy"
define  LEPC1_MIN_E	"lepc1_minimum_energy"
define  LEPC1_MAX_E	"lepc1_maximum_energy"
define  DEVICE          "device"
define  CURSOR          "cursor"

define   PROMPT		"plotting options"
define   Y_MINIMUM	(0.0)			# Y axis minimum
define   Y_MAX_SCALE	(1.1)			# scale factor for max. Y counts

# modes for plot_counts
define	C_OBS		1
define	C_DIFF		2
define	C_SIGMA		3

define	MARK_SIZE	(2.0)
define  LINE_HEIGHT	(0.02)
