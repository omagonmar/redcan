# $Header: /home/pros/xray/lib/pros/RCS/getanyline.x,v 11.0 1997/11/06 16:20:29 prosb Exp $
# $Log: getanyline.x,v $
# Revision 11.0  1997/11/06 16:20:29  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:27:40  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  13:46:07  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:09:36  prosb
#General Release 2.3
#
#Revision 6.1  93/12/08  00:23:19  dennis
#Checked out unnecessarily to correct a problem with mask summary header
#parameters.
#
#Revision 6.0  93/05/24  15:44:46  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:16:47  prosb
#General Release 2.1
#
#Revision 1.2  92/09/02  03:30:47  dennis
#correcting header
#
#
# Module:	getanyline.x
# Project:	PROS -- ROSAT RSDC
# External:	
# Local:	getanyline() (perhaps later to be external)
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989.  You may do anything you like with this
#		file except remove this copyright
# Modified:	{0} dennis -- initial version -- 9/1/92
#		{n} <who> -- <does what> -- <when>
#


#
# Function:	getanyline()
# Purpose:	Get a line of text, possibly longer than SZ_LINE chars
# Pre-cond:	obuf[] is dimensioned at least maxch; maxch > 0
# Post-cond:	returns the number of characters stored into obuf[], or EOF
# Description:	Reads the next logical line (through the next '\n'), or EOF; 
#		uses multiple calls to getline(), if necessary; stores up to 
#		maxch chars into obuf[].  (If maxch is non-positive, no read 
#		is done.)
# Notes:	This is an alternative to IRAF's getlline(); with this one, 
#		make maxch whatever positive integer value you want, the 
#		actual maximum number of characters to get.
#

int procedure getanyline (fd, obuf, maxch)

int	fd			#I input file
char	obuf[ARB]		#O output buffer
int	maxch			#I max chars out

int	spaceleft
int	index
int	getlnc
char	lbuf[SZ_LINE]
int	chunknc
int	rtnval
int	getline()
errchk	getline

begin
	if (maxch <= 0)
	    return (0)

	spaceleft = maxch
	index = 1

	while (true) {
	    # Get next SZ_LINE chars, or to '\n', or EOF.
	    getlnc = getline (fd, lbuf)

	    if (getlnc == EOF) {
		if (index == 1)
		    rtnval = EOF
		else
		    rtnval = index - 1
		break
	    }

	    if (spaceleft > 0) {
		chunknc = min(getlnc, spaceleft)
		call strcpy(lbuf, obuf[index], chunknc)
		spaceleft = spaceleft - chunknc
		index = index + chunknc
	    }

	    # If the last getline() got to a '\n', we are done.
	    # If no '\n', get another chunk.

	    if (lbuf[getlnc] == '\n') {
		rtnval = index - 1
		break
	    }
	}
	return (rtnval)
end
