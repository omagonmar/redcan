#$Header: /home/pros/xray/xspatial/immd/RCS/mdparse.x,v 11.0 1997/11/06 16:33:00 prosb Exp $
#$Log: mdparse.x,v $
#Revision 11.0  1997/11/06 16:33:00  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:52:38  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:15:32  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:36:28  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:21:09  prosb
#General Release 2.2
#
#Revision 5.1  93/04/07  13:37:12  orszak
#jso - changes to add lorentzian model.
#
#Revision 5.0  92/10/29  21:34:42  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:42:41  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:28:17  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:17:13  pros
#General Release 1.0
#
#
# Module:       MDPARSE.X
# Project:      PROS -- ROSAT RSDC
# Purpose:      parse the model name
# External:     int md_parse()
# Local:        
# Description:  
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} M.VanHilst  initial version 	28 November 1988
#               {n} <who> -- <does what> -- <when>
#

include "mdset.h"


######################################################################
#
# md_parse
#
# parse the model name
# 
######################################################################

int procedure md_parse ( name )

char	name[SZ_FNAME]

int	code
int	ch, i			# l: loop counters
int	matchlen		# l: length of input string + 1
char	cbuf[SZ_FNAME]		# l: buf to hold model name (they're not long)
include "mdname.h"
int	strlen()
begin
	# prepare the string
	call strcpy (name, cbuf, SZ_FNAME)
	call strupr (cbuf)
	matchlen = strlen[cbuf] + 1
	if( matchlen == 1)
	    return(0)
	code = 0
	do i = 1, NUM_CODES {
	    ch = 1
	    while( (ch < matchlen) && (cbuf[ch] == mdname[ch,i]) ) {
		ch = ch + 1
	    }
	    if( ch == matchlen ) {
		if( code == 0 ) {
		    code = mdcode[i]
		} else {
		    call printf ("Non-unique model function name: %s\n")
		     call pargstr(name)
		    return(0)
		}
	    }
	}
	if( code == 0 ) {
	    call printf ("Unrecognized model function name: %s\n")
	     call pargstr(name)
	    call printf ("(boxcar|expo|file|impulse|gauss|lorentz|hipass|")
	    call printf ("kfile|king|lopass|power|tophat|mymod|mykmod)\n")
	}
	return(code)
end
