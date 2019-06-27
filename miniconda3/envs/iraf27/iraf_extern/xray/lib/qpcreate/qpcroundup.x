#$Header: /home/pros/xray/lib/qpcreate/RCS/qpcroundup.x,v 11.0 1997/11/06 16:22:08 prosb Exp $
#$Log: qpcroundup.x,v $
#Revision 11.0  1997/11/06 16:22:08  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:29:48  prosb
#General Release 2.4
#
#Revision 8.1  1994/09/16  16:11:35  dvs
#No need to round up -- event sizes don't have to be multiple of
#SZ_DOUBLE in length.
#
#Revision 8.0  94/06/27  14:33:52  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:17:34  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:58:51  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:19:09  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  13:52:52  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:05:27  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:11:29  pros
#General Release 1.0
#
#
#  QPC_ROUNDUP --  this USED to be for rounding up sizes to an
#		   even multiple of SZ_DOUBLE, but this is not
#		   necessary (and wrong, if there aren't any
#		   doubles within the typedef).
#		
#		   Now the routine just returns the input value.
#		   In theory, we could change all the routines
#		   which call qpc_roundup...but this is a simpler
#		   change.  
procedure qpc_roundup(oevsize, size)

int	oevsize			# i: event record size or 0
int	size			# o: "aligned" size of a record
				#    (same as oevsize).

begin
	size = oevsize
end

