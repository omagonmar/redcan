#$Header: /home/pros/xray/xtiming/fft/RCS/par.x,v 11.0 1997/11/06 16:44:41 prosb Exp $
#$Log: par.x,v $
#Revision 11.0  1997/11/06 16:44:41  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:34:01  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:40:37  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:01:31  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:57:33  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:49:09  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  15:33:11  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  02:01:37  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  22:44:24  pros
#General Release 1.0
#
	call smark(sp)
	call salloc(photon_file,SZ_PATHNAME,TY_CHAR)
	call salloc(datacol,SZ_PATHNAME,TY_CHAR)
	call clgstr( SOURCEFILENAME, Memc[photon_file], SZ_PATHNAME)
	call clgstr( DATATYPE, Memc[datacol], SZ_PATHNAME)
	display = clgeti(DISPLAY)
