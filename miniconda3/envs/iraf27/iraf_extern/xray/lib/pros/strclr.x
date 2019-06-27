#$Header: /home/pros/xray/lib/pros/RCS/strclr.x,v 11.0 1997/11/06 16:21:09 prosb Exp $
#$Log: strclr.x,v $
#Revision 11.0  1997/11/06 16:21:09  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:28:18  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:47:12  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:10:42  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:54:10  prosb
#General Release 2.2
#
#Revision 1.1  93/03/02  17:54:51  jmoran
#Initial revision
#

procedure strclr(str)

char	str[ARB]

int	i
int	len
int	strlen()

begin

	len = strlen(str)
	if (len > 0) 
	   for (i=1; i<=len; i=i+1)
	      str[i] = EOS
end
