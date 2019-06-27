#$Header: /home/pros/xray/lib/coords/RCS/precess.x,v 11.0 1997/11/06 16:24:21 prosb Exp $
#$Log: precess.x,v $
#Revision 11.0  1997/11/06 16:24:21  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:32:12  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:37:40  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:21:37  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:03:08  prosb
#General Release 2.2
#
#Revision 5.1  93/04/26  23:54:22  dennis
#Regions system rewrite.
#
#Revision 5.0  92/10/29  21:22:32  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:13:11  prosb
#General Release 2.0:  April 1992
#
#Revision 2.0  91/03/07  00:32:43  pros
#General Release 1.0
#
# precess.x
#
# This routine calls the proper transformations from the coords librayr
# to effect the coordinate transformation that he user has specified.
#

include <precess.h>



procedure precess(x, y, icsystem, iequix, iepoch, 
		  tx, ty, ocsystem, oequix, oepoch, display)

double	x, y, tx, ty
double	iepoch, iequix, oequix, oepoch
int	icsystem, ocsystem
int	display
#--

int	ixsystem
int	oxsystem
double	ixepoch, oxepoch
double 	date

double	caltbe()


include "precess.com"

begin
	tx = x
	ty = y

# Fix up non-FK4 epoch
#
	ixepoch = 0.0
	oxepoch = 0.0

	if ( ( icsystem == FK4 ) || ( icsystem == B1950 ) ) ixepoch = iepoch
	if ( ( ocsystem == FK4 ) || ( ocsystem == B1950 ) ) oxepoch = oepoch

# No Purchase Necessary
#
	if ( icsystem == ocsystem && iequix == oequix && ixepoch == oxepoch )
		return

# Precession only trap
#
# FKX --> FKX

	if ( 	   ( icsystem == FK4 || icsystem == B1950 ) 
		&& ( ocsystem == FK4 || ocsystem == B1950 ) ) { 

		if ( display >= 3 ) call eprintf("Precess in FK4\n")
		call cprecb(iequix,  oequix, imatrix)
		call cprecm(tx, ty, imatrix)
		return
	}
	if (	   ( icsystem == FK5 || icsystem == J2000 ) 
		&& ( ocsystem == FK5 || ocsystem == J2000 ) ) {

		if ( display >= 3 ) call eprintf("Precess in FK5\n")
		call cprecj(iequix,  oequix, imatrix)
		call cprecm(tx, ty, imatrix)
		return
	}

# Set up I/O precession matricies
#
	if ( icsystem == FK4 ) {
	    if ( display >= 3 ) call eprintf("Setting up B in to B1950 precession matrix\n")
	    call cprecb(iequix, 1950.D0, imatrix)	# from in to B1950
	}
	if ( ocsystem == FK4 ) {
	    if ( display >= 3 ) call eprintf("Setting up B1950 to B out precession matrix\n")
	    call cprecb(1950.D0, oequix, omatrix)	# B1950 to out
	}
	if ( icsystem == FK5 ) { 
	    if ( display >= 3 ) call eprintf("Setting up J in to J2000 precession matrix\n")
	    call cprecj(iequix, 2000.D0, imatrix)	# from in to J2000
	}
	if ( ocsystem == FK5 ) {
	    if ( display >= 3 ) call eprintf("Setting up J2000 to J out precession matrix\n") 
	    call cprecj(2000.D0, oequix, omatrix)	# J2000 to out
	}

# Pre-Switch ( icsystem )
#
# FK4	--> B1950
# FK5	--> J2000
# ECL	--> J2000
# SGL	--> Gal
#
	switch ( icsystem ) { 
	case FK4 :
	    if ( display >= 3 ) call eprintf("Precess FK4 to B1950FK4\n")
	    call cprecm(tx, ty, imatrix)
	    ixsystem = B1950

	case FK5 :
	    if ( display >= 3 ) call eprintf("Precess FK5 to J2000FK5\n")
	    call cprecm(tx, ty, imatrix)
	    ixsystem = J2000

	case ECL :    
	    if ( display >= 3 ) call eprintf("Convert Ecliptic@date to J2000FK5\n")
	    date = caltbe(iequix)
	    call cde2j(tx, ty, date, tx, ty);
	    ixsystem = J2000; 

	case SGL :
	    if ( display >= 3 ) call eprintf("Convert Super to Galactic\n")
	    call cds2g(tx, ty, tx, ty);
	    ixsystem = GAL
	case J2000, B1950, GAL:
	    ixsystem = icsystem

	default:
	    call error(1, "Bad case in Pre x-Switch")
	}



#
# Mid-Switch ( ixsystem x oxsystem )
#
# B1950 --> J2000
# 	    Gal
# J2000 --> B1950
#	    Gal
# Gal	--> B1950
#	    J2000
#

define B1950xB1950	0
define B1950xJ2000 	1
define B1950xGAL	2
define J2000xB1950	3
define J2000xJ2000	4
define J2000xGAL	5
define GALxB1950	6
define GALxJ2000	7
define GALxGAL		8

	switch ( ocsystem ) {		# set up the x-cross
	case FK4, B1950 :
	    oxsystem = B1950
	case FK5, J2000, ECL :
	    oxsystem = J2000
	case GAL, SGL :
	    oxsystem = GAL
	default:
	    call error(1, "Bad case in the Setup x-Switch")
	}

	switch ( ( ixsystem * 3 ) + oxsystem ) {
	case B1950xJ2000 :
	    if ( display >= 3 ) call eprintf("Convert B1950FK4 to J2000FK5\n")
	    call cdb2j(tx, ty, ixepoch, tx, ty)

	case B1950xGAL :
	    if ( display >= 3 ) call eprintf("Convert B1950FK4 to Galactic\n")
	    call cdb2g(tx, ty, tx, ty)

	case J2000xB1950 :
	    if ( display >= 3 ) call eprintf("Convert J2000FK5 to B1950FK4\n")
	    call cdj2b(tx, ty, oxepoch, tx, ty)

	case J2000xGAL :
	    if ( display >= 3 ) call eprintf("Convert J2000FK5 to Galactic,\n")
	    call cdj2g(tx, ty, tx, ty)

	case GALxB1950 :
	    if ( display >= 3 ) call eprintf("Convert Galactic to B1950FK4\n")
	    call cdg2b(tx, ty, tx, ty)

	case GALxJ2000 :
	    if ( display >= 3 ) call eprintf("Convert Galactic to J2000FK5\n")
	    call cdg2j(tx, ty, ty, tx)

	case B1950xB1950, J2000xJ2000, GALxGAL :
	default:
	    call error(1, "Bad case in the x-Switch")
	}

# Post-Switch ( ocsystem )
#
# B1950	--> FK4
# J2000	--> FK5
#	    ECL
# Gal	--> SGL

	switch ( ocsystem ) {
	case FK4, FK5 :
	    if ( display >= 3 ) call eprintf("Precess to out epoch\n")
	    call cprecm(tx, ty, omatrix)

	case ECL :
	    if ( display >= 3 ) call eprintf("Convert J2000FK5 to Ecliptic@date\n")
	    date = caltbe(oequix)
	    call cdj2e(tx, ty, date, tx, ty)	    

	case SGL :
	    if ( display >= 3 ) call eprintf("Convert Galactic to Super\n")
	    call cdg2s(tx, ty, tx, ty)

	case B1950, J2000, GAL :
	default:
	    call error(1, "Bad case in Post x-Switch")
	}
end

