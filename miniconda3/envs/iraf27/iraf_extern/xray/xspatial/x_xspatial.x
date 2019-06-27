#$Header: /home/pros/xray/xspatial/RCS/x_xspatial.x,v 11.0 1997/11/06 16:33:42 prosb Exp $
#$Log: x_xspatial.x,v $
#Revision 11.0  1997/11/06 16:33:42  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:37:14  prosb
#General Release 2.4
#
#Revision 8.1  1995/08/07  20:23:04  prosb
#jcc - ci for pros2.4.
#
#Revision 8.0  94/06/27  14:56:03  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:31:16  prosb
#General Release 2.3
#
#Revision 6.1  93/12/15  11:38:06  mo
#MC	12/14/93		Add ERRCREATE task
#
#Revision 6.0  93/05/24  16:10:21  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:30:41  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:34:08  prosb
#General Release 2.0:  April 1992
#
#Revision 3.2  92/04/24  15:01:09  mo
#MC	4/24/92		Add fixsaoreg task definition
#
#Revision 3.1  92/02/13  12:23:22  janet
#added task isoreg.
#
#Revision 3.0  91/08/02  01:26:46  prosb
#General Release 1.1
#
#Revision 2.1  91/07/21  18:19:47  mo
#MC	7/21/91		Update for the new package structure
#
#Revision 2.0  91/03/06  23:13:34  pros
#General Release 1.0
#
# Executables for the spatial package.

task	fixsaoreg=	t_fixsaoreg,
	imcnts =	t_imcnts,
	imdisp =	t_imdisp,
	improj =	t_improj,
	isoreg =	t_isoreg,
	errcreate =	t_errcreate,
	makevig =	t_makevig,
	skypix = 	t_skypix,
	simevt = 	t_simevt,
        srcechk =       t_srcechk

