#$Header: /home/pros/xray/xtiming/RCS/x_xtiming.x,v 11.0 1997/11/06 16:46:07 prosb Exp $
#$Log: x_xtiming.x,v $
#Revision 11.0  1997/11/06 16:46:07  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:32:46  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:38:01  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:04:43  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:55:17  prosb
#General Release 2.2
#
#Revision 5.1  93/05/20  10:12:46  janet
#jd - added 2 new tasks, vartst & kspltab.
#
#Revision 5.0  92/10/29  23:06:54  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  15:30:38  prosb
#General Release 2.0:  April 1992
#
#Revision 3.2  92/04/23  18:16:50  mo
#MC	4/24/92		Remove trailing comma
#
#Revision 3.1  92/04/23  00:54:23  wendy
#Removed fakesrc and addsine tasks.
#
#Revision 3.0  91/08/02  02:00:03  prosb
#General Release 1.1
#
#Revision 1.1  91/07/21  18:07:46  mo
#Initial revision
#
#Revision 2.0  91/03/06  22:48:00  pros
#General Release 1.0
#
#  Executables for the xtiming package

task	ltcurv	  = t_ltcurv,
	fft       = t_fft,
	fold	  = t_fold,
        kspltab   = t_kspltab,
	period    = t_period,
	qpphase	  = t_qpphase,
	timfilter = t_timfilter,
	timplot   = t_timplot,
        vartst    = t_vartst
#	fakesrc   = t_fakesrc,
#	addsine   = t_addsine

