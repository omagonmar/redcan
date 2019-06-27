#$Header: /home/pros/xray/xplot/imcontour/RCS/imc_skymap.x,v 11.0 1997/11/06 16:38:10 prosb Exp $
#$Log: imc_skymap.x,v $
#Revision 11.0  1997/11/06 16:38:10  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:08:59  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:02:16  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:48:40  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:41:10  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:35:14  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  17:32:47  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:24:04  prosb
#General Release 1.1
#
#Revision 1.1  91/07/26  03:02:40  wendy
#Initial revision
#
#Revision 2.0  91/03/06  23:21:07  pros
#General Release 1.0
#
# ---------------------------------------------------------------------
#
# Module:	IMC_SKYMAP.X
# Project:	PROS -- ROSAT RSDC
# Purpose:	Plot a skymap grid for imcontour
# Includes:	skymap_grid(), sph_cart(), cart_sph(), cha_near(),
#		round_up(), chtext(), rad_hms(), rad_dms()
# Modified:	{0} Janet DePonte -- October 1989 -- modified original ST code
#		{n} <who> -- <when> -- <does what>
#
# ---------------------------------------------------------------------
include <gset.h>
include <math.h>
include <mach.h>
include "imcontour.h"
include "clevels.h"
# ---------------------------------------------------------------------
#
# Function:	skymap_grid
# Purpose:	plot skymap grid on graphics display
#
# ---------------------------------------------------------------------
procedure skymap_grid (gp, pl_cnst, ty_grid, gr_label)

pointer	gp				# i/o: GIO structure descriptor
pointer	pl_cnst				# i:   Plate constants descriptor
int	ty_grid				# i:   grid type - FULL or TICS or NONE
int     gr_label			# i:   grid label - IN or OUT or NONE

# Spherical celestial coordinates
double	racen, deccen			# Coordinates of chart center
double	nera,  nwra,  sera,  swra	# RA of plot Corners
double	nedec, nwdec, sedec, swdec	# Dec of plot corners
double	ra, dec				
double	tcra, tcdec, bcra, bcdec	# Center coordinates
double	ramax,  ramin			# extremes of ra
double	decmax, decmin			# extremes of dec
double	raint,  raran,  rasec,  rasr,  rexgap,  rainc
double	decint, decran, decsec, decsr, dexgap
double	delra
double	sgn

# Cartesian plate (plot) coordinates
real	x, x1, x2, xpole
real	y, y1, y2, ypole
real	left, right, bottom, top	# Plot corners

bool	polar, nearpole
bool	donext, alternate
double	decchk
pointer	sp, label, units
pointer lbuff, ubuff			# label & units format buffers

double	escale, nscale, sscale
real	xleast, xmost, xrange
real	yleast, ymost, yrange
int	linra, lindec
real	edge
bool	north

# Declination intervals in seconds of arc
define	NDECGAP		12
double	decgap[NDECGAP]
#               1"   6"   12"   30"   1'    6'     12'    30'    1d
#		2d     5d     10d
data	decgap /1.0, 6.0, 12.0, 30.0, 60.0, 360.0, 720.0, 1.8e3, 3.6e3, 
		7.2e3, 1.8e4, 3.6e4/

# R.A. intervals in seconds of time
define	NRAGAP		13
double	ragap[NRAGAP]
#              1s   2s   5s   10s   20s   30s   1m    2m     5m     10m
#	       20m    30m    1h
data	ragap /1.0, 2.0, 5.0, 10.0, 20.0, 30.0, 60.0, 120.0, 300.0, 600.0, 
	       1.2e3, 1.8e3, 3.6e3/

double	cha_near()
double  round_up()
bool	fp_equald()

begin 
	call smark (sp)
	call salloc (label, SZ_LINE, TY_CHAR)
	call salloc (units, SZ_LINE, TY_CHAR)
	call salloc (lbuff, SZ_LINE, TY_CHAR)
	call salloc (ubuff, SZ_LINE, TY_CHAR)

	# RA, Dec of plot center in radians
	racen  = CEN_RA(pl_cnst)
	deccen = CEN_DEC(pl_cnst)

	north = deccen >= 0.0d0

	# Chart corners in mm
 	call gseti  (gp, G_WCS, MM_R_WCS)
 	call ggwind (gp, left, right, bottom, top)

	# Draw edges of viewport/window
	call gseti  (gp, G_PLTYPE, GL_SOLID)
	call gamove (gp, left,  bottom)
	call gadraw (gp, right, bottom)
	call gadraw (gp, right, top)
	call gadraw (gp, left,  top)
	call gadraw (gp, left,  bottom)
	
	# Is the pole on the chart?

	if (fp_equald (deccen, 0.0d0))
	    sgn = 0.0d0
	else
	    sgn = HALFPI * deccen / abs (deccen)

	# Find rectangular coordinates of pole
	call sph_cart (racen, sgn, xpole, ypole, pl_cnst)

	polar = xpole <= left && 
		xpole >= right && 
		ypole >= bottom && 
		ypole <= top

	# RA, Dec of each corner 
	call cart_sph (left,  bottom, sera, sedec, pl_cnst)
	call cart_sph (right, bottom, swra, swdec, pl_cnst)
	call cart_sph (left,  top,    nera, nedec, pl_cnst)
	call cart_sph (right, top,    nwra, nwdec, pl_cnst)

	# Is it nearly polar?
	nearpole = max (abs (sedec), abs (nedec)) >= ALMOST_POLE || polar

	# Adjust for the Case where Chart Straddles 0H. RA
	if (nwra > nera)
	    nwra = nwra - TWOPI
	if (swra > sera)
	    swra = swra - TWOPI

	if (polar) {
	    # Pole is on the chart
	    call gmark (gp, xpole, ypole, GM_PLUS, 3.0, 3.0)

	    ramin = 0.0
	    ramax = TWOPI

	    if (north) {
		decmin = min (nwdec, swdec)
		decmax = HALFPI - (HALFPI - decmin) * 0.1d0
	    } else {
		# South
		decmax = max (nwdec, swdec)
		decmin = -HALFPI - (-HALFPI - decmax) * 0.1d0
	    }

	    raran  = ramax  - ramin
	    decran = decmax - decmin

	} else {
	    # Pole is outside the chart
	    # Find Extreme Dec. on Chart
	    call cart_sph (0.0, top, tcra, tcdec, pl_cnst)
	    call cart_sph (0.0, bottom, bcra, bcdec, pl_cnst)

	    # Range and extremes of RA in radians
	    # bearing in mind that the plot may be reversed
	    if (north) {
		ramax = nera
		ramin = nwra
	    } else {
		# South
		ramax = sera
		ramin = swra
	    }

	    raran = ramax - ramin

	    # Dec. Range and Extremes
	    if (tcdec < 0.0d0)
		# Top South
		decmax = nwdec
	    else
		# Top North
		decmax = tcdec

	    if (bcdec < 0.0d0)
		# Bottom South
		decmin = bcdec
	    else
		# Bottom North
		decmin = swdec

	    decran = decmax - decmin
	# Polar?
	}

	# Use dotted lines for full grid
	if ( ty_grid == FULL ) {
	   call gseti (gp, G_PLTYPE, GL_DOTTED)
	}
	call gseti (gp, G_CLIP, YES)
	call gsetr (gp, G_PLWIDTH, 1.0)
	call gsetr (gp, G_TXSIZE, 0.75)

	# Grid-Line Interval in RA (in Seconds of Time)
	rasr = RADTOST(raran)
	rexgap = rasr / RA_NUM_TRY

	# Rounded RA interval in seconds of time
	raint = cha_near (rexgap, ragap, NRAGAP)
	rasec = mod (round_up (RADTOST(ramin), raint), double (STPERDAY))

#	repeat {
	ra = STTORAD(rasec)
        do while ( ra < ramax ) {
	    # Plot the Meridians of Equal RA
	    call sph_cart (ra, decmax, x1, y1, pl_cnst)

	    call sph_cart (ra, decmin, x2, y2, pl_cnst)
	    if ( ty_grid == FULL ) {
	       call gamove (gp, x1, y1)
	       call gadraw (gp, x2, y2)
	    }
	    rasec = rasec + raint

	    ra = STTORAD(rasec)
#	} until (STTORAD(rasec) > ramax)
	}
	# Choose Grid-Line Gap for Dec.  (in seconds of arc)
	decsr  = RADTOSA(decran)
	dexgap = decsr / DEC_NUM_TRY

	# Find 'Rounded' Figure for Dec Gap
	decint = cha_near (dexgap, decgap, NDECGAP)

	# Starting line of declination
	decsec = round_up (RADTOSA(decmin), decint)

	ramax = ramax + rainc / 2.0
	delra = 1.0 / RA_INCR

	repeat {
	    # For each line of constant declination
	    dec = SATORAD(decsec)
	    ra  = ramin
	    call sph_cart (ra, dec, x, y, pl_cnst)
	    call gamove (gp, x, y)

	    # RA increment per polyline segment along lines of declination
	    # is based on the width of the side with least RA range and the 
	    # declination
	    if (polar) {
		rainc = decran * delra
	    } else if (north) {
		rainc = (sera - swra) * delra
	    } else {
		# South
		rainc = (nera - nwra) * delra
	    }

	    repeat {
		# For each segment in the polyline
		ra = ra + rainc
 	        call sph_cart (ra, dec, x, y, pl_cnst)

		# draw only if full grid set
	        if ( ty_grid == FULL ) {
		   call gadraw (gp, x, y)
	        }
	    } until (ra > ramax) 

	    decsec = decsec + decint

	} until (SATORAD(decsec) > decmax)

	# Get Scale of E,W Sides (ESCALE)
	# and N,S,Sides (NSCALE,SSCALE)
	# in radians/mm.

	escale = (nedec - sedec) / (top - bottom)
	nscale = (nera 	- nwra)  / (left - right)
	sscale = (sera  - swra)  / (left - right)

#   1.  Mark Dec. Scales up Sides
#       If near the Pole,due to Non-linear Side Dec Scale,
#       Marks are not down both edges,but on Centre Meridian
#       Only.

	yleast = top
	ymost  = bottom
	lindec = 0

	if (nearpole) {
	    decsec = round_up (RADTOSA(decmin), decint)
	    decchk = decmax
	} else {
	    decsec = round_up (RADTOSA(sedec), decint)
	    decchk = nedec
	}

	repeat {
	    dec = SATORAD(decsec)
	    if (nearpole) 
		call sph_cart (racen, dec, x, y, pl_cnst)
	    else
		y = ((dec - sedec) / escale) - top

	    decsec = decsec + decint
	    lindec = lindec + 1

	    if (y < yleast)
		yleast= y
	    if (y > ymost)
		ymost = y

	} until (SATORAD(decsec) > decchk)

	yrange = ymost - yleast
	if (lindec >= 5) {
	    alternate = true
	    donext = true
	    if ((lindec/2*2) != lindec)
		lindec = lindec + 1
	    lindec = lindec / 2
	} else {
	    alternate = false
	    donext = true
	}

	if (nearpole) 
	    decsec = round_up (RADTOSA(decmin), decint)
	else
	    decsec = round_up (RADTOSA(sedec), decint)

	edge = (left - right) / EDGE_FACTOR

	if ( gr_label == OUT ) {
 	   call sprintf (Memc[lbuff], 12, "h=r;v=c;q=h")
 	   call sprintf (Memc[ubuff], 12, "h=r;v=b;q=h")
   	} else if ( gr_label == IN ) {
 	   call sprintf (Memc[lbuff], 12, "h=l;v=c;q=h")
 	   call sprintf (Memc[ubuff], 12, "h=l;v=b;q=h")
	}

	repeat {
	    dec = SATORAD(decsec)

	    if (!alternate)
		donext = true

	    if (nearpole) {
		call sph_cart (racen, dec, x, y, pl_cnst)
		if (abs (y) <= top) 
		    if (donext) {
			call rad_dms (dec, Memc[label], Memc[units], SZ_LINE)
			if ( gr_label != NO_LABEL ) {
			  call gtext (gp, x, y, Memc[label], "h=c;v=c;q=h")
			  call gtext (gp, x, y, Memc[units], "h=c;v=b;q=h")
			}
			donext = false
		    } else
			donext = true
	    } else {

		# x coordinate is dependant on label orientation 
	        if ( gr_label == OUT ) {
		   x = left
	        } else if ( gr_label == IN ) {
		   x = left - edge
		}
		y = ((dec - sedec) / escale) - top
		if ( ty_grid == TICS ) {
		   call gamove (gp, left, y)
		   call gadraw (gp, left-0.5*edge, y)
		   call gamove (gp, right, y)
		   call gadraw (gp, right+0.5*edge, y)
		}
		if (donext) {
		    call rad_dms (dec, Memc[label], Memc[units], SZ_LINE)
		    if ( gr_label != NO_LABEL ) {
		       call gtext (gp, x, y, Memc[label], Memc[lbuff])
		       call gtext (gp, x, y, Memc[units], Memc[ubuff])
		    }
		    donext = false
		} else
		    donext = true
	    }
	    decsec = decsec + decint

	} until (SATORAD(decsec) > decchk)
#
#   2.  Mark RA on Southern Side
#       only if the RA Range is Reasonable (< 7H RA )
#
	if (sera - swra <= (7.0/6.0)*HALFPI) {

	    linra  = 0
	    xleast = left
	    xmost  = right
	    rasec  =  mod (round_up (RADTOST(swra), raint), double (STPERDAY))

	    repeat {

		ra = STTORAD(rasec)
		x  = ((ra - swra) / sscale) + right

		if (x < xleast) {
		    xleast = x
		}
		if (x > xmost) {
		    xmost = x
		}
		linra = linra + 1
		rasec = rasec + raint

	    } until (STTORAD(rasec) >= sera)

	    xrange = xmost - xleast
	    if (linra >= 5) {
		alternate = true
		if ((linra / 2 * 2) != linra) {
		    linra = linra+1
		} else {
		    xrange = xrange * (real (linra) - 2.0) / 
			     (real (linra) - 1.0)
		}
		linra = linra / 2
	    } else {
		alternate = false
	    }

	    if ( gr_label == OUT ) {
	       y = bottom - edge
	    } else if ( gr_label == IN ) {
	       y = bottom + 1.5*edge
	    }

	    rasec = mod (round_up (RADTOST(swra), raint), double(STPERDAY))
	    donext = false

	    repeat {
		ra = STTORAD(rasec)
		x  = ((ra - swra) / sscale) + right
		call rad_hms (ra, Memc[label], Memc[units], SZ_LINE)

		if ( ty_grid == TICS ) {
		   call gamove (gp, x, bottom)
		   call gadraw (gp, x, bottom+.5*edge)
		   call gamove (gp, x, top)
		   call gadraw (gp, x, top-.5*edge)
		}
		if (!alternate) {
		    donext = true
		}
		if (donext) {
		    if ( gr_label != NO_LABEL ) {
		       call gtext (gp, x, y, Memc[label], "h=c;v=t;q=h")
		       call gtext (gp, x, y, Memc[units], "h=c;v=c;q=h")
		    }
		    donext = false
		} else {
		    donext = true
		}
		rasec = rasec + raint

	    } until (STTORAD(rasec) > sera)
	}

	call sfree (sp)
end

# ---------------------------------------------------------------------
#
# Function:	sph_cart
# Purpose:	Convert equatorial celestial coordinates to cartesian 
#  		coordinates using gnomonic projection.  Uses the trans-
#		formation constants computed by prj_const and saved in 
#		a structure.
#
# ---------------------------------------------------------------------
procedure sph_cart (ra, dec, x, y, pl_cnst)

double	ra, dec		# i: Celestial coordinates (radians)
pointer	pl_cnst		# i: Chart constants structure
real	x, y 		# o: Chart coordinates (mm)

double  cosdec, sindec
double  cosra, sinra
double  fl, fm, fn	# l: intermediate trig values
double  tl, tm, tn	# l: intermediate products

begin
	cosdec = dcos (dec)
	sindec = dsin (dec)
	cosra = dcos (ra)
	sinra = dsin (ra)

	fl = cosdec * cosra
	fm = cosdec * sinra
	fn = sindec

	tl = - fl * SIN_A(pl_cnst) +
	       fm * COS_A(pl_cnst)
	tm = - fl * COSA_SIND(pl_cnst) -
	       fm * SINA_SIND(pl_cnst) +
	       fn * COS_D(pl_cnst)
	tn =   fl * COSA_COSD(pl_cnst) +
	       fm * SINA_COSD(pl_cnst) +
	       fn * SIN_D(pl_cnst)

	# Chart coordinates in mm
	x = (tl / tn) / PLATE_SCALE_X(pl_cnst)
	y = (tm / tn) / PLATE_SCALE_Y(pl_cnst)

end

# ---------------------------------------------------------------------
#
# Function:	cart_sph
# Purpose:	Convert rectangular chart coordinates to celestial
#  		coordinates.  Uses the transformation constants computed 
#		by prj_const and saved in a structure. 
#
# ---------------------------------------------------------------------
procedure cart_sph (x, y, ra, dec, pl_cnst)

real	x, y		# i: Chart coordinates (mm)
double	ra, dec		# o: Celestial coordinates (radians)
pointer	pl_cnst		# i: # Chart constants structure

double	psi, eta
double	div, tn, tm, tl, fl, fm, fn, a, b, t

begin
	psi = x * PLATE_SCALE_X(pl_cnst)
	eta = y * PLATE_SCALE_Y(pl_cnst)
	div = sqrt (1.0 + psi*psi * eta*eta)

	tn  = 1.0 / div
	tm  = eta * tn
	tl  = psi * tn

	fl  = - tl * SIN_A(pl_cnst) -
	        tm * COSA_SIND(pl_cnst) +
	        tn * COSA_COSD(pl_cnst)
	fm  =   tl * COS_A(pl_cnst) -
	        tm * SINA_SIND(pl_cnst) +
	        tn * SINA_COSD(pl_cnst) 
	fn  =   tm * COS_D(pl_cnst) +
	        tn * SIN_D(pl_cnst)

	b   = TWOPI
	a   = atan2 (fm, fl) + b
	ra  = mod (a, b)
	t   = sqrt (fl*fl + fm*fm)
	dec = atan2 (fn, t)
end

# ---------------------------------------------------------------------
# Function:	cha_near
# Purpose:	Check proximity of array elements to each other.
# Returns:      element of the array arr(n) which is closest to an exact
#  		value EX 
#
# ---------------------------------------------------------------------
double procedure cha_near (ex, arr, n)

double	ex		# The Exact Value
double	arr[ARB]	# The Array of Rounded Values
int	n		# Dimension of Array ARR

int	j

begin
	for (j = 1;  j < n && (ex - arr[j]) > 0.0;  j = j + 1)
	    ;

	if (j > 1 && j < n)
	    if (abs (ex - arr[j-1]) < abs (ex - arr[j])) 
		j = j - 1

	return (arr[j])
end

# ---------------------------------------------------------------------
#
# Function:	round_up
# Purpose:	round input value up to the nearest whole number.
# Returns:	Rounded while number
#
# ---------------------------------------------------------------------
double procedure round_up (x, y)

double 	x	# i: Value to be rounded
double 	y	# i: Multiple X is to be rounded up in

double 	z
double 	r

begin
	if (x < 0.0)
	    z = 0.0
	else
	    z = y

	r = y * double (int ((x + z) / y))

	return (r)
end

# ---------------------------------------------------------------------
#
# Function:	chtext
# Purpose:	draw the line buffer using 1 of 3 formats; 
#		superscript, subscript, or normal
#
# ---------------------------------------------------------------------
procedure chtext (gp, line, text, script)

pointer	gp
int	line
char	text[ARB]
int	script

real	x, y

string	c_format "h=l;v=c;f=r"
string	u_format "h=l;v=b;f=r"
string	d_format "h=l;v=t;f=r"

begin
	x = 0.0
	y = real (line)

	if (script == SUPER_SCRIPT) 
	    call gtext (gp, x, y, text, u_format)
	else if (script == NORMAL_SCRIPT) 
	    call gtext (gp, x, y, text, c_format)
	else if (script == SUB_SCRIPT)
	    call gtext (gp, x, y, text, d_format)
end

#----------------------------------------------------------------------
#
# Function:	rad_hms
# Purpose:	convert from radians to hr/mins/secs
#
# ---------------------------------------------------------------------
procedure rad_hms (rarad, hms, units, maxch)

double	rarad
char	hms[ARB]
char	units[ARB]
int	maxch

int	sec
int	h, m
real	s
char	ch[3], cm[3], cs[5]

begin
	units[1] = EOS
	hms[1]   = EOS

	if (rarad == 0.0) {
	    # 0 hours RA
	    call strcpy ("0 ", hms,   maxch)
	    call strcpy (" h", units, maxch)
	    return
	}

	# Seconds of time
	sec = nint (RADTOST(rarad))

	# Range:  0 to 24 hours
	if (sec < 0)
	    sec = sec + STPERDAY
	else if (sec > STPERDAY)
	    sec = mod (sec, STPERDAY)

	# Separater fields
	s = mod (sec, 60)
	m = mod (sec / 60, 60)
	h = sec / 3600

	# Format fields
	if (h > 0) {
	    # Non-zero hours
	    call sprintf (ch, 3, "%02d ")
		call pargi (h)
	    call strcat (ch, hms, maxch)
	} else {
	    call strcat (" 0 ", hms, maxch)
	}
	call strcat ("  h", units, maxch)

	if (m > 0 || s > 0) {
	    # Minutes
	    call sprintf (cm, 3, "%02d ")
		call pargi (m)
	    call strcat (cm, hms, maxch)
	    call strcat ("  m", units, maxch)
	}

	if (s > 0) {
	    # Seconds
	    call sprintf (cs, 3, "%02d ")
		call pargr (s)
	    call strcat (cs, hms, maxch)
	    call strcat ("  s", units, maxch)
	}
end

# ---------------------------------------------------------------------
#
# Function:	rad_dms
# Purpose:	convert from radians to deg/min/sec buffer
#
# ---------------------------------------------------------------------
procedure rad_dms (arcrad, dms, units, maxch)

double	arcrad
char	dms[ARB]
char	units[ARB]
int	maxch

int	d, m, s
char	cd[3], cm[3], cs[3]
int	sec

define	NDEC	0

begin
	units[1] = EOS
	dms[1]   = EOS

	# Integer seconds of arc
	sec = nint (RADTOSA(arcrad))

	# Sign of declination
	if (sec > 0)
	    # North
	    call strcpy ("+", dms, maxch)
	else if (sec < 0) {
	    # South
	    call strcpy ("-", dms, maxch)
	    sec = -sec
	} else {
	    # Zero declination
	    call strcpy ("0 ", dms, maxch)
	    call strcpy (" o", units, maxch)
	    return
	}

	# Separate fields
	s = mod (sec, 60)
	m = mod (sec / 60, 60)
	d = sec / 3600

	# Degrees
	if (d > 0) {
	    # Non-zero
	    call sprintf (cd, 3, "%02d ")
		call pargi (d)
	    call strcat (cd, dms, maxch)
		call strcpy ("   o", units, maxch)
	} else {
	    call strcat ("0 ", dms, maxch)
		call strcpy ("  o", units, maxch)
	}

	# Minutes of arc
	if (m > 0 || s > 0) {
	    call sprintf (cm, 3, "%02d\'")
		call pargi (m)
	    call strcat (cm, dms, maxch)
	    call strcat ("   ", units, maxch)
	}

	# Seconds of arc
	if (s > 0) {
	    call sprintf (cs, 3, "%02d\"")
		call pargi (s)
	    call strcat (cs, dms, maxch)
	    call strcat ("   ", units, maxch)
	}
end
