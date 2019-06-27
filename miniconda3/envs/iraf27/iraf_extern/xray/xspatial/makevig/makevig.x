#$Header: /home/pros/xray/xspatial/makevig/RCS/makevig.x,v 11.0 1997/11/06 16:31:44 prosb Exp $
#$Log: makevig.x,v $
#Revision 11.0  1997/11/06 16:31:44  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:49:57  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:11:00  prosb
#General Release 2.3.1
#
#Revision 7.1  94/06/15  15:44:55  janet
#*** empty log message ***
#
#Revision 7.0  93/12/27  18:31:35  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:12:33  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:30:56  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:37:15  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:52:15  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:13:08  pros
#General Release 1.0
#
# -------------------------------------------------------------------------
# Module:       makevig
# Project:      PROS -- ROSAT RSDC
# Purpose:      Calculate the vignetting corrections and output to a -.pl mask
# Description:  
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1990.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} Maureen Conroy initial version  August 1990
#               {n} <who> -- <does what> -- <when>
#
# -------------------------------------------------------------------------
include <error.h>		# error messages
include <pmset.h>
include	"inst.h"
include	"vign.h"
include	<rosat.h>
include <plhead.h>

define	VIGN_FATAL	1
#
#     Generate an IRAF PMIO mask from the Einstein vignetting function
#
############################################################################
#
# Generate an IRAF PMIO mask
#  It will produce a mask with the dimensions of the instrument.
#  The output maskfile name will match the reference image name with a -.vign
#    extension if the maskfile is not specified
#
############################################################################

procedure t_makevig()

pointer	instrument	# input instrument name
pointer	maskfile	# output mask file name
pointer	ref_image	# name of reference image file
pointer	temp		# temporary file name until write complete

short	shortone		# constant 1 for short operations

bool	clobber			# parameter - delete existing file?

long	axlen[PM_MAXDIM]	# axis dimensions for mask file
#int	blockfactor		#
int	depth			# depth of mask values in bits
int	display			# parameter - display verbosity 0=none,
				#				1=map,header
int	fd			# file descriptor ( channel ) for I/O
int	line,mline		# output mask line counter
int	ncols
int	naxes		# number of output mask axes
int	v[PM_MAXDIM]    # vector array index for PLIO bookkeeping
int	vm[PM_MAXDIM]    # vector array index for PLIO bookkeeping

int	mirrorx,maxx	# mirrored x value, and max value of x used
int	mirrory,maxy	# mirrored y value, and max value of y used
#int	n 		# index for illegal BRACKETS
int	x,y
int	ysq

double	scale		# scale factor for PLIO header

double	theta		# off-axis angle
double	vbinres
double	vbinscale	# output scaling value
double	vign		# the vignetting correction at current location
short	vignbin

pointer im		# IMIO file descriptor
pointer	pm		# PLIO file descriptor
pointer sp		# stack pointer

pointer instrec		# record of instrument parameters
pointer	title		# pointer to output PLIO header
pointer vignrec		# record of vignetting formula values
pointer vignline	# one line buffer for vignetting values

pointer pm_newmask()
pointer immap()
#pointer	pl_create()
int	clgeti()
bool	clgetb()
#double	clgetd()
double	calc_theta(),calc_vign()
int	imgeti()
#int	stridx()
long	imgetl()

begin
	call smark(sp)
	call salloc( title, SZ_PLHEAD, TY_CHAR)
	call salloc( vignrec , LEN_VIGN , TY_STRUCT )
	call salloc( instrec , LEN_INST , TY_STRUCT )
	call salloc( maskfile, SZ_PATHNAME, TY_CHAR )
	call salloc( ref_image, SZ_PATHNAME, TY_CHAR )
	call salloc( instrument , SZ_PATHNAME, TY_CHAR )
	call salloc( temp , SZ_PATHNAME, TY_CHAR )
	call clgstr("ref_image",Memc[ref_image],SZ_PATHNAME)
#	n = stridx( "[" , Memc[ref_image])
#	if( n != 0 )
#	{
#	    call error( VIGN_FATAL , 
#			"Bracket notation on reference image not supported")
#	}
#    Name of output file - CR defaults to reference image name
	call clgstr("mask",Memc[maskfile],SZ_PATHNAME)
#	call clgstr("satellite",Memc[sat],SZ_PATHNAME)
#	call clgstr("instrument",Memc[instrument],SZ_PATHNAME)
#	vbinres = clgetd("resolution")
	vbinscale = 0.01D0
	vbinres=vbinscale
#	vbinres = min( vbinscale, vbinres)
	im = immap(Memc[ref_image],READ_ONLY,0)
#    Bookkeeping parameters
	clobber = clgetb("clobber")
	display = clgeti("display")
	if( display >= 1)
	    ncols = clgeti("ncols")
	im = immap(Memc[ref_image],READ_ONLY,0)
	naxes=imgeti(im,"i_naxis")
	axlen[1]=imgetl(im,"i_naxis1")
	axlen[2]=imgetl(im,"i_naxis2")
	if( axlen[1] != axlen[2] )
	    call error( VIGN_FATAL, 
			"reference image axis dimensions must be equal")
#	blockfactor=XDIM(instrec)/axlen[1]
#	PIXSCALE(instrec) = blockfactor*PIXSCALE(instrec)
	call read_vign_par(display,im,vignrec,instrec)
#    Check output file names and rationalize extensions - file will be writtein
#	to temp and renamed at end 
	call vigngetoutfile(Memc[ref_image],Memc[maskfile],
			    clobber,SZ_PATHNAME,Memc[temp])

# extract the file dimension parameters and detector ID
#	call set_instrument(INST(vignrec),SAT(vignrec),instrec)

# define the output mask size to be that of the detector
#	axlen[1] = XDIM(instrec)
#	axlen[2] = YDIM(instrec)

	naxes = 2 
	depth = 16 
# create a new mask with a reference image
	pm = pm_newmask(im,depth)
#	pm = pl_create(naxes,axlen,depth)
	line = 1
	shortone = 1

# Initialize the PLIO mask bookkeeping vector
	call amovki(1,v,PM_MAXDIM)
	call amovki(1,vm,PM_MAXDIM)
	
	y = YCORNER(instrec)
#	y = YDIM(instrec) - YCORNER(instrec) + 1

#	call printf("YOPT: %f\n")
#	  call pargr(YOPTICAL_CENTER(instrec))
#	mirrory = (YOPTICAL_CENTER(instrec) - 
#		  abs(YOPTICAL_CENTER(instrec)-y) + 1) 
	mirrory = YOPTICAL_CENTER(instrec) + (YOPTICAL_CENTER(instrec)-y)+1
	mline = mirrory
	vm[naxes] = mline
#	maxy = mline
#	maxy = YDIM(instrec)+1 
	maxy = -1
	call salloc( vignline , axlen[1] , TY_SHORT )
# Process consecutive binary lines and calculate the vignetting values and
#    transfer to PLIO mask
	while( line <= axlen[2] && y <= YOPTICAL_CENTER(instrec) || 
	      mirrory > YOPTICAL_CENTER(instrec) && mirrory > 0 )
#	while( line <= axlen[2] && y <= YOPTICAL_CENTER(instrec) )
#	while( line <= axlen[2] )
	{
# Initialize line and starting off-axis angle and vignetting value
	    x = XCORNER(instrec)
#  MIRROR code
	    mirrorx=XOPTICAL_CENTER(instrec) + abs(XOPTICAL_CENTER(instrec)-x)+1
	    maxx = mirrorx
#  end MIRROR code
	    theta = calc_theta(instrec,x,y,ysq)
	    vign = calc_vign(vignrec,theta)
	    vignbin = (vign / vbinscale + .5D0)
	    shortone = 100
	    call amovks(shortone,Mems[vignline],axlen[1])
# 	    call aclrs(Mems[vignline],axlen[1])
	    call calc_left(instrec,vignrec,axlen,vignbin,vbinres,vbinscale,x,
			   mirrorx,ysq,Mems[vignline])
#  Second do all bins 'right' of center
	    x=maxx+1
	    call calc_right(instrec,vignrec,axlen,vignbin,vbinres,vbinscale,x,
			    ysq,Mems[vignline])
#	 Flush the line to the mask file and update the bookkeeping vector
	    if( y <= YOPTICAL_CENTER(instrec) )
	    {
	    if( display >= 2 )
		call dbdisp(line,vignbin,Mems[vignline],instrec,axlen)
	    if( display >= 3 )
		call dblinedisp(line,Mems[vignline],instrec,axlen)
	    call pmplps(pm,v,Mems[vignline],0,axlen[1],0)
	    line = line+1
	    v[naxes] = line
	    }
	    if( mirrory > YOPTICAL_CENTER(instrec) && mirrory <= axlen[1])
	    {
	        if( display >= 2 )
	            call dbdisp(mline,vignbin,Mems[vignline],instrec,axlen)
	        if( display >= 3 )
		    call dblinedisp(line,Mems[vignline],instrec,axlen)
		call pmplps(pm,vm,Mems[vignline],0,axlen[1],0)
#	        mline = mline - 1
#	        vm[naxes] = mline
	    }
	    if( mirrory > YOPTICAL_CENTER(instrec) && mirrory <= axlen[1])
	        maxy = max(y,maxy,mirrory)
	    else
		maxy = max(y,maxy)
	    y = y+1
	    mirrory = mirrory-1
#	    mline = -mirrory+axlen[2]-1
	    mline = mirrory
	    vm[naxes] = mline
#	    miny = min(y,miny,mirrory)
	}
	if( maxy < axlen[2])
	{
	    y = maxy+1
	    line = y
	    v[naxes]=line
	    while( line <= axlen[2] )
	    {
# Initialize line and starting off-axis angle and vignetting value
	        x = XCORNER(instrec)
#  MIRROR code
	        mirrorx=XOPTICAL_CENTER(instrec) + abs(XOPTICAL_CENTER(instrec)-x+1)
	        maxx = mirrorx
#  end MIRROR code
	        theta = calc_theta(instrec,x,y,ysq)
	        vign = calc_vign(vignrec,theta)
	        vignbin = (vign / vbinscale + .5)
 	        call amovks(shortone,Mems[vignline],axlen[1])
# 	        call aclrs(Mems[vignline],axlen[1])
	        call calc_left(instrec,vignrec,axlen,vignbin,vbinres,vbinscale,
			       x,mirrorx,ysq,Mems[vignline])
#  Second do all bins 'right' of center
#	    x=maxx
	    x=maxx+1
	    call calc_right(instrec,vignrec,axlen,vignbin,vbinres,vbinscale,x,
			   ysq,Mems[vignline])
#	 Flush the line to the mask file and update the bookkeeping vector
	    if( display >= 2 )
		call dbdisp(line,vignbin,Mems[vignline],instrec,axlen)
	    if( display >= 3 )
		call dblinedisp(line,Mems[vignline],instrec,axlen)
	    call pmplps(pm,v,Mems[vignline],0,axlen[1],0)
	    line = line+1
	    v[naxes] = line
	    y = y+1
	}
	}

# Save the mask and close the files and go home
	if( display >= 1)
	{
#       Display the file with equal rows and columns, full field
	    call rg_pmdisp(pm,ncols,ncols,-1,-1,-1,-1)
	    call flush( STDOUT )
	}
	# Write the file to disk ( appending a -.pl extension)
#	scale=1.0D0/vbinscale
	scale = vbinscale
	call enc_plhead(Memc[maskfile],"vignetting",Memc[ref_image],
			axlen[1],axlen[2],scale,0,Memc[title],SZ_PLHEAD)
	if( display >= 1 )
	    call msk_disp("","",Memc[title])
	call pm_savef(pm,Memc[temp],Memc[title],0)
        call imunmap(im)
	call pm_close(pm)
	call close(fd)
#        call imunmap(im)
#     Rename the temp file to the requested name if necessary
	if( display >= 1 ){
	    call printf("Creating output vignetting file: %s\n")
		call pargstr(Memc[maskfile])
	}
	call finalname(Memc[temp],Memc[maskfile])
	call sfree(sp)
end


