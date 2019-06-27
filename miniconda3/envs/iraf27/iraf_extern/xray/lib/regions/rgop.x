#$Header: /home/pros/xray/lib/regions/RCS/rgop.x,v 11.0 1997/11/06 16:19:03 prosb Exp $
#$Log: rgop.x,v $
#Revision 11.0  1997/11/06 16:19:03  prosb
#General Release 2.5
#
#Revision 9.2  1996/03/12 20:34:47  prosb
#JCC/Denis - Invoking PL_NEEDCOMPRESS(pm) needs to be made conditional
#            on PL_LLOP(pm) being non-zero to avoid a "divide by zero"
#            possibility.
#
#Revision 9.0  1995/11/16  18:26:36  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:44:48  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:08:05  prosb
#General Release 2.3
#
#Revision 6.2  93/08/30  19:59:36  dennis
#Added call to pl_compress() from rg_flush(), to keep obsolete scanlines 
#from clogging up memory.
#
#Revision 6.1  93/07/02  14:27:57  mo
#MC	7/2/93		Fix procedure declaration for dbcom to NOT be function
#
#Revision 6.0  93/05/24  15:38:59  prosb
#General Release 2.2
#
#Revision 5.3  93/05/19  04:49:21  dennis
#In rg_add(), don't try to convert position coordinates for FIELD; 
#FIELD has no position.
#
#Revision 5.2  93/05/18  23:53:29  dennis
#Changed several routines, to make temp masks in image-relative coordinates,
#not section-relative; formerly the conversion from section-relative to 
#image-relative occurred only at the time of flushing the final temp mask 
#to the target mask; that meant the temp mask borders didn't match the 
#image borders, which allowed out-of-bounds references.
#
#Revision 5.1  93/04/27  00:04:26  dennis
#Regions system rewrite.
#
#Revision 5.0  92/10/29  21:14:23  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  17:21:10  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  91/08/02  10:35:20  mo
#MC   8/2/91          Updated dependencies
#
#Revision 2.0  91/03/07  00:15:52  pros
#General Release 1.0
#
#  rgop.x
#
#  generic operator calls for the region algebra parser/compiler
#
#  Smithsonian Astrophysical Observatory
#  31 August 1988
#  Michael VanHilst
#
#  rg_init()
#  rg_new()
#  rg_add()
#  rg_not()
#  rg_merge()
#  rg_flush()

include <error.h>
include	<pmset.h>
include	<plio.h>
include	<regparse.h>
include "rgset.h"

# rgop.com
# define MAX_RGPM 100
# pointer pmask
# int	pltype
# int	pmdepth
# int	last_pm
# int	rgdepth
# int	rgvalue
# int	naxes
# int	axlen[PM_MAXDIM]
# int	v[PM_MAXDIM]
# pointer rgpm[MAX_RGPM]
# common /rgop/ pmask,pltype,pmdepth,last_pm,rgdepth,rgvalue,naxes,axlen,v,rgpm

define OP_SRC 5

# rg_init
# set up common space
procedure rg_init ( pl, pl_or_pm )
pointer	pl
int	pl_or_pm

include "rgop.com"

begin
	if( pl_or_pm == MSKTY_PM )
	    call pm_gsize (pl, naxes, axlen, pmdepth)
	else
	    call pl_gsize (pl, naxes, axlen, pmdepth)
	call amovki (1, v, PM_MAXDIM)
	call amovki (0, rgpm, MAX_RGPM)
	pmask = pl
	pltype = pl_or_pm
	last_pm = 0
	rgdepth = 1
	rgvalue = 1
end


# rg_new
# open a new temp pm and put the defined region into it
procedure rg_new ( type, argc, argv )
int	type
int	argc
real	argv[ARB]

pointer	pm			# l: pointer to temp mask
int	rop
include "rgop.com"

pointer	rg_new_rgpm()

begin
	# Create new temp pm
	pm = rg_new_rgpm()
	
	# Put it on top of the stack
	call rg_push_rgpm(pm)

	# Put the region into it
	rop = OP_SRC
	call rg_add (type, argc, argv, rop)
end


# rg_add
# add the defined region to the already open temp mask
procedure rg_add ( type, argc, argv, rgop )
int	type
int	argc
real	argv[ARB]
int	rgop

bool	sectrel
long	origin[2]
long	sect_offset[2]
real	imrel_posn[2]
int	count, i, j
pointer	sp
pointer	vpts
pointer	vx, vy
int	rop, pmop
include "rgop.com"

int	rg_opcode()

begin
	if (rgpm[last_pm] == 0) {
	    call printf ("WARNING: temp region not open\n")
	    return
	}
	pmop = RG_ROP
	rop = rg_opcode (rgop)
	if (rop > 100) {
	    call printf ("WARNING: unknown region operator\n")
	    return
	}

	if (argc >= 2) {	# if there are coordinates,
	    # use image-relative coordinates, not section-relative
	    sectrel = (PM_MAPXY(rgpm[last_pm]) == YES)
	    if (sectrel) {
		origin[1] = 0
		origin[2] = 0
		call imaplv(PM_REFIM(rgpm[last_pm]), origin, sect_offset, 2)
		imrel_posn[1] = argv[1] + sect_offset[1]
		imrel_posn[2] = argv[2] + sect_offset[2]
	    } else {
		imrel_posn[1] = argv[1]
		imrel_posn[2] = argv[2]
	    }
	}

	# (use sectrel when necessary for the rest of this routine; 
	#  PM_MAPXY() must be NO when we call any rg_<shape>() routine)
	PM_MAPXY(rgpm[last_pm]) = NO

	switch( type ) {
	case ANNULUS:
	    call rg_annulus (rgpm[last_pm], imrel_posn[1], imrel_posn[2], 
			argv[3], argv[4], rgvalue, rgdepth, pmop, rop, pltype)
			     
	case BOX:
	    call rg_box (rgpm[last_pm], imrel_posn[1], imrel_posn[2], 
			argv[3], argv[4], rgvalue, rgdepth, pmop, rop, pltype)
	case CIRCLE:
	    call rg_circle (rgpm[last_pm], imrel_posn[1], imrel_posn[2], 
			argv[3], rgvalue, rgdepth, pmop, rop, pltype)
	case ELLIPSE:
	    call rg_ellipse (rgpm[last_pm], imrel_posn[1], imrel_posn[2], 
			argv[3], argv[4], argv[5], rgvalue, rgdepth, pmop, 
			rop, pltype)
	case FIELD:
	    call rg_field (rgpm[last_pm], rgvalue, rgdepth, pmop, rop, pltype)
	case PIE:
	    call rg_pie (rgpm[last_pm], imrel_posn[1], imrel_posn[2], 
			argv[3], argv[4], rgvalue, rgdepth, pmop, rop, pltype)
	case POINT:
	    call smark (sp)
	    call salloc (vpts, argc, TY_REAL)
	    do j = 1, argc, 2 {
		if (sectrel) {
		    Memr[vpts + j - 1] = argv[j    ] + sect_offset[1]
		    Memr[vpts + j    ] = argv[j + 1] + sect_offset[2]
		} else {
		    Memr[vpts + j - 1] = argv[j    ]
		    Memr[vpts + j    ] = argv[j + 1]
		}
	    }
	    call rg_point (rgpm[last_pm], argc, Memr[vpts], 
			   rgvalue, rgdepth, pmop, rop, pltype)
	    call sfree (sp)
	case POLYGON:
	    call smark (sp)
	    count = argc / 2
	    call salloc (vx, count, TY_REAL)
	    call salloc (vy, count, TY_REAL)
	    i = 0
	    do j = 1, argc, 2 {
                if (sectrel) {
		    Memr[vx + i] = argv[j  ] + sect_offset[1]
		    Memr[vy + i] = argv[j+1] + sect_offset[2]
                } else {
		    Memr[vx + i] = argv[j  ]
		    Memr[vy + i] = argv[j+1]
                }
		i = i + 1
	    }
	    call rg_polygon (rgpm[last_pm], count, Memr[vx], Memr[vy],
			     rgvalue, rgdepth, pmop, rop, pltype)
	    call sfree (sp)
	case ROTBOX:
	    call rg_rotbox (rgpm[last_pm], imrel_posn[1], imrel_posn[2], 
			argv[3], argv[4], argv[5], rgvalue, rgdepth, pmop, 
			rop, pltype)
	default:
	    call printf ("WARNING: unknown region type\n")
	    return
	}
end


# rg_not
# invert bits of temp region
procedure rg_not()

include "rgop.com"

begin
	# set subsection to full region
	call amovki (1, v, PL_MAXDIM)
	call pl_rop (rgpm[last_pm], v, rgpm[last_pm], v, axlen, 
							PIX_NOT(PIX_DST))
end


# rg_merge
# create a new pm by combining two existing pm's (rop'ing first onto second
procedure rg_merge ( rgop )
int	rgop

int	rop
pointer	pm1, pm2, pm3
include	"rgop.com"

int	rg_opcode()
pointer	rg_pop_rgpm()
pointer	rg_new_rgpm()

begin
	# get appropriate rop code
	rop = rg_opcode (rgop)
	if (rop > 100) {
	    call printf ("WARNING: unknown region operator\n")
	    return
	}
	# set subsection to full image
	call amovki (1, v, PM_MAXDIM)

	# Pop the 2 existing temp masks from the stack
	pm2 = rg_pop_rgpm()
	pm1 = rg_pop_rgpm()

	# Create new temp mask for resultant
	pm3 = rg_new_rgpm()
	PM_MAPXY(pm3) = NO

	# Combine pm1 and pm2 into pm3
	call pl_rop (pm2, v, pm3, v, axlen, PIX_SRC)
	call pl_rop (pm1, v, pm3, v, axlen, rop)

	# Push the resultant onto the top of the stack
	call rg_push_rgpm(pm3)

	# Close the old temp masks
	call rg_close_rgpm(pm2)
	call rg_close_rgpm(pm1)
end


# rg_flush
# paint temp onto pm by using temp as stencil for index value
procedure rg_flush ( index, pm )
int	index
pointer	pm

int	i
pointer sp, rangebuf, linebuf
include	"rgop.com"

begin
	call smark (sp)
	call salloc (rangebuf, (axlen[1] + 1) * RL_LENELEM, TY_INT)
	call salloc (linebuf, axlen[1] + 1, TY_INT)

	# go through all the scanlines
	do i=1, axlen[2] {
	    v[2] = i
	    call pl_glri (rgpm[last_pm], v, Memi(rangebuf),
			  pmdepth, axlen[1], 0)
	    call rg_plpi (pm, v, Memi(rangebuf), Memi(linebuf),
			  pmdepth, axlen[1], RG_VALUE, index, pltype)
	}

	# if there are too many, release obsolete scanlines.

        # JCC/Denis - Invoking PL_NEEDCOMPRESS(pm) needs to be made 
        # conditional on PL_LLOP(pm) being non-zero to avoid 
        # a "divide by zero" possibility.

        if (PL_LLOP(pm) != 0) 
	   if (PL_NEEDCOMPRESS(pm))
	      call pl_compress (pm)

	# reset v[2]
	v[2] = 1
	# close all temporary masks (should be only one)
	do i = 1, last_pm
	    call rg_close_rgpm(rgpm[i])
	call amovki (0, rgpm, MAX_RGPM)
	last_pm = 0
	call sfree (sp)
end


# rg_opcode
# return the PIX code for a given RG operator
int procedure rg_opcode ( rgop )
int	rgop

int	rop

begin
	switch (rgop) {
	case OP_AND:
	    # operator for intersection of two regions
	    rop = and (PIX_SRC, PIX_DST)
	case OP_OR:
	    # operator for union of two regions
	    rop = or (PIX_SRC, PIX_DST)
	case OP_NOT:
	    # operator for exclusion of a region
	    rop = and (PIX_NOT(PIX_SRC), PIX_DST)
	case OP_XOR:
	    # operator for union less the intersection
	    rop = xor (PIX_SRC, PIX_DST)
	case OP_SRC:
	    # operator for painting a region into an empty mask
	    rop = PIX_SRC
	default:
	    rop = 1000
	}
	return (rop)
end


#int procedure dbcom ()
procedure dbcom ()

int	i
include	"rgop.com"

begin
	call printf ("axlen: %d, depth: %d\n v: ")
	    call pargi (axlen)
	    call pargi (pmdepth)
	do i = 1, PM_MAXDIM {
	    call printf ("%d ")
		call pargi (v[i])
	}
	call printf ("\n ptrs 1: %d, 2: %d, 3: %d \n")
	    call pargi (rgpm[1])
	    call pargi (rgpm[2])
	    call pargi (rgpm[3])
end


# RG_NEW_RGPM - Create a new temp mask; return pointer to it

pointer procedure rg_new_rgpm()

include "rgop.com"

pointer	pm_newmask()
pointer	pl_create()

begin
	if( pltype == MSKTY_PM )
	    return (pm_newmask (PM_REFIM(pmask), 1))
	else
	    return (pl_create (naxes, axlen, 1))
end


# RG_CLOSE_RGPM - Close an old temp mask

procedure rg_close_rgpm(pm)
pointer	pm			# i: pointer to temp mask to close

include "rgop.com"

begin
	if( pltype == MSKTY_PM )
	    call pm_close (pm)
	else
	    call pl_close (pm)
end


# RG_PUSH_RGPM - Increment rgpm stack pointer, check for overflow; 
#                push temp mask pointer onto top of stack

procedure rg_push_rgpm(pm)
pointer	pm			# i: pointer to temp mask

include "rgop.com"

begin
	# Bump stack pointer
	last_pm = last_pm + 1
	if (last_pm > MAX_RGPM)
	    call error(EA_FATAL, "temp mask stack overflow")

	# Push temp mask pointer onto top of stack
	rgpm[last_pm] = pm
end


# RG_POP_RGPM - Return temp mask pointer from top of rgpm stack, 
#               decrementing stack pointer, checking for underflow

pointer procedure rg_pop_rgpm()

include "rgop.com"

begin
	if (last_pm <= 0)
	    call error(EA_FATAL, "temp mask stack underflow")
	last_pm = last_pm - 1
	return (rgpm[last_pm+1])
end
