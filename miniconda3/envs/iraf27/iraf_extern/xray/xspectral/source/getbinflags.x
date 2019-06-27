#$Header: /home/pros/xray/xspectral/source/RCS/getbinflags.x,v 11.0 1997/11/06 16:42:14 prosb Exp $
#$Log: getbinflags.x,v $
#Revision 11.0  1997/11/06 16:42:14  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:29:43  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:31:43  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:55:30  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:50:22  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:44:27  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  18:15:01  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  91/09/22  19:06:02  wendy
#Added
#
#Revision 3.0  91/08/02  01:58:20  prosb
#General Release 1.1
#
#Revision 2.1  91/07/12  16:13:20  prosb
#jso - made spectral.h system wide
#
#Revision 2.0  91/03/06  23:03:28  pros
#General Release 1.0
#
# Project:	PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
#
#  GETBINFLAGS   ---   retrieves the bin flags for the chi-square calculation

include	 <spectral.h>

#  local definitions

define  MAX_RANGES	 16


#  ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
#
procedure  get_bin_flags (range_str, flags, nflags, nvalues)

int	nflags					# number of flags
int	flags[ARB]				# array of (boolean) flags
int	bin					# index into array
int	ranges[3, MAX_RANGES]			# ranges
int	nvalues					# number of values in "ranges"
char	range_str[ARB]				# range string

int	decode_ranges()
bool	is_in_range()

begin
	if( decode_ranges( range_str, ranges, MAX_RANGES, nvalues) == ERR )
	    call error (1, "Error parsing channel range string.")
#	call printf( "Number of channels used in Chi-square = %d\n" )
#	    call pargi (nvalues)

	do bin = 1, nflags
	    if( is_in_range( ranges, bin ) )
		flags[bin] = 1
	      else
		flags[bin] = 0
end
