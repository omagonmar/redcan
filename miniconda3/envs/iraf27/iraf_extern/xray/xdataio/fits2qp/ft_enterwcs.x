#$Header: /home/pros/xray/xdataio/fits2qp/RCS/ft_enterwcs.x,v 11.0 1997/11/06 16:34:36 prosb Exp $
#$Log: ft_enterwcs.x,v $
#Revision 11.0  1997/11/06 16:34:36  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:59:04  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:20:49  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:40:17  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:25:04  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:37:09  prosb
#General Release 2.1
#
#Revision 1.2  92/09/23  11:40:29  jmoran
#JMORAN - no changes
#
#Revision 1.1  92/07/13  14:10:18  jmoran
#Initial revision
#

#COMMENT Revision 4.0  92/04/27  15:01:35  prosb
#COMMENT General Release 2.0:  April 1992
#
#COMMENT Revision 3.0  91/08/02  01:13:58  prosb
#COMMENT General Release 1.1
#
#COMMENT Revision 2.0  91/03/06  23:26:35  pros
#COMMENT General Release 1.0
#

# Chopped from ~iraf/sys/mwcs/iwewcs.x		John : Apr 90

include	<ctype.h>
include	<imhdr.h>
include	<imio.h>
include	"mwcs.h"		# grabbed from iraf$sys/mwcs
include	"ftwcs.h"

# FT_ENTERWCS -- Enter a WCS as represented in a chopped IMWCS
# wcs descriptor into an MWCS descriptor.  This routine is called by FT_MWCS

procedure ft_enterwcs (mw, iw, ndim)

pointer	mw			#io:  pointer to MWCS descriptor
pointer	iw			# i:  pointer to IMWCS descriptor
int	ndim			# i:  system dimension

double	theta
char	ctype[8]
int	axes[2], axis, npts, ch, ip, decax, ax1, ax2, i, j
pointer	sp, r, o_r, cd, ltm, cp, rp, bufp, pv, wv, o_cd, o_ltm

int	strncmp(), ctod(), strldxs()
errchk	mw_swtermd, malloc, mw_swtype, mw_swsampd
define	samperr_ 91

begin
	call smark (sp)
	call salloc (r, ndim, TY_DOUBLE)
	call salloc (o_r, ndim, TY_DOUBLE)
	call salloc (cd, ndim*ndim, TY_DOUBLE)
	call salloc (ltm, ndim*ndim, TY_DOUBLE)
	call salloc (o_cd, ndim*ndim, TY_DOUBLE)
	call salloc (o_ltm, ndim*ndim, TY_DOUBLE)

	decax = 2

	# Set any nonlinear functions on the axes.
	do axis = 1, ndim {

	    rp = IW_CTYPE(iw,axis)
	    if (rp == NULL)
		next

	    # Get the value of CTYPEi.  Ignore case and treat '_' and '-'
	    # as equivalent.

	    do i = 1, 8 {
		ch = Memc[rp+i-1]
		if (ch == ' ' || ch == '\'')
		    break
		else if (IS_UPPER(ch))
		    ch = TO_LOWER(ch)
		else if (ch == '_')
		    ch = '-'
		ctype[i] = ch
	    }
	    ctype[9] = EOS


	    # Determine the type of function on this axis.
	    if (strncmp (ctype, "linear", 6) == 0) {
		;   # Linear is the default.

	    } else if (strncmp (ctype, "sampled", 7) == 0) {
		# A sampled WCS is an array of [P,W] points.

		call eprintf("Sorry but sampled axis transformations are silly\n")
		if ( 0 == 0 ) next

#		bufp = iw_gbigfits (iw, TY_WSVDATA, axis)
		npts = IW_WSVLEN(iw,axis)
		call malloc (pv, npts, TY_DOUBLE)
		call malloc (wv, npts, TY_DOUBLE)

		ip = 1
		do i = 1, npts {
		    if (ctod (Memc[bufp], ip, Memd[pv+i-1]) <= 0)
			goto samperr_
		    if (ctod (Memc[bufp], ip, Memd[wv+i-1]) <= 0) {
samperr_		call eprintf (
			    "Axis %d: Cannot read sampled WCS\n")
			    call pargi (axis)
			break
		    }
		}

		call mw_swtype (mw, axis, 1, "sampled", "")
		call mw_swsampd (mw, axis, Memd[pv], Memd[wv], npts)

		call mfree (wv, TY_DOUBLE)
		call mfree (pv, TY_DOUBLE)
		call mfree (bufp, TY_CHAR)

	    } else if (strncmp (ctype, "ra--", 4) == 0) {
		# The projections are restricted to two axes and are indicated
		# by CTYPEi values such as, e.g., "RA---TAN" and "DEC--TAN"
		# for the TAN projection.

		# Locate the DEC axis.
		decax = 0
		do j = 1, ndim {
		    cp = IW_CTYPE(iw,j)
		    if (cp != NULL)
			if (Memc[cp+3] == '-' || Memc[cp+3] == '_')
			    if (strncmp (Memc[cp], "DEC", 3) == 0 ||
				strncmp (Memc[cp], "dec", 3) == 0) {
				decax = j
				break
			    }
		}

		# Did we find it?
		if (decax == 0) {
		    call eprintf (
			"Axis %d: Cannot locate dec-%s axis\n")
			call pargi (axis)
			call pargstr (ctype[5])
		}

		# Get the function type.
		ip = strldxs ("-", ctype) + 1

		# Assign the function to the two axes.
		axes[1] = axis
		axes[2] = decax
		call mw_swtype (mw, axes, 2, ctype[ip],
#		    "axis 1: axtype=ra axis, 2: axtype=dec")
		    "axis 1: axtype=ra axis 2: axtype=dec")

	    } else if (strncmp (ctype, "dec-", 4) == 0) {
		;   # This case is handled when RA-- is seen.

	    } else {
		# Since we have to be able to read any FITS header, we have
		# no control over the value of CTYPEi.  If the value is
		# something we don't know about, assume a LINEAR axis, using
		# the given value of CTYPEi as the default axis label.

		call mw_swattrs (mw, axis, "label", ctype)
	    }
	}

	# Compute the CD matrix, or verify that one was read.  Either the
	# CD matrix was input, the CROTA/CDELT representation was input,
	# or nothing was input, in which case we have the identity matrix.

	if ( IW_ISCD(iw) == 0 )
	    if ( IW_ISKY(iw) == 0 )
		call mw_mkidmd (IW_CD(iw,1,1), ndim)
	    else {
		theta = IW_CROTA(iw)
		ax2 = decax
		ax1 = 3 - decax
		IW_CD(iw,ax1,ax1) = IW_CDELT(iw,ax1) * cos(theta)
		IW_CD(iw,ax1,ax2) = abs(IW_CDELT(iw,ax2)) * sin(theta)
		IW_CD(iw,ax2,ax1) = -abs(IW_CDELT(iw,ax1)) * sin(theta)
		IW_CD(iw,ax2,ax2) = IW_CDELT(iw,ax2) * cos(theta)
		if (IW_CDELT(iw,ax1) < 0)
		    IW_CD(iw,ax1,ax2) = -IW_CD(iw,ax1,ax2)
		if (IW_CDELT(iw,ax2) < 0)
		    IW_CD(iw,ax2,ax1) = -IW_CD(iw,ax2,ax1)
	    }

	# Extract an NDIM submatrix from LTM and CD.
	do j = 1, ndim
	    do i = 1, ndim {
		Memd[o_cd+(j-1)*ndim+(i-1)] = IW_CD(iw,i,j)
		Memd[o_ltm+(j-1)*ndim+(i-1)] = IW_LTM(iw,i,j)
	    }

	# Set the linear portion of the Wterm.  First we have to transform
	# it from the FITS logical->world representation to the MWCS
	# physical->world form, by separating out the Lterm.  We have
	# CD = CD' * LTM and R = inv(LTM) * (R' - LTV), where CD' and R' are
	# the FITS versions of the MWCS CD matrix and R vector (CRPIX), and
	# LTM and LTV are the Lterm rotation matrix and translation vector.

	# Compute CD = CD' * LTM.
	if ( IW_ISLM(iw) == 1 )
	    call mw_mmuld (Memd[o_cd], Memd[o_ltm], Memd[cd], ndim)
	else
	    call amovd (Memd[o_cd], Memd[cd], ndim*ndim)

	# Compute R = inv(LTM) * (R' - LTV).
	if ( IW_ISLV(iw) == 1 ) {
	    call mw_invertd (Memd[o_ltm], Memd[ltm], ndim)
	    call asubd (IW_CRPIX(iw,1), IW_LTV(iw,1), Memd[o_r], ndim)
	    call mw_vmuld (Memd[ltm], Memd[o_r], Memd[r], ndim)
	} else
	    call amovd (IW_CRPIX(iw,1), Memd[r], ndim)

	# Set the Wterm.
	call mw_swtermd (mw, Memd[r], IW_CRVAL(iw,1), Memd[cd], ndim)


	call sfree (sp)
end

