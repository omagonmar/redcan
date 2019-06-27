#$Header: /home/pros/xray/lib/regions/RCS/rgop.com,v 11.0 1997/11/06 16:19:16 prosb Exp $
#$Log: rgop.com,v $
#Revision 11.0  1997/11/06 16:19:16  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:26:34  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:44:45  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:08:02  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:38:55  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:14:21  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  17:21:05  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:06:29  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:15:47  pros
#General Release 1.0
#
# rgop.com
define MAX_RGPM 100
pointer pmask
int	pltype
int	pmdepth
int	last_pm
int	rgdepth
int	rgvalue
int	naxes
int	axlen[PM_MAXDIM]
int	v[PM_MAXDIM]
pointer rgpm[MAX_RGPM]
common /rgop/ pmask,pltype,pmdepth,last_pm,rgdepth,rgvalue,naxes,axlen,v,rgpm
