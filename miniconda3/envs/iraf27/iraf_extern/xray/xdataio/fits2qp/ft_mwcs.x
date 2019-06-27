#$Header: /home/pros/xray/xdataio/fits2qp/RCS/ft_mwcs.x,v 11.0 1997/11/06 16:34:40 prosb Exp $
#$Log: ft_mwcs.x,v $
#Revision 11.0  1997/11/06 16:34:40  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:59:26  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:21:12  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:40:41  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:25:32  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:37:29  prosb
#General Release 2.1
#
#Revision 1.2  92/09/23  11:40:43  jmoran
#JMORAN - no changes
#
#Revision 1.1  92/07/13  14:10:32  jmoran
#Initial revision
#
#COMMENT Revision 4.0  92/04/27  15:01:39  prosb
#COMMENT General Release 2.0:  April 1992
#
#COMMENT Revision 3.0  91/08/02  01:13:59  prosb
#COMMENT General Release 1.1
#
#COMMENT Revision 2.0  91/03/06  23:26:38  pros
#COMMENT General Release 1.0
#

# Chopped from ~iraf/sys/mwcs/mwloadim.x	John : Apr 90
#

include	<error.h>
include	<imhdr.h>
include	<imio.h>
include	"mwcs.h"			# grabbed from iraf$sys/mwcs
include	"ftwcs.h"

# FT_MWCS -- Convert an IMWCS object (Hacked to contain NO card buffer) into
# an mwcs object.


pointer procedure ft_mwcs(iw)

pointer	iw				# i: pointer to fits format wcs

int	ndim
int	i, j
pointer	sp, sysname
pointer	mw


pointer mw_open()
int	mw_refstr()
errchk	mw_newsystem, mw_swtype
string	s_physical "physical"

begin

	mw = NULL
	ndim = IW_NDIM(iw)

	call smark (sp)
	call salloc (sysname, SZ_FNAME, TY_CHAR)

	mw = mw_open(mw, ndim)

	# Set the Lterm.
	call amovd (IW_LTV(iw,1), D(mw,MI_LTV(mw)), ndim)

	# If we have an L matrix set it.
	if ( IW_ISLM(iw) == 1 ) {
	    do j = 1, ndim
		do i = 1, ndim
		    D(mw,MI_LTM(mw)+(j-1)*ndim+(i-1)) = IW_LTM(iw,i,j)
	}

	# Enter the saved WCS.  We make up a system name for now, and patch
	# it up later once the real name has been recalled along with the
	# attributes.

	if ( IW_ISKY(iw) == 1 ) {
	    call mw_newsystem (mw, "image", ndim)
	    call ft_enterwcs (mw, iw, ndim)

	    ifnoerr {
		call mw_gwattrs (mw, 0, "system", Memc[sysname], SZ_FNAME)
	    } then
		WCS_SYSTEM(MI_WCS(mw)) = mw_refstr (mw, Memc[sysname])
	}

	# Set the default world system.
	call mw_sdefwcs (mw)

	call sfree (sp)

	return mw
end








