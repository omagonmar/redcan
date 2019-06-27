#$Header: /home/pros/xray/xspectral/source/RCS/xflux.x,v 11.0 1997/11/06 16:43:23 prosb Exp $
#$Log: xflux.x,v $
#Revision 11.0  1997/11/06 16:43:23  prosb
#General Release 2.5
#
#Revision 9.2  1997/06/11 18:00:28  prosb
#JCC(6/11/97) - change INDEF to INDEFD.
#
#Revision 9.1  1997/03/27 21:20:26  prosb
#JCC(3/27/97) - Rename flxd_do.x to flux_density.x
#
#Revision 9.0  1995/11/16  19:31:16  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:35:14  prosb
#General Release 2.3.1
#
#Revision 7.1  94/06/15  15:37:41  janet
#jd - fixed typo in deceleration_constant, had 2 l's.
#
#Revision 7.0  93/12/27  18:58:04  prosb
#General Release 2.3
#
#Revision 6.1  93/07/02  14:45:26  mo
#MC	7/2/93	Correct boolean initializations from YES/NO to TRUE/FALSE
#
#Revision 6.0  93/05/24  16:53:03  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:46:34  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  18:18:37  prosb
#General Release 2.0:  April 1992
#
#Revision 3.2  92/03/19  16:26:28  orszak
#jso - changed distanceunits to defaultunints for clarity.
#
#Revision 3.1  91/09/22  19:07:27  wendy
#Added
#
#Revision 3.0  91/08/02  01:59:13  prosb
#General Release 1.1
#
#Revision 2.2  91/07/19  14:48:41  orszak
#jso - changes to improve the output of xflux, and correction of miscalculated
#      distance.
#
#Revision 2.1  91/07/12  16:08:11  prosb
#jso - made spectral.h system wide and add calls to open new pset parameter
#
#Revision 2.0  91/03/06  23:02:57  pros
#General Release 1.0
#
# xflux.x
#
# Project:      PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
#
# Top level for the xflux task
#
# John : Jan 90


include <spectral.h>
include <ctype.h>
include "flux.h"
include "intermed.h"

define MAX_ENERGIES	15

define EXT_INT	"_int.tab"
define EXT_FLUX "_flux.tab"
define EXT_FLXD "_fd.tab"


procedure t_xflux()

#--
bool	flux				# Do I compute flux or flux density?
bool	density				# Do I compute density?

real 	energy1[MAX_ENERGIES]		# flux enegry or flux density range
real	energy2[MAX_ENERGIES]
int	nenergies

char	inroot[SZ_FNAME]		# file names
char	infile[SZ_FNAME]
char	outfile[SZ_FNAME]

pointer	itb				# input table pointer
pointer idata				# intermediate struct
pointer	np				# parameter pointer

char	str[SZ_LINE]			# Assorted junk variables
int	strptr

double	dval
int	junk

int	gctod()
bool	streq(), tbtacc()
pointer	tbtopn()
pointer	clopset()

begin

	np = clopset("pkgpars")

	call strcpy("",  infile, SZ_FNAME)			# Initilize
	call strcpy("", outfile, SZ_FNAME)			#
	density    = FALSE
	flux	   = FALSE
	
	call clgstr("fluxinter", inroot, SZ_FNAME)	# get intermediate file

	if ( streq("", inroot) )
	    call clgstr("intermediate", inroot, SZ_FNAME)

	if ( streq("NONE", inroot) )
		call error(1, "No intermediate file specified")

	call rootname(inroot, infile, EXT_INT, SZ_FNAME)

	if ( !tbtacc(infile) )
		call error(1, "can't access the intermediate file")


	call clgstr("energy", str, SZ_LINE)		# get energy or range
	call replace(str, ':', '!')			# change : to !
	strptr = 1


	# Parse the flux energies string into an array of energies or
	# a pair of energy ranges.
	#
	nenergies = 0
	while ( str[strptr] != EOS && nenergies <= MAX_ENERGIES ) {
	    nenergies = nenergies + 1

	    call skipwhite(str, strptr, SZ_LINE)
	    junk = gctod(str, strptr, dval)

	    if ( junk == 0 ) {
		call printf("can't convert string to double %s\n")
		 call pargstr(str[strptr])
		 call flush(STDOUT)
		call error(1, "numeric conversion failed")
	    }

	    energy1[nenergies] = dval
	    call skipwhite(str, strptr, SZ_LINE)

	    if ( str[strptr] == '!' ) {
		if ( density  )
		    call error(1, "can't mix flux and flux-density computations in one pass")
	        strptr = strptr + 1
	        call skipwhite(str, strptr, SZ_LINE)
	    	junk = gctod(str, strptr, dval)

		if ( junk == 0 ) {
		    call printf("can't convert string to double %s\n")
		     call pargstr(str[strptr])
		     call flush(STDOUT)
		    call error(1, "numeric conversion failed")
		}

	    	energy2[nenergies] = dval
	    	flux = TRUE
	    } else {
		if ( flux )
		    call error(1, "can't mix flux and flux-density computations in one pass")
		density	 = TRUE
	    }
	    call skipwhite(str, strptr, SZ_LINE)
	}

	itb = tbtopn(infile, READ_ONLY, 0)		# open input file
	call int_get(itb, idata)			# read intermed columns

	if ( density ) {
		call rootname(infile, outfile, EXT_FLXD, SZ_FNAME)
		call flux_density(idata, outfile, energy1, nenergies)
	} else {
		call rootname(infile, outfile, EXT_FLUX, SZ_FNAME)
		call flux_do(idata, outfile, energy1, energy2, nenergies)
	}

	call tbtclo(itb)
	call int_raze(idata)
	call clcpset(np)

end



#
# Get some parameters and return them.
#

procedure flux_params(h0, q0, dkpc, dz)

double	h0				# o:
double	q0				# o:
double	dkpc				# o:
double	dz				# o:

char	tok[SZ_LINE]
char	str[SZ_LINE]
double	distance			# distance for luminosity
int	dunits				# units for distance
int	strptr
int	chars_read

int	gctod()
real	clgetr()
bool	streq()

begin

	#read constants
	h0 = clgetr("Hubble_constant")
	q0 = clgetr("deceleration_constant")

	# read in distance
	call clgstr("distance", str, SZ_LINE)

	strptr = 1
	chars_read = gctod(str, strptr, distance)
	if ( chars_read == 0 ) {
		dkpc = INDEFD  #JCC(97):  INDEF->INDEFD 
		dz   = INDEFD  #JCC(97):  INDEF->INDEFD
		return
	}

	# does the distance have units?
	call skipwhite(str, strptr, SZ_LINE)
	if ( str[strptr] == EOS )
		call clgstr("defaultunits", tok, SZ_LINE)
	else
		call strcpy(str[strptr], tok, SZ_LINE)

	# what are the units
	if ( streq("kpc", tok) )
		dunits = KPC
	else if ( streq("z", tok) )
		dunits = RED
	else {
		call printf("Unknown units specified for distance: %s\n")
		call pargstr(tok)
		call flush(STDOUT)
		call error(1, "in xflux")
	}

	# if we have zedshift compute kpc and return both, if we have
	# kpc redshift is undefined
	if ( dunits == RED ) {
		dz = distance
		if ( q0 != 0 ) {
			dkpc = C / ( h0 * q0**2 ) *
				( distance * q0 + ( q0 - 1 ) *
					( -1 + sqrt(2 * q0 * distance + 1 )))
		}
		else {
			dkpc = C * distance / h0 * ( 1 + distance / 2 )
		}
		dkpc = dkpc * 1000
	}
	else {
		dz 	= INDEFD
		dkpc	= distance
	}
end



procedure skipwhite(str, ptr, size)


char	str[ARB]
int	ptr, size
#--

begin
	while ( IS_WHITE(str[ptr]) && ( ptr < size ) ) ptr = ptr + 1
end


procedure replace(str, c1, c2)

char	str[ARB]
int	c1, c2
#--

int	i

begin
	i = 1
	while ( str[i] != EOS ) {
		if ( str[i] == c1 ) str[i] = c2
		i = i + 1
	}
end
