#$Header: /home/pros/xray/xspectral/source/RCS/matrix.x,v 11.0 1997/11/06 16:42:43 prosb Exp $
#$Log: matrix.x,v $
#Revision 11.0  1997/11/06 16:42:43  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:30:09  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:32:37  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:56:12  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:50:56  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:44:54  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  18:15:52  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  91/09/22  19:06:24  wendy
#Added
#
#Revision 3.0  91/08/02  01:58:30  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:05:00  pros
#General Release 1.0
#
# Project:      PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
#

# Matrix.x
#
# John : Dec 89
#
# In support of Spline_patch.x
#
# mat_x_mat(mat1, mat2, mat3)		mat1 x mat2 	 -> mat3
# mat_trans(mat1, mat2)			mat1 (transpose) -> mat2
# vec_x_mat(vec1, mat, vec2)		vec1 x mat	 -> vec2


procedure mat_x_mat(mat1, mat2, mat3)

real	mat1[4, 4]
real	mat2[4, 4]
real	mat3[4, 4]
#--

int	i, j, k

begin
	do j = 1, 4
	    do i = 1, 4 {
		mat3[i, j] = 0
		do k = 1, 4
		    mat3[i, j] = mat3[i, j] + mat1[k, j] * mat2[i, k]
	    }
end


procedure vec_x_mat(vec1, mat, vec2)

real	vec1[4]
real	mat [4, 4]
real	vec2[4]
#--

int	i, j

begin
	do j = 1, 4 {
	    vec2[j] = 0
	    do i = 1, 4
		vec2[j] = vec2[j] + vec1[i] * mat[j, i] 
	}
end


procedure mat_trans(mat1, mat2)

real	mat1[4, 4]
real	mat2[4, 4]
#--

int	i, j

begin
	do i = 1, 4
	    do j = 1, 4
		mat2[i, j] = mat1[j, i]
end
