#$Header: /home/pros/xray/xspectral/source/RCS/asc_bal_histo.x,v 11.0 1997/11/06 16:41:48 prosb Exp $
#$Log: asc_bal_histo.x,v $
#Revision 11.0  1997/11/06 16:41:48  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:28:55  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:29:53  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:54:10  prosb
#General Release 2.3
#
#Revision 6.1  93/10/27  10:07:11  mo
#MC	10/27/93		Fixed type in 'bal_epsilon' parameter name
#
#Revision 6.0  93/05/24  16:48:39  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:43:21  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  18:12:59  prosb
#General Release 2.0:  April 1992
#
#Revision 3.2  92/03/05  13:23:31  orszak
#jso - with qpspec upgrade; no changes (yet)
#
#Revision 3.1  91/09/22  18:39:56  wendy
#Added Copyright
#
#Revision 3.0  91/08/02  01:57:49  prosb
#General Release 1.1
#
#Revision 2.2  91/07/12  15:31:08  prosb
#jso - made spectral.h system wide
#
#Revision 2.1  91/05/17  14:23:19  pros
#jso - changed CHK_VALBALS to check against "bal_epsilon" ( 
#from table BAL) instead of machine EPSILON definition.
#
#Revision 2.0  91/03/06  23:01:28  pros
#General Release 1.0
#
#
# ASC_BAL_HISTO -- get bal histogram from an ASCII string
#
# Project:      PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright

include <ctype.h>
include <mach.h>
include <spectral.h>

procedure asc_bal_histo(balhisto, bh)

char	balhisto[ARB]			# i: bal histo string
pointer	bh				# o: bal histo record

int 	nvals				# l: number of values
int	nchar				# l: return form ctod
int	ip				# l: index pointer
int	i, j				# l: counters
real	tpercent			# l: total bal percentage
real	mean				# l: mean bal value
double	vals[MAX_BALS*2]		# l: lengths of all vals
double 	dval				# l: temp double value
pointer	valbals				# l: pointer to array of valid bals
pointer	sp				# l: stack pointer

int	ctod()				# l: convert char to double
int	clgeti()			# l: get an int param
int	chk_valbals()			# l: check valid bals
real	clgetr()			# l: get a real param

begin
	# mark the stack
	call smark(sp)

	# get bal histogram info from param file
	BH_BAL_STEPS(bh) = clgeti("bal_steps")
	BH_START_BAL(bh) = clgetr("bal_start")
	BH_BAL_INC(bh) = clgetr("bal_inc")
	BH_BAL_EPS(bh) = clgetr("bal_epsilon")
	BH_END_BAL(bh) = BH_START_BAL(bh) + BH_BAL_STEPS(bh)*BH_BAL_INC(bh)

	# allocate a buffer for the valid histo values
	call salloc(valbals, BH_BAL_STEPS(bh), TY_REAL)
	# and fill with valid values
	do i=1, BH_BAL_STEPS(bh)
	    Memr[valbals+i-1] = BH_START_BAL(bh)+(BH_BAL_INC(bh)*(i-1))

	# pick out the values from the string	
	nvals = 1
	ip = 1
	while( TRUE ){
	    # get next value
	    nchar = ctod(balhisto, ip, dval)
	    # break on end of string
	    if( nchar ==0 ) break
	    # make sure we don't overflow
	    if( nvals > (MAX_BALS*2) )
		call error(1, "too many histogram values specified")
	    # stuff value into the array
	    vals[nvals] = dval
	    # make sure its a valid bal	(odd only)
	    if( mod(nvals,2) ==1 ){
	    if ( chk_valbals(Memr[valbals], vals[nvals],
			BH_BAL_STEPS(bh), BH_BAL_EPS(bh) ) == NO ) {
		call printf("invalid bal value: %.2f\n")
		call pargd(vals[nvals])
		call printf("valid bals range from %.2f to %.2f, every %.2f\n")
		call pargr(BH_START_BAL(bh))
		call pargr(BH_END_BAL(bh))
		call pargr(BH_BAL_INC(bh))
		call flush(STDOUT)
		call error(1, "invalid bal")
	    }
	    }
	    nvals = nvals + 1
	    # skip past commas and spaces
	    while((IS_WHITE(balhisto[ip])) || (balhisto[ip] == ','))
		ip = ip+1
	}
	nvals = nvals - 1
	# no values means no bals!
	if( nvals ==0 ){
	    tpercent = 100.0
	    j = 0
	}
	# one value means we have only a bal value at 100%
	else if( nvals ==1 ){
	    BH_BAL(bh,1) = vals[1]
	    BH_PERCENT(bh,1) = 100.0
	    tpercent = 100.0
	    mean = vals[1]
	    j = 1
	}
	else{
	    tpercent = 0.0
	    mean = 0.0
	    # make sure we have an even number of values
	    if( (nvals/2) == ((nvals-1)/2) )
		call error(1, "each bal must be accompanied by a percentage")
	    # get the histogram
	    j = 0
	    for(i=1; i<nvals; i=i+2){
		j = j+1
		BH_BAL(bh,j) = vals[i]
		BH_PERCENT(bh,j) = vals[i+1]
		tpercent = tpercent + BH_PERCENT(bh,j)
		mean = mean + BH_BAL(bh,j) * BH_PERCENT(bh,j)/100.0
	    }
	}
	# make sure we have close to 100% (frh 8/8/89)
	if( (tpercent<99.0) || (tpercent>101.0) )
	    call errorr(1, "bal histogram is not close to 100%", tpercent)
	BH_MEAN_BAL(bh) = mean
	BH_ENTRIES(bh) = j

	# free up stack space
	call sfree(sp)
end

#
#  CHK_VALBALS -- check new bal value against valid bals
#
int procedure chk_valbals(valbals, val, nn, epsilon )

real	valbals[ARB]			# i: valid bal values
double	val				# i: bal to check
int	nn				# i: number of bals in valbals
real	epsilon				# i: allowed epsilon from table BAL

int	ii				# l: loop counter
real	rval				# l: real value

begin
	rval = real(val)
	do ii = 1, nn {
	    # if we find a close bal, we are done
	    if ( abs(valbals[ii]-rval) < epsilon )
		return(YES)
	}
	return(NO)
end
