#$Header: /home/pros/xray/xspectral/source/RCS/spline.x,v 11.0 1997/11/06 16:43:21 prosb Exp $
#$Log: spline.x,v $
#Revision 11.0  1997/11/06 16:43:21  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:31:13  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:35:08  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:58:00  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:52:57  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:46:30  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  18:18:25  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  91/09/22  19:07:23  wendy
#Added
#
#Revision 3.0  91/08/02  01:59:11  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:07:40  pros
#General Release 1.0
#
# Project:      PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
#
# Spline_patch 
#
# from MVH to SPP by John : Dec 89 
#
procedure spline_patch(splinemat, contrlmat, xcnt, ycnt, xvals, yvals, patch)

real	splinemat[4, 4]			# i: matrix describing the type if fit
real	contrlmat[4, 4]			# i: patch control points
int	xcnt				# i: number of x values wanted
int	ycnt				# i: number of y values wanted
real	xvals[xcnt]			# i: x intervals
real	yvals[ycnt]			# i: y intervals
real	patch[xcnt, ycnt]		# o: filled interpolation patch
#--

real	yvec[4]
real	x, xx, xxx
real	transpose[4, 4]
real	temporary[4, 4]
real	transform[4, 4]
real	coef[4]

int	i, j

begin
	call mat_x_mat(splinemat, contrlmat, temporary)	# Create the transform matrix
	call mat_trans(splinemat, transpose)
	call mat_x_mat(temporary, transpose, transform)

	yvec[4] = 1.0

	# Pass over all points in the patch and compute a value
	#
	for ( j = 1; j <= ycnt; j = j + 1 ) {
	    yvec[3] = yvals[j];				# x side vector
	    yvec[2] = yvals[j] * yvals[j]
	    yvec[1] = yvals[j] * yvals[j] * yvals[j]

	    call vec_x_mat(yvec, transform, coef)	# x coefficients

	    for ( i = 1; i <= xcnt; i = i + 1 ) {
		x   = xvals[i]				# y side vector
		xx  = x * x
		xxx = x * x * x

	 	patch[i, j] =				# Run the xform 
		    ( coef[1] * xxx )  +  
		    ( coef[2] * xx   ) +
		    ( coef[3] * x    ) +   coef[4];
	    }
	}
end










