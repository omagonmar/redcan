#$Header: /home/pros/xray/lib/pros/RCS/getplims.x,v 11.0 1997/11/06 16:20:30 prosb Exp $
#$Log: getplims.x,v $
#Revision 11.0  1997/11/06 16:20:30  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:27:43  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:46:12  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:09:40  prosb
#General Release 2.3
#
#Revision 6.1  93/06/17  17:29:18  dennis
#Changed reference to streq() to the correct type (bool, not int).
#
#Revision 6.0  93/05/24  15:44:51  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:16:51  prosb
#General Release 2.1
#
#Revision 3.1  92/04/27  13:48:51  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:00:46  wendy
#General
#
#Revision 2.0  91/03/07  00:07:02  pros
#General Release 1.0
#
#
#  GET_PLIMS -- get display mode for a plio file
#
# define max dimensions of the mask we create
define MAX_VALS	4

procedure get_plims(dmode, x1, x2, y1, y2)

char	dmode[ARB]			# i: input pl display mode string
int	x1, x2, y1, y2			# o: rg_pldisp parameters
char	temp[SZ_LINE]			# l: temp lower case mode string
int	nvals				# l: number of values specified by user
int	nchar				# l: return from ctoi
int	ip				# l: ctoi index
int	vals[MAX_VALS+1]		# l: vals specified by user

int	ctoi()				# l: char to int
int	abbrev()			# l: check for abbrev
bool	streq()				# l: string compare

begin
	# convert to lower case
	call strcpy(dmode, temp, SZ_LINE)
	call strlwr(temp)
	# check for keywords
	# default is to zoom in
	if( streq("", temp)  ||
	    (abbrev("zoom", temp) >0) ||
	    (abbrev("subfield", temp) >0) ){
	    x1 = 0
	    x2 = 0
	    y1 = 0
	    y2 = 0
	}
	else if( (abbrev("full", temp) >0) ||
		 (abbrev("field", temp) >0) ){
	    x1 = -1
	    x2 = -1
	    y1 = -1
	    y2 = -1
	}
	else{
	    # pick out the 4 int values
	    nvals = 1
	    ip = 1
	    while( TRUE ){
		nchar = ctoi(temp, ip, vals[nvals])
		if( nchar ==0 ) break
		if( nvals > MAX_VALS )
		    call error(1, "too many pl dimensions specified")
		nvals = nvals + 1
	    }
	    nvals = nvals - 1
	    if( nvals != MAX_VALS )
		call error(1, "requires x1, y1, x2, y2 values")
	    else{
		x1 = vals[1]
		x2 = vals[2]
		y1 = vals[3]
		y2 = vals[4]
		# make sure the user did not put 0 or -1 in the second value
		if( (x2 == 0) || (x2 == -1) || (y2 == 0) || (y2 == -1) )
		    call error(1, "x2 and/or y2 value should not be 0 or -1")
		# make sure range values are in correct order
		if( (x1 >= x2) || (y1 >= y2) )
		    call error(1, "second range value must be > first range value")
	    }
	}
end
