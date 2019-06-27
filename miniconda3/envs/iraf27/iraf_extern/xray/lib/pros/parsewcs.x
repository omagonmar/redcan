#$Header: /home/pros/xray/lib/pros/RCS/parsewcs.x,v 11.0 1997/11/06 16:21:03 prosb Exp $
#$Log: parsewcs.x,v $
#Revision 11.0  1997/11/06 16:21:03  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:28:09  prosb
#General Release 2.4
#
#Revision 8.1  1994/09/13  15:21:51  dvs
#(Mo's changes...something to do with WCS matrices)
#
#Revision 8.0  94/06/27  13:46:56  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:10:24  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:53:50  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:17:17  prosb
#General Release 2.1
#
#Revision 4.2  92/09/14  14:57:10  prosb
#MC	9/14/92		Reformat the descriptive string, using hh:mm:ss
#			and an extra line to prevent wrap-around.
#
#Revision 4.1  92/07/09  17:28:14  mo
#No changes - bug was in coord_eq.f
#
#Revision 4.0  92/04/27  13:49:35  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  92/03/30  12:05:08  mo
#MC	3/30/92		Fix spelling of 'EQUATORIAL'
#
#Revision 3.0  91/08/02  01:01:13  wendy
#General
#
#Revision 2.1  91/04/12  09:58:44  mo
#MC	3/91		Improve the error message for 'unknown system'
#			to be clearer for the case of 'image file does
#			not exist".  This was needed for skypix applications.
#			This was the cheap solution since this routine
#			is called by many applications.
#
#Revision 2.0  91/03/07  00:07:21  pros
#General Release 1.0
#
# Module:       PARSEWCS.X
# Project:      PROS -- ROSAT RSDC
# Purpose:      Convert between MWCS and ASCII strings
# External:     < routines which can be called by applications>
# Local:        < routines which are NOT intended to be called by applications>
# Description:  < opt, if sophisticated family>
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} JR  -- initial version  -- 1990   
#               {1} Mc  -- Add error message for non-existent image -- 2/91
#               {n} <who> -- <does what> -- <when>
#


include <ctype.h>
include <math.h>
include <qpoe.h>
include <precess.h>

# ParseWCS -- extract the coordinate system from the user input string.
#
#  This code is a poor expression of the following intended legal inputs
#
#	Galactic
#	Supergalactic
#	Ecliptic <year>
#	Equatorial <J|B>year[@<year>]
#	Jxxxx
#	Bxxxx
#	IMAGE
#
#	TANGENT <x> <y> <arcx> <arcy> = <ra> <dec> <roll> <system>
#


procedure str2wcs(istring, ostring, mw, system, equix, epoch)

char	istring[ARB]			# i: input description
char	ostring[ARB]			# o: expanded description
pointer	mw				# o: mwcs transform
int	system				# o: sky system <precess.h>
double	equix				# o: sky equinox
double	epoch				# o: B1950 sky epoch
#--

char	spec[SZ_LINE]			# the coordinate system input spec
int	i
int	junk

double	r[2]				# things to build the wcs
double	w[2]
double	arc[2]
double	roll

char	t[132]

int	strdic(), gctod(), ctowrd()
int	axis[2]

begin
	i = 1

	call refwcsim(istring, mw, system, equix, epoch)

	if ( mw != NULL ) {
		call wcs2str(mw, system, equix, epoch, t)
		call strcpy(istring, ostring, SZ_LINE)
		call strcat(" is \n          ", ostring, SZ_LINE)
		call strcat(t, ostring, SZ_LINE)
		return
	}

	call strupr(istring)

	junk = ctowrd(istring, i, spec, SZ_LINE)

	system = strdic(spec, spec, SZ_LINE,
		"|GALACTIC|SUPERGALACTIC|ECLIPTIC|EQUATORIAL| |IMAGE|TANGENT") + 1

	if ( system == TAN ) {
	    junk = gctod(istring, i, r[1])
	    junk = gctod(istring, i, r[2])
	    junk = gctod(istring, i, arc[1])
	    junk = gctod(istring, i, arc[2])

	    while ( IS_WHITE(istring[i]) ) i = i + 1
	    if ( istring[i] != '=' ) call error(1, "Bad projection spec\n")

	    i = i + 1

	    junk = gctod(istring, i, w[1])
	    junk = gctod(istring, i, w[2])
	    junk = gctod(istring, i, roll)
			
	    call mkwcs(r, w, arc, roll, mw)
	    axis[1] = 1
	    axis[2] = 2
	    call mw_swtype(mw, axis, 2, 
			"tan", "axis 1: axtype=ra axis 2: axtype=dec")


	    junk = ctowrd(istring, i, spec, SZ_LINE)
	    system = strdic(spec, spec, SZ_LINE,
		"|GALACTIC|SUPERGALACTIC|ECLIPTIC|EQUATORIAL") + 1
	}	

	if ( system == ECL ) {
	    junk = gctod(istring, i, equix)		# Crunch the equix number
	} else if ( system == 1 || system == FK5 ) {
	    if ( system == FK5 ) junk = ctowrd(istring, i, spec, SZ_LINE)

	    switch ( spec[1] ) {
	        case 'B':
	            system = FK4
	        case 'J':
		    system = FK5
		default:
		   call eprintf("invalid coordinate system specification: %s\n")
			call pargstr(istring)
		   call error(1,"If this is a file - it doesn't exist")
	    }
	    i = 2
	    junk = gctod(spec, i, equix)	# Crunch the equinox number

	    if ( system == FK4 && istring[i] == '@' ) {
	        i = i + 1
	        junk = gctod(spec, i, epoch)	# Crunch the epoch number
	    } else {
	        epoch = 1950.0
	    }

	    if ( ( system == FK4 ) && ( equix == 1950.D0 ) ) system = B1950
	    if ( ( system == FK5 ) && ( equix == 2000.D0 ) ) system = J2000
	}

	# Rebuild the string from the parsed numbers
	#
	call wcs2str(mw, system, equix, epoch, ostring)	
end



procedure refwcsim(imname, mw, system, equix, epoch)

char	imname[ARB]				# i: name of an image
pointer	mw					# o: image wcs
int	system					# o: im sky system <precess.h>
double	equix					# o: equinox
double	epoch					# o: B1950 obsv date
#--

pointer	im, imh
pointer	immap()
errchk	immap()

double	cal_be()
pointer	mw_openim()
bool	streq()
#char	buf[SZ_LINE]

begin
	iferr ( im = immap(imname, READ_ONLY, 0) ) {
#	    call eprintf(buf,"Unable to open file: %s\n",SZ_LINE)
#		call pargstr(imname)
#	    call error(1,buf)
	    mw = NULL
	    system = -1
	    equix = 0.0
	    epoch = 0.0
	    return
	}

	call get_imhead(im, imh)

	equix = QP_EQUINOX(imh)
	epoch = 0.0

	#switch
	     if ( streq(QP_RADECSYS(imh), "FK5") )      system = FK5
	else if ( streq(QP_RADECSYS(imh), "FK4") )      system = FK4
	else if ( streq(QP_RADECSYS(imh), "FK4-NO-E") ) system = FK4
	else if ( streq(QP_RADECSYS(imh), "ELC") )      system = ECL
	else if ( streq(QP_RADECSYS(imh), "GAL") )      system = GAL
	else {
		system = FK4
		equix   = 1950.00
	}

	if ( system == FK5 && equix == 2000.00 )
		system = J2000

	if ( system == FK4 ) {
	    epoch = cal_be(double(QP_MJDOBS(imh)) + 2400000.5D0)

	    if ( equix == 1950.00 ) 
		system = B1950
	}

	mw = mw_openim(im)
end


# Make a WCS matrix from reference points and rotation angle
procedure mkwcs(r, w, arc, roll, mw)

double r[ARB]			# i: input reference pixel (x,y)
double w[ARB]			# i: input world position 
double arc[ARB]			# i: input pixel sizes (deg/pix)
double roll
pointer mw			# o: pointer to mw object
#--

double	theta
double	m[2, 2]

begin
	theta = DEGTORAD(roll)

	m[1, 1] =      arc[1]  * cos(theta)
	m[1, 2] =  abs(arc[2]) * sin(theta)
	m[2, 1] = -abs(arc[1]) * sin(theta)
	m[2, 2] =      arc[2]  * cos(theta)
	if ( arc[1] < 0 )
	    m[1, 2] = -m[1, 2]
	if ( arc[2] < 0 )
	    m[2, 1] = -m[2, 1]

	call mkwcs2(r,w,m,mw)
end


# Make a WCS matrix from reference points and rotation matrix
procedure mkwcs2(r, w, m, mw)

double r[ARB]			# i: input reference pixel (x,y)
double w[ARB]			# i: input world position 
double m[2,ARB]			# i: input CD matrix (from WCS)
pointer mw			# o: pointer to mw object
#--

pointer mw_open()
int	ndim
#double	theta

begin
	mw = NULL
	ndim = 2

	mw = mw_open(mw, ndim)	 			# Make a wcs.

	call mw_newsystem (mw, "image", ndim)

#	theta = DEGTORAD(roll)

#	m[1, 1] =      arc[1]  * cos(theta)
#	m[1, 2] =  abs(arc[2]) * sin(theta)
#	m[2, 1] = -abs(arc[1]) * sin(theta)
# 	m[2, 2] =      arc[2]  * cos(theta)
#	if ( arc[1] < 0 )
#	    m[1, 2] = -m[1, 2]
#	if ( arc[2] < 0 )
#	    m[2, 1] = -m[2, 1]

	call mw_swtermd(mw, r, w, m, ndim)
	call mw_sdefwcs (mw)
end

procedure bkwcs(mw, r, w, arc, roll)

pointer mw			# i: pointer to mw object
double r[ARB]			# o: output reference pixel (x,y)
double w[ARB]			# o: output world position 
double arc[ARB]			# o: output pixel sizes (deg/pix)
double roll			# o: output roll angle (degrees)
#--

double	m[2,2]

begin
	call bkwcs2(mw, r, w, arc, roll, m)

end

procedure bkwcs2(mw, r, w, arc, roll, m)

pointer mw			# i: pointer to mw object
double r[ARB]			# o: output reference pixel (x,y)
double w[ARB]			# o: output world position 
double arc[ARB]			# o: output pixel sizes (deg/pix)
double	roll			# o: output rotation angle (degrees)
double	m[2, ARB]		# o: output CD matrix
#--

double	ltm[2, 2]		# The Logical terms
double	ltv[2]

double	ilm[2, 2]		# The inverted L term
double	xm[2, 2]		# The logical -> World transform matrix

double	m1, m2, m1m2
double	theta

pointer	ct, mw_sctran()

begin

	call mw_ssystem(mw, "world")

	call mw_gwtermd(mw, r, w, m, 2)
	call mw_gltermd(mw, ltm, ltv, 2)

	ct = mw_sctran(mw, "physical", "logical", 3)
	call mw_c2trand(ct, r[1], r[2], r[1], r[2])

	call mw_invertd(ltm, ilm, 2)
	call mw_mmuld(ilm, m, xm, 2)

	m1 = sqrt(xm[1, 1]**2 + xm[2, 1]**2)
	m2 = sqrt(xm[1, 2]**2 + xm[2, 2]**2)

	m1m2 = sign(1.0d0, xm[1, 1] * xm[2, 2] - xm[1, 2] * xm[2, 1])

	# Here we asume an astronomical image with RA increasing to the 
	# left and X increasing to the right.  All others beware.
	#
	if ( m1m2 > 0 ) { 				# +CDELT1 && +CDELT2
		theta  = atan2( xm[1, 2], xm[2, 2])
		arc[1] = m1
		arc[2] = m2
	} else {					# -CDELT1 && -CDELT2
		theta  = atan2(-xm[1, 2], xm[2, 2])
		arc[1] = -m1
		arc[2] =  m2
	}

	roll  = RADTODEG(theta)
end


procedure wcs2str(mw, system, equix, epoch, str)

pointer	mw
int	system
double	equix
double	epoch
char	str[ARB]
#--

int	i, strlen()

double  r[2]				# a broken wcs.
double  w[2]
double	arc[2]
double  roll

begin
	i = 1

	if ( mw != NULL ) {
		call bkwcs(mw, r, w, arc, roll)
		call sprintf(str, SZ_LINE, "%13s %g %g %g %g = \n\t\t%.2H %.1h %g\n                 ")
		 call pargstr("TANGENT")
		 call pargr(real(r[1]))
		 call pargr(real(r[2]))
		 call pargr(real(arc[1]))
		 call pargr(real(arc[2]))
		 call pargr(real(w[1]))
		 call pargr(real(w[2]))
		 call pargr(real(roll))

		i = strlen(str)
	}

	switch ( system ) {
	case FK4, FK5, J2000, B1950 :
	    call sprintf(str[i], SZ_LINE, "%13s %c%-7g")
	    call pargstr("EQUATORIAL")
	    switch ( system ) {
	    case FK4, B1950 :
		call pargi('B')
	    case FK5, J2000 :
		call pargi('J')
	    }
	    call pargd(equix)
	case ECL :
	    call sprintf(str[i], SZ_LINE, "%13s  %-7g")
	    call pargstr("ECLIPTIC")
	    call pargd(equix)
	case GAL :
	    call sprintf(str[i], SZ_LINE, "%20s")
	    call pargstr("GALACTIC")
	case SGL :
	    call sprintf(str[i], SZ_LINE, "%20s")
	    call pargstr("SUPERGALACTIC")
	}
end
