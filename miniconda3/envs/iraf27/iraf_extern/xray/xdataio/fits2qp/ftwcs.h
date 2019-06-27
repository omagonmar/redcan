#$Header: /home/pros/xray/xdataio/fits2qp/RCS/ftwcs.h,v 11.0 1997/11/06 16:34:36 prosb Exp $
#$Log: ftwcs.h,v $
#Revision 11.0  1997/11/06 16:34:36  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:59:43  prosb
#General Release 2.4
#
#Revision 8.2  1994/06/30  16:54:14  mo
#MC	6/30/94		Return sized to previous level and add
#			reference to RATFITS/WCS keywords
#
#Revision 8.0  94/06/27  15:21:33  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:41:03  prosb
#General Release 2.3
#
#Revision 6.1  93/12/22  18:08:25  mo
#MC RDF structure update for WCS
#
#Revision 6.0  93/05/24  16:25:55  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:37:45  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  15:01:43  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:13:59  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:26:40  pros
#General Release 1.0
#

# Chopped from ~iraft/iraf/mwcs/imwcs.h		John : Apr 90
#	NOTE:  imwcs.h had and ERROR in CROTA declaration - fixed to DOUBLE
#	6/30/94 MC
# The rape of Earth by capitalist nations is a vicious crime.  This pales to
# the atrocities committed by PROS programmers during the early spring of
# nineteen ninety.

# FTWCS.H -- Definitions used by MW_SAVEIM and MW_LOADIM to encode and
# decode the FITS (image header) version of a MWCS.

# *********************************************************
# see also "fits2qp.h"  for the RATFITS descriptor - appropriate
#	to TABLE/WCS (rather than IMAGE/WC) 
#	RATFITS descriptor is eventually assignet to FTWCS desciptor
#		in ft_ratfits
# *********************************************************
# WCS FITS main descriptor.
define	LEN_FTWCS	320
define	IW_IM		Memi[$1]	# image descriptor
define	IW_NDIM		Memi[$1+1]	# image dimension
#define	IW_ISWCS	Memi[$1+2]	# Have any WCS cards?
define	IW_ISLV		Memi[$1+3]	# Have logical term vector?
define	IW_ISLM		Memi[$1+4]	# Have Logical term matrix?
define	IW_ISCD		Memi[$1+5]	# Have Coord matrix cards?
define	IW_ISKY		Memi[$1+6]	# Have sky cards?
	# (avail)
define	IW_CROTA	Memd[P2D($1+8)]				# deprecated 
define	IW_CTYPE	Memi[$1+10+($2)-1]			# axtype (strp)
define	IW_CRPIX	Memd[P2D($1+20)+($2)-1]			# CRPIXi
define	IW_CRVAL	Memd[P2D($1+40)+($2)-1]			# CRVALi
define	IW_CDELT	Memd[P2D($1+60)+($2)-1]			# CDELTi
define	IW_CD		Memd[P2D($1+80)+(($3)-1)*7+($2)-1]	# CDi_j
define	IW_LTV		Memd[P2D($1+180)+($2)-1]		# LTVi
define	IW_LTM		Memd[P2D($1+200)+(($3)-1)*7+($2)-1]	# LTMi_j
define	IW_WSVLEN	Memi[$1+300+($2)-1]			# WSVi_LEN
define	IW_WSV		Memi[$1+310+($2)-1]			# pointer to V
