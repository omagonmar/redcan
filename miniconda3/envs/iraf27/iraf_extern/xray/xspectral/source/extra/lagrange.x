#$Header: /home/pros/xray/xspectral/source/extra/RCS/lagrange.x,v 11.0 1997/11/06 16:41:41 prosb Exp $
#$Log: lagrange.x,v $
#Revision 11.0  1997/11/06 16:41:41  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:31:30  prosb
#General Release 2.4
#
Revision 8.0  1994/06/27  17:35:33  prosb
General Release 2.3.1

Revision 7.0  93/12/27  18:53:48  prosb
General Release 2.3

Revision 6.0  93/05/24  16:53:19  prosb
General Release 2.2

Revision 5.0  92/10/29  22:43:03  prosb
General Release 2.1

Revision 3.0  91/08/02  01:59:28  prosb
General Release 1.1

#Revision 2.0  91/03/06  23:04:10  pros
#General Release 1.0
#
#
#	lagrangian interpolation
#
#						A. Szczypek

double  procedure  lagrange ( n, x, y, xp )

int	n			# entries
int	i,  j			# indices
double	x[ARB],  y[ARB]		#
double	xp			#
double	c[6],  answer		#

begin
	for( i=1; i<(n+1); i=i+1 )  {
	    c[i] = 1.0
	    for( j=1; j<(n+1); j=j+1 )
		if( i != j )
		    c[i] = c[i]*(xp-x[j])/(x[i]-x[j])
	    }

	answer = 0.0
	for( i=1; i<(n+1); i=i+1 )
	    answer = answer + c[i]*y[i]	

	return (answer)
end
