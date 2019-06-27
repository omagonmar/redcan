#$Header: /home/pros/xray/xspectral/source/RCS/bal_histo.x,v 11.0 1997/11/06 16:41:49 prosb Exp $
#$Log: bal_histo.x,v $
#Revision 11.0  1997/11/06 16:41:49  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:28:57  prosb
#General Release 2.4
#
#Revision 8.1  1994/08/10  14:05:34  dvs
#Modified bal_histo & get_time_fractions to be sensitive to the
#deffilt in the qpoe file when making the bal histogram.
#Also removed bal_time_warning, since it is now superfluous.
#
#Revision 7.1  94/02/03  14:11:33  prosb
#Revised bal_time_warning to not give warning when difference
#is under a second.
#
#Revision 7.0  93/12/27  18:54:13  prosb
#General Release 2.3
#
#Revision 6.1  93/10/26  14:54:04  dvs
#Added routine flip_all_bal which calls bal_flip on all the records
#in the BLT structure.  This is called by bal_histo if we must convert
#the BLT from BLT_FORMAT=1 into the Einstein convention (BLT_FORMAT=0).
#
#Revision 6.0  93/05/24  16:48:44  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:43:24  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  18:13:06  prosb
#General Release 2.0:  April 1992
#
#Revision 3.4  92/04/10  11:16:44  orszak
#jso - changed the warnig message to point to help file and not me.
#
#Revision 3.3  92/03/05  13:24:37  orszak
#jso - upgrade to qpspec; error message about time filtering.
#
#Revision 3.2  91/09/22  19:05:10  wendy
#Added
#
#Revision 3.1  91/09/13  14:44:45  prosb
#jso - removed the explicit calls to dg convert routines.  at the same time
#      as the install of this code the files in xspectral/data psgni.tables
#      and dgni.table will change from dg format to sun format, and the insl
#      script will take this into account.
#      NB: note that the two variables psgni_bounds and dgni_bounds are type
#          int, while the data file psgni.table and dgni.table have shorts.
#,
#
#Revision 3.0  91/08/02  01:57:50  prosb
#General Release 1.1
#
#Revision 2.1  91/07/12  15:32:51  prosb
#jso - made spectral.h system wide
#
#Revision 2.0  91/03/06  23:01:33  pros
#General Release 1.0
#
#
#  BAL_HISTO -- get bal histogram for x,y position
#
# Project:      PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright

include <mach.h>
include <math.h>
include <spectral.h>

# define number of records in the psgni and dgni files
define PSGNI_RECS	(81*81)
define DGNI_RECS	(51*51)

# this only works for positive numbers!!!
# smallest real number <= r
define floor		real(int($1))

procedure bal_histo(xi, yi, qp, blt, nblt, bh, gtf, convert, debug)

real	xi				# i: x position
real	yi				# i: y position
pointer qp				# i: qpoe pointer
pointer	blt				# i: blt records
int	nblt				# i: number of blt records
pointer	bh				# o: bal histo pointer
pointer gtf				# i: good time filter 
int	convert				# i: if true, convert to Einstein
int	debug				# i: debug level

bool	is_bal_conv			# l: did we convert blt to Einstein?
int	i				# l: loop counter
int	psgni_bounds[4]			# l: psgni bounds
int	used_psgni			# l: flag we used the psgni
int	dgni_bounds[4]			# l: dgni bounds
int	used_dgni			# l: flag we used the dgni
int	used				# l: flag we used psgni/dgni
real	x				# l: Einstein y
real	y				# l: Einstein z
real	dy				# l: Einst. y in detector coords
real	dz				# l: Einst. z in detector coords
real	time_fraction			# l: current time fraction
real	total_time			# l: total time of blt records
real	bal_spatial			# l: spatial bal
real	bal_sigma			# l: sigma on spatial bal
real	bal_temporal			# l: temporal bal
real	bal_effective			# l: combo of spatial and time bal
real	bal_mean			# l: mean bal (used for display)
real	psgni_inc			# l: psgni grid increment
real	psgni_norm_factor		# l: bal norm factor
real	psgni_histo[MAX_BALS]		# l: psgni histogram
real	psgni_fraction			# l: psgni fraction
real	dgni_inc			# l: dgni grid increment
real	dgni_norm_factor		# l: bal norm factor
real	dgni_histo[MAX_BALS]		# l: dgni histogram
real	dgni_fraction			# l: dgni fraction
pointer	time_fractions			# l: time fractions
pointer	cur_blt				# l: current blt pointer
pointer	psgni_buf			# l: psgni buffer
pointer	dgni_buf			# l: dgni buffer

int	chk_bounds()			# l: check x,y within bounds

begin

	# display good time filters!
	if (debug>0)
	{
	    call printf("Good time filter: %s.\n")
	     call pargstr(Memc[gtf])
	    call flush(STDOUT)
	}

	# convert to Einstein coords, if necessary
	if( convert == YES ){
	    x = xi - 1
	    y = 1024 - yi
	}
	else{
	    x = xi
	    y = yi
	}

	# we may have to convert the blt records into Einstein as well.
	# (The old Einstein convention is when BLT_FORMAT=0.)
	is_bal_conv=false
	if (nblt>0)
	{
	    if (BLT_FORMAT(blt)>0)
	    {
		call flip_all_bal(blt,nblt)
		is_bal_conv=true
	    }
	}

	# allocate a large psgni buffer
	call calloc(psgni_buf, PSGNI_RECS*2, TY_SHORT)
	call calloc(dgni_buf, DGNI_RECS*2, TY_SHORT)

	# clear the bal histogram
	call aclrr(psgni_histo, MAX_BALS)
	call aclrr(dgni_histo, MAX_BALS)

	# haven't use psgni or dgni yet
	used = NO_GNI
	used_psgni = NO
	used_dgni = NO
	psgni_fraction = 0.0
	dgni_fraction = 0.0
	total_time = 0.0

	# get the stuff we need to calculate bal histos
	call init_bal_histo(bh,
			    Mems[psgni_buf], psgni_bounds,
			    psgni_inc, psgni_norm_factor,
			    Mems[dgni_buf], dgni_bounds,
			    dgni_inc, dgni_norm_factor,
			    debug)

	# get time fraction for each cai
	call get_time_fractions(blt, nblt, gtf, qp,
			time_fractions, total_time, debug)

	# for each blt record ...
	do i=1, nblt{
	    # get current time fraction
	    time_fraction = Memr[time_fractions+i-1]
	    # point to the current blt record
	    cur_blt = BLT(blt, i)
	    # get temporal bal value
	    bal_temporal = BLT_BAL(cur_blt)
	    call un_aspect_coords(cur_blt, x, y, dy, dz)
	    if( debug >0 ){
		call printf("\n (x,y)=%.4f %.4f detector (y,z): %.4f %.4f\n")
		call pargr(x)
		call pargr(y)
		call pargr(dy)
		call pargr(dz)
		call flush(STDOUT)
	    }

	    # get spatial bal, from psgni or dgni
	    if( chk_bounds(dy, dz, psgni_bounds, debug)==YES ){
		used_psgni = YES
		used = PSGNI
		call get_psgni_bal(dy, dz, psgni_bounds, psgni_inc,
				   Mems[psgni_buf], bal_spatial, bal_sigma,
				   debug)
		# combine the spatial and temporal bal to get the effective bal
		bal_effective = bal_spatial * bal_temporal / psgni_norm_factor
	    }
	    else if( chk_bounds(dy, dz, dgni_bounds, debug)==YES ){
		used_dgni = YES
		used = DGNI
		call get_dgni_bal(dy, dz, dgni_bounds, dgni_inc,
				   Mems[dgni_buf], bal_spatial, bal_sigma,
				   debug)
		# combine the spatial and temporal bal to get the effective bal
		bal_effective = bal_spatial * bal_temporal / dgni_norm_factor
	    }
	    else{
		call error(1, "source falls off both psgni and dgni!")
	    }
	    
	    if( debug>0 ){
		call printf("\nbal - %.3f %.3f %.5f %.5f %.5f %.3f%%\n\n")
		call pargr(dy)
		call pargr(dz)
		call pargr(bal_effective)
		call pargr(bal_spatial)
		call pargr(bal_temporal)
		call pargr(time_fraction*100)
	    }

	    # add this fraction to the bal histogram
	    switch(used){
	    case PSGNI:
		call add_to_histo(bal_effective, time_fraction, bh,
				  psgni_histo, debug)
#		call printf("psgni:\tspatial bal=%.2f\ttime frac=%.2f\n")
#		call pargr(bal_spatial)
#		call pargr(time_fraction*100.0)
		psgni_fraction = psgni_fraction + time_fraction
	    case DGNI:
		call add_to_histo(bal_effective, time_fraction, bh,
				  dgni_histo, debug)
#		call printf("dgni:\tspatial bal=%.2f\ttime frac=%.2f\n")
#		call pargr(bal_spatial)
#		call pargr(time_fraction*100.0)
		dgni_fraction = dgni_fraction + time_fraction
	    default:
		call error(1, "internal error: add_to_histo")
	    }
	}

	# normalize the psgni histogram
	if( used_psgni == YES )
	    call renormalize_histo(bh, psgni_histo, debug)
	# normalize the dgni histogram
	if( used_dgni == YES )
	    call renormalize_histo(bh, dgni_histo, debug)

	# if we have any psgni, use it
	if( used_psgni == YES ){
	    # write histogram into bal struct
	    call output_histo(psgni_histo, bh, PSGNI, debug)
	}
	# otherwise, if we have any dgni use it
	else if( used_dgni == YES ){
	    # write histogram into bal struct
	    call output_histo(dgni_histo, bh, DGNI, debug)
	}
	# otherwise we should have had an error already
	else
	    call error(1, "internal_error: output_histo")

	# print out the mean bal and total fractions for psgni
	call get_mean_bal(bh, psgni_histo, bal_mean)
#	call printf("\npsgni:\tmean bal=%.2f\ttotal frac=%.2f\n")
#	call pargr(bal_mean)
#	call pargr(psgni_fraction*100.0)

	# print out the mean bal and total fractions for psgni
	call get_mean_bal(bh, dgni_histo, bal_mean)
#	call printf("dgni:\tmean bal=%.2f\ttotal frac=%.2f\n")
#	call pargr(bal_mean)
#	call pargr(dgni_fraction*100.0)
	call printf("\n")

	# free up allocated space
	call mfree(time_fractions, TY_REAL)
	call mfree(psgni_buf, TY_SHORT)
	call mfree(dgni_buf, TY_SHORT)

	# unconvert bal, if it was converted previously.
	if (is_bal_conv)
	{
	   call flip_all_bal(blt,nblt)
	}
end

#
#  INIT_BAL_HISTO -- get the stuff we need to calculate bal histos
#
procedure init_bal_histo(bh, psgni_buf, psgni_bounds, psgni_inc, 
			 psgni_norm_factor, dgni_buf, dgni_bounds,
			 dgni_inc, dgni_norm_factor, debug)

pointer	bh				# o: bal histo pointer
short	psgni_buf[ARB]			# o: psgni records
int	psgni_bounds[4]			# o: psgni bounds
real	psgni_inc			# o: psgni grid increment
real	psgni_norm_factor		# o: bal norm factor
short	dgni_buf[ARB]			# o: dgni records
int	dgni_bounds[4]			# o: dgni bounds
real	dgni_inc			# o: dgni grid increment
real	dgni_norm_factor		# o: bal norm factor
int	debug				# i: debug level

pointer	psgni_name			# l: psgni file name
pointer	dgni_name			# l: dsgni file name
pointer	sp				# l: stack pointer

real	clgetr()			# l: get real cl param
int	clgeti()			# l: get int cl param

begin
	# mark the stack
	call smark(sp)

	# allocate space
	call salloc(psgni_name, SZ_PATHNAME, TY_CHAR)
	call salloc(dgni_name, SZ_PATHNAME, TY_CHAR)

	# allocate spec for bal histo records, if necessary
	if( bh ==0 )
	    call calloc(bh, LEN_BH, TY_STRUCT)
	# get bal histogram info from param file
	BH_BAL_STEPS(bh) = clgeti("bal_steps")
	BH_START_BAL(bh) = clgetr("bal_start")
	BH_BAL_INC(bh) = clgetr("bal_inc")
	BH_BAL_EPS(bh) = clgetr("bal_eps")
	BH_END_BAL(bh) = BH_START_BAL(bh) + BH_BAL_STEPS(bh)*BH_BAL_INC(bh)
	# get spatial bal file information
	call clgstr("psgni", Memc[psgni_name], SZ_PATHNAME)
	call clgstr("dgni", Memc[dgni_name], SZ_PATHNAME)

	# read in the psgni records
	call get_psgni(Memc[psgni_name], psgni_buf, psgni_bounds, psgni_inc,
			psgni_norm_factor, debug)

	# read in the dgni records
	call get_dgni(Memc[dgni_name], dgni_buf, dgni_bounds, dgni_inc,
			dgni_norm_factor, debug)

	# free up stack space
	call sfree(sp)
end

#
#  GET_PSGNI -- get psgni records from psgni file
#
procedure get_psgni(name, psgni_buf, psgni_bounds, psgni_inc,
		    psgni_norm_factor, debug)

char	name[ARB]			# i: psgni file name
short	psgni_buf[ARB]			# o: psgni records
int	psgni_bounds[4]			# o: psgni bounds
real	psgni_inc			# o: psgni grid increment
real	psgni_norm_factor		# o: bal norm factor
int	debug				# i: debug level

int	fd				# l: file pointer
int	nshort				# l: number of shorts to read
int	got				# l: number of shorts got
pointer	hbuf				# l: psgni header
pointer	sp				# l: stack pointer

int	open()				# l: open a file
int	read()				# l: read from a file

begin
	# mark the stack
	call smark(sp)

	# allocate space for header and data
	call salloc(hbuf, 256, TY_SHORT)

	# open the psgni file
	fd = open(name, READ_ONLY, BINARY_FILE)

	# read in the first 512 bytes containing header information
	if( read(fd, Mems[hbuf], 256) != 256 )
	    call error(1, "unexpected EOF reading psgni header")

	# move in the header information
	psgni_bounds[1] = int(Mems[hbuf+0])
	psgni_bounds[2] = int(Mems[hbuf+1])
	psgni_bounds[3] = int(Mems[hbuf+2])
	psgni_bounds[4] = int(Mems[hbuf+3])

	call amovr( Mems[hbuf+4], psgni_inc, 1)
	call amovr( Mems[hbuf+6], psgni_norm_factor, 1)

	if( debug >0 ){
	    call printf("psgni bounds: %d %d %d %d\n")
	    call pargi(psgni_bounds[1])
	    call pargi(psgni_bounds[2])
	    call pargi(psgni_bounds[3])
	    call pargi(psgni_bounds[4])
	    call printf("psgni inc: %.2f; psgni_norm_factor: %.2f\n")
	    call pargr(psgni_inc)
	    call pargr(psgni_norm_factor)
	    call flush(STDOUT)
	}

	# read in the psgni data into a short buffer
	nshort = PSGNI_RECS * 2
	got = read(fd, psgni_buf, nshort)
	if( got != nshort )
	    call errori(1, "unexpected EOF reading psgni data", got)

	# close the file
	call close(fd)
end

#
#  GET_DGNI -- get dgni records from dgni file
#
procedure get_dgni(name, dgni_buf, dgni_bounds, dgni_inc,
		    dgni_norm_factor, debug)

char	name[ARB]			# i: dgni file name
short	dgni_buf[ARB]			# o: dgni records
int	dgni_bounds[4]			# o: dgni bounds
real	dgni_inc			# o: dgni grid increment
real	dgni_norm_factor		# o: bal norm factor
int	debug				# i: debug level

int	fd				# l: file pointer
int	nshort				# l: number of shorts to read
int	got				# l: number of shorts got
pointer	hbuf				# l: dgni header
pointer	sp				# l: stack pointer

int	open()				# l: open a file
int	read()				# l: read from a file

begin
	# mark the stack
	call smark(sp)

	# allocate space for header and data
	call salloc(hbuf, 256, TY_SHORT)

	# open the dgni file
	fd = open(name, READ_ONLY, BINARY_FILE)

	# read in the first 512 bytes containing header information
	if( read(fd, Mems[hbuf], 256) != 256 )
	    call error(1, "unexpected EOF reading dgni header")

	# move in the header information
	dgni_bounds[1] = int(Mems[hbuf+0])
	dgni_bounds[2] = int(Mems[hbuf+1])
	dgni_bounds[3] = int(Mems[hbuf+2])
	dgni_bounds[4] = int(Mems[hbuf+3])

	call amovr( Mems[hbuf+4], dgni_inc, 1)
	call amovr( Mems[hbuf+6], dgni_norm_factor, 1)

	if( debug >0 ){
	    call printf("dgni bounds: %d %d %d %d\n")
	    call pargi(dgni_bounds[1])
	    call pargi(dgni_bounds[2])
	    call pargi(dgni_bounds[3])
	    call pargi(dgni_bounds[4])
	    call printf("dgni inc: %.2f; dgni_norm_factor: %.2f\n")
	    call pargr(dgni_inc)
	    call pargr(dgni_norm_factor)
	    call flush(STDOUT)
	}

	# read in the dgni data into a short buffer
	nshort = DGNI_RECS * 2
	got = read(fd, dgni_buf, nshort)
	if( got != nshort )
	    call errori(1, "unexpected EOF reading dgni data", got)

	# close the file
	call close(fd)
end

#
#  GET_TIME_FRACTIONS -- get the time fractions for the blt records
#
procedure get_time_fractions(blt, nblt, gtf, qp, time_fractions, total, debug)

pointer	blt			# i: blt records
int	nblt			# i: number of blt records
pointer gtf			# i: good time filter for QPOE
pointer qp			# i: QPOE pointer
pointer	time_fractions		# o: time fractions
real	total			# o: total time in blt
int	debug			# i: debug level

int	i			# l: loop counter
pointer	cur_blt			# l: current blt pointer
pointer	blt_string		# l: string of BLT start&stop
pointer blt_filter		# l: time filter for each BLT
pointer sgt			# l: good time starting times [array]
pointer egt			# l: good time ending times [array]
int	n_gt			# l: number of good times
int	i_gt			# l: index into good times arrays

begin
	# allocate space for the time fractions
	call calloc(time_fractions, nblt, TY_REAL)

	# clear space for string
	call malloc(blt_string, SZ_LINE, TY_CHAR)

	# get the total time
	total = 0.0
	do i=1, nblt{
	    # point to the current record
	    cur_blt = BLT(blt, i)
	    
	    # create time filter with good time information and BLT
	    # stop and start times.  In effect, this will find the
	    # intersection of the BLT record with the deffilt.
	    call sprintf(Memc[blt_string],SZ_LINE,"time=%.7f:%.7f")
	     call pargd(BLT_START(cur_blt,i))
	     call pargd(BLT_STOP(cur_blt,i))

	    call add_filter(Memc[gtf],Memc[blt_string],blt_filter)

	    # Convert this time filter into an array of good time
	    # starts and stops
	    call filter2gt(qp,Memc[blt_filter],sgt,egt,n_gt)

	    # calculate bal record duration (by summing good times)
	    Memr[time_fractions+i-1] = 0
	    do i_gt=1,n_gt {
		Memr[time_fractions+i-1] = Memr[time_fractions+i-1] +
		   Memd[egt+i_gt-1] - Memd[sgt+i_gt-1]
		if (debug>0)
		{
		   call printf("Blt %d: added time %f.\n")	
		    call pargi(i)
		    call pargd(Memd[egt+i_gt-1] - Memd[sgt+i_gt-1])
		}
	    }

	    # add to the total
	    total = total + Memr[time_fractions+i-1]

	    # free strings
	    call mfree(blt_filter,TY_CHAR)
	}

	if (total>0.0)
	{
	   # now get the time fractions
	   do i=1, nblt{
	      Memr[time_fractions+i-1] = Memr[time_fractions+i-1]/total
	   }
	}

	if( debug >0 ){
	    call printf("time fractions: ")
	    do i=1, nblt{
		call printf("%.2f ")
		call pargr(Memr[time_fractions+i-1])
	    }
	    call printf("\n")
	    call flush(STDOUT)
	}

	call mfree(blt_string,TY_CHAR)
end

#
#  CHK_BOUNDS -- see if x,y is withing bounds
#
int procedure chk_bounds(dy, dz, bounds, debug)

real	dy				# i: detector Einstein coords.
real	dz				# i: detector Einstein coords.
int	bounds[4]			# i: psgni records
int	debug				# i: debug level

begin
	if( (dy<bounds[1]) || (dy>bounds[2]) ||
	    (dz<bounds[3]) || (dz>bounds[4]) )
	    return(NO)
	else
	    return(YES)
end

#
# GET_PSGNI_BAL -- get the spatial bal from psgni file
#
procedure get_psgni_bal(dy, dz, psgni_bounds,psgni_inc,
			  psgni_buf,bal_spatial,bal_sigma_spatial, debug)

real	dy			# i: detector Einstein coords.
real	dz			# i: detector Einstein coords.
int	psgni_bounds[4]		# i: extremes of psgni grid
real	psgni_inc		# i: inc along y,z axis for psgni grid
short	psgni_buf[2,PSGNI_RECS]	# i: psgni grid
real	bal_spatial		# o: bal from psgni
real	bal_sigma_spatial	# o: bal sigma from psgni
int	debug			# i: debug level

int	base_offset		# l: base array offset to 'closest grid pnt'
int	iy_pix			# l: integer of y_pix_per_line
int	i			# l: loop counter
real	bal_quad[4]		# l: bals for each point in quadrant
real	bal_sigma_quad[4]	# l: sigmas for each point in quadrant
real	denominator		# l: temp in interpolation calc
real	dist[4]			# l: dist from interpolation points
real	dist_sq[4]		# l: dist sq from interpolation points
real	numerator		# l: temp in interpolation cal#c
real	y_pix_per_line		# l: (yend-ybegin)/inc
real	y_base			# l: base position on grid x of 'closest pnt'
real	z_base			# l: base position on grid y of 'closest pnt'
real	y_incs			# l: (xbegin-xi)/inc
real	z_incs			# l: (ybegin-yi)/inc

begin
	# check to make sure we are within bounds and flag results if not
	if( (dy<psgni_bounds[1])||(dy>psgni_bounds[2]) ||
	    (dz<psgni_bounds[3])||(dz>psgni_bounds[4]) ){
		bal_spatial = -1.0
		bal_sigma_spatial = 0.0
		return
	}

	# check to see if any coord is directly on a boundary line and
	# if so, push it just a bit into the grid
	if(dy==psgni_bounds[1])
	    dy = dy + 0.001	# top 
	if(dy==psgni_bounds[2])
	    dy = dy - 0.001	# bottom
	if(dz==psgni_bounds[3])
	    dz = dz + 0.001	# left
	if(dz==psgni_bounds[4])
	    dz = dz - 0.001	# right

	# else define the major quantities:
	# z_incs - number of array elements we go in z direction
	# y_incs - number of array elements we go in y direction
	# y_pix_per_line - number of incs in line of y (fastest moving dir.)
	y_incs = floor((dy-psgni_bounds[1])/psgni_inc)
	z_incs = floor((dz-psgni_bounds[3])/psgni_inc)
	y_pix_per_line = (psgni_bounds[2]-psgni_bounds[1])/psgni_inc  + 1.0
	iy_pix = y_pix_per_line

	# use these to calculate the array element closest to detector position
	# but smaller than it ...
	base_offset = int(y_incs + y_pix_per_line * z_incs) + 1

	# ... and calculate the y,z position in grid of this element
# NB: These two lines of code are different from the original code in bal_histo
# because bal_histo has a bug and does not correctly calculate the base values.
# This fix affects the dgni values only.  Signed, Eric and Ginevra
	y_base=floor((dy-psgni_bounds[1])/psgni_inc)*psgni_inc+psgni_bounds[1]
	z_base=floor((dz-psgni_bounds[3])/psgni_inc)*psgni_inc+psgni_bounds[3]

	# now see if the point we want is exactly on a grid point
	if( (dy==y_base) && (dz==z_base) ) {
	    # if so, use the array element we just calculated
	    bal_spatial = real(psgni_buf(1,base_offset))/10.
	    bal_sigma_spatial = real(psgni_buf(2,base_offset))/1000.
	    return
	}

	# if not, interpolate using 4 grid points centered around the detector
	# coords with 1 point in each quadrant
	# balx = {sum(i=1,4) bali - ri} / {sum(i=1,4) ri}
	# sigmax = sqrt{sum(i=1,4) sigi**2/ri**2 }/{sum(i=1,4) ri}
	# where ri is distance

	#
	# note that the quadrants are numbered as follows:
	#
	# 		y ->
	#
	# 		!
	# 	2	!	1
	# 		!
	# z	--------x---------
	# 		!
	# !	 3	!	4
	# \/		!				x = detector point
	#
	#

	# first calculate the 4 distance quantities
	# (we do squared first to make the code easier to read)
	# the grid points are all 1 grid inc away from the base
	# in one or both directions
	dist_sq[1] =  ( y_base + psgni_inc - dy ) *
		      ( y_base + psgni_inc - dy ) +
		      ( z_base - dz ) * ( z_base - dz )
	# this is the base value
	dist_sq[2] =  ( y_base - dy ) * ( y_base - dy ) +
		      ( z_base - dz ) * ( z_base - dz )
	dist_sq[3] =  ( y_base - dy ) * ( y_base - dy ) +
		      ( z_base + psgni_inc - dz ) *
		      ( z_base + psgni_inc - dz )
	dist_sq[4] =  ( y_base + psgni_inc - dy ) *
		      ( y_base + psgni_inc - dy ) +
		      ( z_base + psgni_inc - dz ) *
		      ( z_base + psgni_inc - dz )

	# now get un-squared distances, which is what we really want
	do i=1,4 {
	    dist[i] = sqrt(dist_sq[i])
	}

	# get the 4 values for bal and sigma
	bal_quad[1] = real(psgni_buf(1,base_offset+1))/10.
	bal_sigma_quad[1] = real(psgni_buf(2,base_offset+1))/10000.

	# this is the base value
	bal_quad[2] = real(psgni_buf(1,base_offset))/10.
	bal_sigma_quad[2] = real(psgni_buf(2,base_offset))/10000.

	bal_quad[3] = real(psgni_buf(1,base_offset+iy_pix))/10.
	bal_sigma_quad[3] = real(psgni_buf(2,base_offset+iy_pix))/10000.

	bal_quad[4] = real(psgni_buf(1,base_offset+iy_pix+1))/10.
	bal_sigma_quad[4] = real(psgni_buf(2,base_offset+iy_pix+1))/10000.

	if( debug >0 ){
	    call printf("%.5f %.5f %.5f %.5f\n")
	    call pargr(bal_quad[1])
	    call pargr(bal_quad[2])
	    call pargr(bal_quad[3])
	    call pargr(bal_quad[4])
	    call printf("%.5f %.5f %.5f %.5f\n")
	    call pargr(dist[1])
	    call pargr(dist[2])
	    call pargr(dist[3])
	    call pargr(dist[4])
	    call printf("%.5f %.5f %.5f %.5f\n")
	    call pargr(bal_sigma_quad[1])
	    call pargr(bal_sigma_quad[2])
	    call pargr(bal_sigma_quad[3])
	    call pargr(bal_sigma_quad[4])
	}

	# now do interpolation for bal
	numerator = 0.0
	denominator = 0.0
	do i=1,4 {
	    numerator = numerator + bal_quad[i]/dist[i]
	    denominator = denominator + 1.0/dist[i]
	}
	bal_spatial = numerator/denominator

	# and the interpolation for the sigma
	# (note: denominator is same as before)
	numerator = 0.0
	do i=1,4 {
	    numerator = numerator + bal_sigma_quad[i]*bal_sigma_quad[i]/dist[i]
	}
	bal_sigma_spatial = sqrt(numerator/denominator)
end

#
# GET_DGNI_BAL -- get the spatial bal from dgni file
#
procedure get_dgni_bal(dy, dz, dgni_bounds,dgni_inc,
			  dgni_buf,bal_spatial,bal_sigma_spatial, debug)

real	dy			# i: detector Einstein coords.
real	dz			# i: detector Einstein coords.
int	dgni_bounds[4]		# i: extremes of dgni grid
real	dgni_inc		# i: inc along y,z axis for dgni grid
short	dgni_buf[2,DGNI_RECS]	# i: dgni grid
real	bal_spatial		# o: bal from dgni
real	bal_sigma_spatial	# o: bal sigma from dgni
int	debug			# i: debug level

int	base_offset		# l: base array offset to 'closest grid pnt'
int	iy_pix			# l: integer of y_pix_per_line
int	i			# l: loop counter
real	bal_quad[4]		# l: bals for each point in quadrant
real	bal_sigma_quad[4]	# l: sigmas for each point in quadrant
real	denominator		# l: temp in interpolation calc
real	dist[4]			# l: dist from interpolation points
real	dist_sq[4]		# l: dist sq from interpolation points
real	numerator		# l: temp in interpolation cal#c
real	y_pix_per_line		# l: (yend-ybegin)/inc
real	y_base			# l: base position on grid x of 'closest pnt'
real	z_base			# l: base position on grid y of 'closest pnt'
real	y_incs			# l: (xbegin-xi)/inc
real	z_incs			# l: (ybegin-yi)/inc

begin
	# check to make sure we are within bounds and flag results if not
	if( (dy<dgni_bounds[1])||(dy>dgni_bounds[2]) ||
	    (dz<dgni_bounds[3])||(dz>dgni_bounds[4]) ){
		bal_spatial = -1.0
		bal_sigma_spatial = 0.0
		return
	}

	# check to see if any coord is directly on a boundary line and
	# if so, push it just a bit into the grid
	if(dy==dgni_bounds[1])
	    dy = dy + 0.001	# top 
	if(dy==dgni_bounds[2])
	    dy = dy - 0.001	# bottom
	if(dz==dgni_bounds[3])
	    dz = dz + 0.001	# left
	if(dz==dgni_bounds[4])
	    dz = dz - 0.001	# right

	# else define the major quantities:
	# z_incs - number of array elements we go in z direction
	# y_incs - number of array elements we go in y direction
	# y_pix_per_line - number of incs in line of y (fastest moving dir.)
	y_incs = floor((dy-dgni_bounds[1])/dgni_inc)
	z_incs = floor((dz-dgni_bounds[3])/dgni_inc)
	y_pix_per_line = (dgni_bounds[2]-dgni_bounds[1])/dgni_inc  + 1.0
	iy_pix = y_pix_per_line

	# use these to calculate the array element closest to detector position
	# but smaller than it ...
	base_offset = int(y_incs + y_pix_per_line * z_incs) + 1

	# ... and calculate the y,z position in grid of this element
# NB: These two lines of code are different from the original code in bal_histo
# because bal_histo has a bug and does not correctly calculate the base values.
# This fix affects the dgni values only.  Signed, Eric and Ginevra
	y_base=floor((dy-dgni_bounds[1])/dgni_inc)*dgni_inc+dgni_bounds[1]
	z_base=floor((dz-dgni_bounds[3])/dgni_inc)*dgni_inc+dgni_bounds[3]

	# now see if the point we want is exactly on a grid point
	if( (dy==y_base) && (dz==z_base) ) {
	    # if so, use the array element we just calculated
	    bal_spatial = real(dgni_buf(1,base_offset))/10.
	    bal_sigma_spatial = real(dgni_buf(2,base_offset))/1000.
	    return
	}

	# if not, interpolate using 4 grid points centered around the detector
	# coords with 1 point in each quadrant
	# balx = {sum(i=1,4) bali - ri} / {sum(i=1,4) ri}
	# sigmax = sqrt{sum(i=1,4) sigi**2/ri**2 }/{sum(i=1,4) ri}
	# where ri is distance

	#
	# note that the quadrants are numbered as follows:
	#
	# 		y ->
	#
	# 		!
	# 	2	!	1
	# 		!
	# z	--------x---------
	# 		!
	# !	 3	!	4
	# \/		!				x = detector point
	#
	#

	# first calculate the 4 distance quantities
	# (we do squared first to make the code easier to read)
	# the grid points are all 1 grid inc away from the base
	# in one or both directions
	dist_sq[1] =  ( y_base + dgni_inc - dy ) *
		      ( y_base + dgni_inc - dy ) +
		      ( z_base - dz ) * ( z_base - dz )
	# this is the base value
	dist_sq[2] =  ( y_base - dy ) * ( y_base - dy ) +
		      ( z_base - dz ) * ( z_base - dz )
	dist_sq[3] =  ( y_base - dy ) * ( y_base - dy ) +
		      ( z_base + dgni_inc - dz ) *
		      ( z_base + dgni_inc - dz )
	dist_sq[4] =  ( y_base + dgni_inc - dy ) *
		      ( y_base + dgni_inc - dy ) +
		      ( z_base + dgni_inc - dz ) *
		      ( z_base + dgni_inc - dz )

	# now get un-squared distances, which is what we really want
	do i=1,4 {
	    dist[i] = sqrt(dist_sq[i])
	}

	# get the 4 values for bal and sigma
	bal_quad[1] = real(dgni_buf(1,base_offset+1))/10.
	bal_sigma_quad[1] = real(dgni_buf(2,base_offset+1))/10000.

	# this is the base value
	bal_quad[2] = real(dgni_buf(1,base_offset))/10.
	bal_sigma_quad[2] = real(dgni_buf(2,base_offset))/10000.

	bal_quad[3] = real(dgni_buf(1,base_offset+iy_pix))/10.
	bal_sigma_quad[3] = real(dgni_buf(2,base_offset+iy_pix))/10000.

	bal_quad[4] = real(dgni_buf(1,base_offset+iy_pix+1))/10.
	bal_sigma_quad[4] = real(dgni_buf(2,base_offset+iy_pix+1))/10000.

	if( debug >0 ){
	    call printf("%.5f %.5f %.5f %.5f\n")
	    call pargr(bal_quad[1])
	    call pargr(bal_quad[2])
	    call pargr(bal_quad[3])
	    call pargr(bal_quad[4])
	    call printf("%.5f %.5f %.5f %.5f\n")
	    call pargr(dist[1])
	    call pargr(dist[2])
	    call pargr(dist[3])
	    call pargr(dist[4])
	    call printf("%.5f %.5f %.5f %.5f\n")
	    call pargr(bal_sigma_quad[1])
	    call pargr(bal_sigma_quad[2])
	    call pargr(bal_sigma_quad[3])
	    call pargr(bal_sigma_quad[4])
	}

	# now do interpolation for bal
	numerator = 0.0
	denominator = 0.0
	do i=1,4 {
	    numerator = numerator + bal_quad[i]/dist[i]
	    denominator = denominator + 1.0/dist[i]
	}
	bal_spatial = numerator/denominator

	# and the interpolation for the sigma
	# (note: denominator is same as before)
	numerator = 0.0
	do i=1,4 {
	    numerator = numerator + bal_sigma_quad[i]*bal_sigma_quad[i]/dist[i]
	}
	bal_sigma_spatial = sqrt(numerator/denominator)
end

#
# GET_MEAN_BAL -- get the mean bal from a histogram
#
procedure get_mean_bal(bh, histo, bal_mean)

pointer	bh				# i: bal histo pointer
real	histo[ARB]			# i: histogram of bal values
real	bal_mean			# o: mean bal
int	i				# l: loop counter
real	bal				# l: current bal value
real	percent				# l: current bal's percentage

begin
	# reset mean
	bal_mean = 0.0
	# for each histo value ...
	do i=1, MAX_BALS{
	    # if the fraction at this bal is non-zero ...
	    if( histo[i] > EPSILONR ){
	 	# get percentage
		percent = histo[i]
		# get this bal
		bal = BH_START_BAL(bh) + float(i-1)*BH_BAL_INC(bh)
		# add to mean
		bal_mean = bal_mean + bal * percent
	    }
	}
end

#
# ADD_TO_HISTO -- add fraction to the bal histogram
#
procedure add_to_histo(bal_effective, time_fraction, bh, histo, debug)

real	bal_effective			# i: combo of spatial and time bal
real	time_fraction			# i: current time fraction
pointer	bh				# i: bal histo pointer
real	histo[ARB]			# o: bal histo
int	debug				# i: debug level

int	offset				# l: offset into histo buf

begin
	# make sure bal is within limits
	if( (bal_effective >= BH_START_BAL(bh)) &&
	    (bal_effective <= BH_END_BAL(bh)) ){
	    # get offset into histo buf (from 0)
	    offset = int((bal_effective-BH_START_BAL(bh))/BH_BAL_INC(bh))+1
	    # add time fraction to histo buf
	    histo[offset] = histo[offset] + time_fraction
	}
end

#
#  RENORMALIZE_HISTO -- renormalize the bal histogram
#
procedure renormalize_histo(bh, histo, debug)

pointer	bh				# i: bal histo pointer
real	histo[ARB]			# i: bal histogram
int	debug				# i: debug level

int	i				# l: loop counter
real	total				# l: total percentage in histogram

begin
	# get total bal fraction
	total = 0.0
	do i=1, BH_BAL_STEPS(bh){
	    total = total + histo[i]
	}
	# check for 0 - this really shouldn't happen
	if( total < EPSILON )
	    call error(1, "bal histogram has no entries")
	# now renormalize
	do i=1, BH_BAL_STEPS(bh){
	    histo[i] = (histo[i]/total)
	}
	if( debug >0 ){
	    call printf("bal histo: ")
	    do i=1, BH_BAL_STEPS(bh){
		if( histo[i] < EPSILON )
		    next
		call printf("%d %2.f; ")
		call pargi(i)
		call pargr(histo[i])
	    }
	    call printf("\n")
	    call flush(STDOUT)
	}
end

#
#  OUTPUT_HISTO -- put the bal histogram into the bal structure
#
procedure output_histo(histo, bh, used, debug)

real	histo[ARB]				# i: bal histogram
pointer	bh					# o: bal struct
int	used					# i: flag if psgni/dgni used
int	debug					# i: debug level

int	i					# l: loop counter
int	j					# l: bal counter
real	tpercent				# l: total percentage
real	mean					# l: mean bal value

begin
	# no non-zero bal percentages as yet
	j = 0
	tpercent = 0.0
	mean = 0.0
	# look for all non-zero bals
	do i=1, MAX_BALS{
	    if( histo[i] > EPSILONR ){
		j = j+1
		BH_PERCENT(bh,j) = histo[i] * 100.0
		tpercent = tpercent + BH_PERCENT(bh,j)
		BH_BAL(bh,j) = BH_START_BAL(bh) +
				 float(i-1)*BH_BAL_INC(bh)
		mean = mean + BH_BAL(bh,j) * BH_PERCENT(bh,j)/100.0
	    }
	}
	# make sure we have close to 100% (frh 8/8/89)
	if( (tpercent<99.0) || (tpercent>101.0) )
	    call errorr(1, "bal histogram is not close to 100%", tpercent)
	BH_MEAN_BAL(bh) = mean
	BH_ENTRIES(bh) = j
	BH_BAL_FLAG(bh) = used
end

#
#  UN_ASPECT_COORDS -- take aspect correction out of coords and
#		       convert to Einstein coords for later
#
procedure un_aspect_coords(cur_blt, y, z, dy, dz)

pointer	cur_blt				# i: current blt record
real	y				# l: aspected y coord
real	z				# l: aspected z coord
real	dy				# o: unaspected y pos einstein coords
real	dz				# o: unaspected z pos einstein coords

# all of this is in einstein coords:
real	half				# l: half of the ipc field
real	yasp				# l: aspect y offset
real	zasp				# l: aspect z offset
real	theta				# l: aspect roll
real	thetanom			# l: nominal roll
real	thetabin			# l: binned roll
real	thetasums			# l: sum of thetas
real	phi				# l: boresight angle
real	fybore				# l: y boresight correction
real	fzbore				# l: z boresight correction
real	ybr				# l: ?
real	zbr				# l: ?
real	sintp				# l: sin of tangent plane dir
real	costp				# l: cos of tangent plane dir

begin
	# first cut - we convert back to einstein to do this
	half = 511.5
	# get aspect quantities
	# the z aspect offset is negative because of the coord transf.
	yasp = BLT_ASPX(cur_blt)
	zasp = - BLT_ASPY(cur_blt)
	theta = BLT_ROLL(cur_blt)
	# get boresight quantities
	phi = BLT_BOREROT(cur_blt)
	fybore = BLT_BOREX(cur_blt)
	# the z aspect offset is negative because of the coord transf.
	fzbore = - BLT_BOREY(cur_blt)
	# get roll angles
	thetanom = BLT_NOMROLL(cur_blt)
	thetabin = BLT_BINROLL(cur_blt)
	
#	THIS IS THE CODE FROM ASPSET:
	thetasums = thetanom + thetabin
#	include the half offset
	ybr = half
	zbr = half

#	the original code did not include binning offsets
#	ybr = ybr + yboff
#	zbr = zbr + zboff

#	get aspect correction factors
	costp = cos(thetasums)
	sintp = sin(thetasums)
	ybr = ybr-(costp*yasp-sintp*zasp)
	zbr = zbr-(sintp*yasp+costp*zasp)
	thetasums = thetasums+theta

#	get boresight corrections
	costp = cos(thetasums)
	sintp = sin(thetasums)
	ybr = ybr-(costp*fybore-sintp*fzbore)
	zbr = zbr-(sintp*fybore+costp*fzbore)
	thetasums = thetasums-phi

#	get rotation quantities
	costp = cos(thetasums)
	sintp = sin(thetasums)
#	get rotated half set
	ybr = ybr-half*(costp-sintp)
	zbr = zbr-half*(sintp+costp)

#	THIS IS THE CODE FROM TROTINV
	dy = costp*(y-ybr)+sintp*(z-zbr)
	dz = -sintp*(y-ybr)+costp*(z-zbr)
end

#
# FLIP_ALL_BAL -- routine which flips the signs of all the BLT records.
#
procedure flip_all_bal(blt,nblt)
pointer	blt
int	nblt

int	i_blt
begin
	do i_blt=1,nblt
	{
	    call bal_flip(BLT(blt,i_blt))
	}
end
