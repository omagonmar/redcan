#$Header: /home/pros/xray/lib/pros/RCS/mskdisp.x,v 11.0 1997/11/06 16:20:40 prosb Exp $
#$Log: mskdisp.x,v $
#Revision 11.0  1997/11/06 16:20:40  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:27:59  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:46:38  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:10:01  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:45:11  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:17:05  prosb
#General Release 2.1
#
#Revision 4.1  92/07/07  23:44:39  dennis
#Corrected '/n' to '\n'.
#
#Revision 4.0  92/04/27  13:49:13  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  92/01/28  23:18:43  dennis
#Replace 1024 with SZ_OBUF, from <printf.h>, as max length of formatted 
#output string.
#
#Revision 3.0  91/08/02  01:00:53  wendy
#General
#
#Revision 2.1  91/04/12  10:01:08  mo
#MC	3/91		This was one of a series of fixes needed to
#			allow regions strings > 1024 characters.  In
#			particular, IRAF seems to limit %s formats
#			to 1024 characters, so multiple print statements
#			were added.
#
#
#Revision 2.0  91/03/07  00:07:13  pros
#General Release 1.0
#
#
# MSK_DISP -- display info about a mask file
#

include	<printf.h>	# defines SZ_OBUF

procedure msk_disp(heading, imname, plhead)

char	heading[ARB]			# i: heading for display
char	imname[ARB]			# i: image name
char	plhead[ARB]			# i: plio header string

int	clen				# l: length of displayed string
int	len				# l: length of title string

int	strlen()
bool	strne()				# l: string compare

begin
	call printf("\n")
	# display the heading, if necessary
	len = strlen(heading)
	clen = 0
	while( clen < len ){
	    if( strne("", heading) ){
	        call printf("%s")
	            call pargstr(heading[clen+1])
	    }
	    clen = clen + SZ_OBUF
	}
	call printf("\n")

	# display the image name, if necessary
	if( strne("", imname) ){
	    call printf("image:\t\t%s\n")
	    call pargstr(imname)
	}

	# display the plio header string
	call disp_plhead(plhead)
end

