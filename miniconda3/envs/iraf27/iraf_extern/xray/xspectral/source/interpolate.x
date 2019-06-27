#$Header: /home/pros/xray/xspectral/source/RCS/interpolate.x,v 11.0 1997/11/06 16:42:24 prosb Exp $
#$Log: interpolate.x,v $
#Revision 11.0  1997/11/06 16:42:24  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:30:00  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:32:18  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:55:58  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:50:47  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:44:48  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  18:15:40  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  91/09/22  19:06:18  wendy
#Added
#
#Revision 3.0  91/08/02  01:58:27  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:04:04  pros
#General Release 1.0
#
# Project:      PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
#

# Interpolate.x
#
# John : Dec 89
#
# Use a matrix transform to interpolate data into a 2 dimentional
# array.
#
# Put on your thinking cap for this one boys and girls;  Its time to 
# play whose got the index!
#
procedure interpolate(x, y, in, xexp, yexp, out)

int	x, y					# x, y dim of the in array
real	in[x, y]				# input values
int	xexp, yexp				# x, y dim of the out array
real	out[xexp, yexp]				# output values
#--

pointer	ins		# ZERO based array Copy of the in array with edges
pointer	xinterval	# ZERO based array of output point intervals along each
pointer	yinterval	#  input patch.
pointer xbins		# ZERO based array of output patch sizes
pointer ybins		#
pointer	patch		# Zero based array of the output patch
real	control[4, 4]	# ONE based array of the input patch + control points

int	i, j		# TopLeft corner of the input patch in the ins arrray
			# the input patch size is 1, 1
int	a, b		# TopLeft corner of the output patch in the out array

real	inc		# incremetal difference along each axis
real	k		# a real
int	c, m, n		# counters

pointer	sp

real	CatRoms[4, 4]	# Transform definition	(Catmull Rom spline)

data	((CatRoms(i, j), i=1, 4), j=1, 4)	/ -0.5,  1.5, -1.5,  0.5,
						   1.0, -2.5,  2.0, -0.5,
						  -0.5,  0.0,  0.5,  0.0,
						   0.0,  1.0,  0.0,  0.0 /
begin
	call smark(sp)

	call salloc(ins, ( x + 2 ) * ( y + 2 ), TY_REAL)
	call inset(1, x, y, in, Memr[ins])

	call salloc(patch, (( xexp + x - 1 ) / ( x - 1 )) * 
			   (( yexp + y - 1 ) / ( y - 1 )) ,TY_REAL)

	call salloc(yinterval, yexp + 2, TY_REAL) 
	call salloc(xinterval, xexp + 2, TY_REAL) 
	call salloc(ybins, y + 2, TY_INT)
	call salloc(xbins, x + 2, TY_INT)

	inc = float(x - 1)/ float(xexp - 1)		# Create X intervals

	i = 0;  c = 0
	for ( a = 0; a < xexp - 1; ) {
	    k = a * inc - i
	    if ( k < 1 ) {
		Memr[xinterval + a] = k;  a = a + 1;  c = c + 1
	    } else {
		Memi[xbins + i] = c;      i = i + 1;  c = 0 
	    }
	}
	c = c + 1
	Memr[xinterval + a] = 1.0
	Memi[xbins + i] = c		# catch the last bin


	inc = float(y - 1)/ float(yexp - 1)		# Create Y intervals

	j = 0;  c = 0
	for ( b = 0; b < yexp - 1; ) {
	    k = b * inc - j
	    if ( k < 1 ) {
		Memr[yinterval + b] = k;  b = b + 1;  c = c + 1
	    } else {
		Memi[ybins + j] = c;      j = j + 1;  c = 0
	    }
	}
	c = c + 1
	Memr[yinterval + b] = 1.0
	Memi[ybins + j] = c		# catch the last bin

	# for each four points in the array pass them (and their neighbors)
	# into the Spline_patch and get a matrix of interpolation
	# values.  Then copy these into the out array.
	#
	j = 0
	for ( b = 0; b < yexp; ) {
	    i = 0
	    for ( a = 0; a < xexp; ) {

		# Make the control grid		      # SPP is the most worst
		#				      # combination of zero
		do m = 0, 3			      # and one based indexing
		    do n = 0, 3
			control[n + 1, m + 1] = Memr[ins  + 
						( i + n ) + 
						( j + m ) * (x + 2)]
	
		call spline_patch(CatRoms, control,
				  Memi[xbins + i]    , Memi[ybins + j],
		   		  Memr[xinterval + a], Memr[yinterval + b],
				  Memr[patch])

		# Copy the patch to the out array
		#
		do m = 0, Memi[ybins + j] - 1
		    do n = 0, Memi[xbins + i] - 1
			out[a + n + 1, b + m + 1] = Memr[patch + (n) +
						         (m * Memi[xbins + i])]
		a = a + Memi[xbins + i]
		i = i + 1
	    }
	    b = b + Memi[ybins + j]
	    j = j + 1
	}
	call sfree(sp)
end



procedure inset(mode, x, y, in, out)

int	mode
int	x, y
real	in[x, y]
real	out[x+2, y+2]
#--

int	i, j

begin

	switch ( mode ) {

	case 1:
		out[1,     1]     = in[1, 1]
		out[x + 2, 1]     = in[x, 1]
		out[1,     y + 2] = in[1, y]
		out[x + 2, y + 2] = in[x, y]

		do i = 1, x  { out[i + 1,     1] = in[i, 1] }
		do i = 1, x  { out[i + 1, y + 2] = in[i, y] }

		do i = 1, y  { out[    1, i + 1 ] = in[1, i] }
		do i = 1, y  { out[x + 2, i + 1 ] = in[x, i] }

		do i = 1, x
		    do j = 1, y
			out[i + 1, j + 1] = in[i, j]
	default:

		call error(1, "Inset: copy mode not recognized")
	}
end





