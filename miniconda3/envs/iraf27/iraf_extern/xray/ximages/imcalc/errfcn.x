#$Header: /home/pros/xray/ximages/imcalc/RCS/errfcn.x,v 11.0 1997/11/06 16:27:00 prosb Exp $
#$Log: errfcn.x,v $
#Revision 11.0  1997/11/06 16:27:00  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:33:36  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:43:48  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:23:41  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:05:28  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:24:20  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  17:27:32  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:16:41  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:31:03  pros
#General Release 1.0
#
#
# ERRFCN -- error functions called when a divisor is zero
# for now, just return user-specified value
#
short procedure errfcns()
include "errfcn.com"
begin
	return(short(errfcn))
end

int procedure errfcni()
include "errfcn.com"
begin
	return(int(errfcn))
end

long procedure errfcnl()
include "errfcn.com"
begin
	return(long(errfcn))
end

real procedure errfcnr()
include "errfcn.com"
begin
	return(errfcn)
end

double procedure errfcnd()
include "errfcn.com"
begin
	return(double(errfcn))
end

complex procedure errfcnx()
include "errfcn.com"
begin
	return(complex(errfcn))
end

