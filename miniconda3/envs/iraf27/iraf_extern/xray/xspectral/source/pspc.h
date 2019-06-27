#$Header: /home/pros/xray/xspectral/source/RCS/pspc.h,v 11.0 1997/11/06 16:43:14 prosb Exp $
#$Log: pspc.h,v $
#Revision 11.0  1997/11/06 16:43:14  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:30:55  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:34:30  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:57:30  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:52:21  prosb
#General Release 2.2
#
#Revision 5.2  93/01/30  12:45:55  prosb
#jso - added parmeter that defines final off-axis angle of the filter.
#
#Revision 5.1  93/01/26  17:19:48  prosb
#jso - changed the high threshhold to 247, which seems correct.  see
#      ipros_archive mail on 27 jan 1993.
#
#Revision 5.0  92/10/29  22:46:04  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  18:17:40  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  92/03/25  11:25:00  orszak
#jso - no change for first installation of new qpspec
#
#Revision 3.0  91/08/02  01:58:59  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:06:50  pros
#General Release 1.0
#
# pspc.h

define	PSPC_RSPBINS	729
define	PSPC_PITCH	256
define	PSPC_CHANNELS	34
define	PSPC_OFFAR	14
define	PSPC_ELEM	4

define	PSPC_FILT_ANG	9

define	PSPC_HITHRESH	247
define	PSPC_LOTHRESH	7


define	ROS_DTMAT	"ros_dtmat"
define	ROS_EGRID	"ros_egrid"
define	ROS_OFFAR	"ros_offar"
define	ROS_FILTE	"ros_filte"




