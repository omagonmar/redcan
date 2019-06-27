#$Header: /home/pros/xray/lib/qpcreate/RCS/qpctime.x,v 11.0 1997/11/06 16:22:11 prosb Exp $
#$Log: qpctime.x,v $
#Revision 11.0  1997/11/06 16:22:11  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:29:52  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:33:59  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:17:41  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:58:59  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:19:16  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  13:53:02  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:05:29  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:11:37  pros
#General Release 1.0
#
#
#  QPC_TIME -- display clock and cpu time
#

include <time.h>
include "qpcreate.h"

procedure qpc_time(s, display)

char	s[ARB]				# l: title string
int	display				# l: display level

int	len				# l: len of s
char	timestr[SZ_TIME]		# l: time of day
long	clk				# l: clock time
long	cpu				# l: cpu time
long	clktime()			# l: get clock time
long	cputime()			# l: get cputime
int	strlen()			# l: string length

begin
	if( display >2 ){
	    len = strlen(s)+1
	    clk = clktime(0)
	    cpu = cputime(0)
	    call cnvtime(clk, timestr, SZ_TIME)
	    call printf("%s:")
	    call pargstr(s)
	    if( len < 8 )
		call printf("\t\t\t\t")
	    else if( len < 16 )
		call printf("\t\t\t")
	    else if( len < 24 )
		call printf("\t\t" )
	    else
		call printf("\t")
	    call printf("clk=%s\tcpu=%.2f\n")
	    call pargstr(timestr)
	    call pargr(cpu/1000.0)
	    call flush(STDOUT)
	}
end
