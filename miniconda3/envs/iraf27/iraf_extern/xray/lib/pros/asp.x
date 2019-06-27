#$Header: /home/pros/xray/lib/pros/RCS/asp.x,v 11.0 1997/11/06 16:20:16 prosb Exp $
#$Log: asp.x,v $
#Revision 11.0  1997/11/06 16:20:16  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:27:15  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:45:25  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:08:48  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:43:54  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:14:53  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  13:47:00  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  00:48:52  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:06:37  pros
#General Release 1.0
#
# -------------------------------------------------------------------------
# Module:       asp
# Project:      PROS -- ROSAT RSDC
# Purpose:      Apply aspect corrections ( assumes BS offsets included in aspect)
# Description:  
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1990.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} Maureen Conroy initial version  August 1990
#               {n} <who> -- <does what> -- <when>
#
# -------------------------------------------------------------------------
include <qpoe.h>
#include	"/pros/builds/apr89/lib/qpoe.h"

include	<math.h>
include	<mach.h>

define	ASP_X	1
define	ASP_Y	2
define	ASP_ROLL 3

########################################################################
#
#  Convert from detector position to image position using current
#	aspect solution ( x,y offsets and roll)
#
#
########################################################################
procedure asp_apply(det_xpos,det_ypos,aspect,det_xcenter,det_ycenter,
		      nominal_roll,pos_x,pos_y)

real	det_xpos		# i: un-aspected ( detector ) position (x,y)
real	det_ypos		# i: un-aspected ( detector ) position (x,y)

real	aspect[ARB]		# i: aspect offset record
				#    x offset in pixels
				#    y offset in pixels
				#    roll in radians
real	det_xcenter		# i: detector center
real	det_ycenter		# i: detector center
real	nominal_roll		# i: nominal observation roll from header
				#    in radians
real	pos_x			# o: input position ( x,y)
real	pos_y			# o: input position ( x,y)

real	bin_offsets[3]		# l: binning offsets ( nominally 0 )
real	rmat[4]			# l: rotation matrix


begin
	call aclrr(bin_offsets,3)
#	
#    nominal_roll in radians = roll  * pi radians
#                             -----   ----------
#                                      180 degs

#	nominal_roll = nominal_roll * PI / 180.0E0
	
	call asp_transmatx(aspect,bin_offsets,nominal_roll,det_xcenter,
			     det_ycenter,rmat)
	call asp_tranrot(rmat,det_xpos,det_ypos,pos_x,pos_y)
end

########################################################################
#  Convert from image position to detector position using current
#	aspect solution ( x,y offsets and roll)
#
#########################################################################
procedure asp_deapply(pos_x,pos_y,aspect,det_xcenter,det_ycenter,
		      nominal_roll,det_xpos,det_ypos)

real	pos_x			# i: input position ( x,y)
real	pos_y			# i: input position ( x,y)
real	aspect[ARB]		# i: aspect offset record
				#    x offset in pixels
				#    y offset in pixels
				#    roll in radians
real	det_xcenter		# i: detector center
real	det_ycenter		# i: detector center
real	nominal_roll		# i: nominal observation roll from header

real	det_xpos		# o: un-aspected ( detector ) position (x,y)
real	det_ypos		# o: un-aspected ( detector ) position (x,y)

real	bin_offsets[3]		# l: binning offsets ( nominally 0 )
real	rmat[4]			# l: rotation matrix
real	trmat[4]		# l: inverted rotation matrix for de-applying


begin
	call aclrr(bin_offsets,3)
#	
#    nominal_roll in radians = roll  * pi radians
#                             -----   ----------
#                                      180 degs

#	nominal_roll = nominal_roll * PI / 180.0E0
	
	call asp_transmatx(aspect,bin_offsets,nominal_roll,det_xcenter,
			     det_ycenter,rmat)
	call asp_invmatrix(rmat,trmat)
	call asp_tranrot(trmat,pos_x,pos_y,det_xpos,det_ypos)
end

########################################################################
#   create the inverse of a transformation matrix
#
#
#   general description:
#   create the inverse of a transformation matrix
#   where transmat ( 1 ) = cos ( theta )
#         transmat ( 2 ) = sin ( theta )
#         transmat ( 3 ) = x translation
#         transmat ( 4 ) = y translation
# 
#   note: this will convert a degap->poe matrix to a poe->degap matrix
#                        or a poe->degap matrix to a degap->poe matrix
#
########################################################################
procedure asp_invmatrix( transmat, inverse)
real	transmat[ARB]			# i: input transformation matrix
      
real	inverse[ARB]			# o: inverted transformation matrix

int	index				# l: local loop index

#   to obtain the inverse of a transformation matrix

begin
	inverse(1) = transmat(1)
	for(index=2;index<=4;index=index+1)
	    inverse(index) = -transmat(index)
 
	call asp_onlyrot( inverse,inverse(3),inverse(4),inverse(3),inverse(4))
end

########################################################################
#
#   This subroutine performs a 2 dimensional rotation.
#
#    general description:
#   This subroutine performs a 2 dimensional rotation.
#   Arguments:
#       RBUFF   rotation matrix
#       Where: RBUFF(1) = COSTP ,  RBUFF(2) = SINTP,
#              RBUFF(3) and  RBUFF(4) are not used
#       XI      Initial coordinate on input.
#       YI      Initial coordinate on input.
#       XF      Final coordinate on output.
#       YF      Final coordinate on output.
#       XF = COSTP*XI-SINTP*YI
#       YF = SINTP*XI+COSTP*YI
#
########################################################################
procedure asp_onlyrot(rbuff, xi, yi, xf, yf)

real	rbuff[ARB]		# i: rotation matrix
real	xi			# i: input x coordinate
real	yi			# i: input y coordinate

real	xf			# o: final x coordinate
real	yf			# o: final y coordinate

real	temp_xf			# l: temporary storage for xf
begin
	temp_xf = rbuff[1]*xi - rbuff[2]*yi
	yf	= rbuff[2]*xi + rbuff[1]*yi
	xf	= temp_xf
end

########################################################################
#
#   This subroutine performs a 2 dimensional rotation and translation.
#
#   general description:
#   This subroutine performs a 2 dimensional rotation and translation.
#   Arguments:
#       RBUFF   rotation matrix
#       Where: RBUFF(1) = COSTP ,  RBUFF(2) = SINTP,
#              RBUFF(3) = XBR , RBUFF(4) = YBR
#       XI      Initial coordinate on input.
#       YI      Initial coordinate on input.
#       XF      Final coordinate on output.
#       YF      Final coordinate on output.
#       XF = COSTP*XI-SINTP*YI+XBR
#       YF = SINTP*XI+COSTP*YI+YBR
########################################################################

procedure asp_tranrot( rbuff, xi, yi, xf, yf)
real	rbuff[ARB]		# i: rotation matrix
real	xi			# i: input x coordinate
real	yi			# i: input y coordinate

real	xf			# o: final x coordinate
real	yf			# o: final y coordinate

real	temp_x			# l: temporary x storate
begin
	temp_x = rbuff[1]*xi - rbuff[2]*yi + rbuff[3]
	yf = rbuff[2]*xi + rbuff[1]*yi + rbuff[4]
	xf = temp_x
end


########################################################################
#
#  create the rosat hri aspect transformation matrix
#
#  degap coordinates to poe coordinates, using:
#  x,y,roll aspect offsets with boresight corrections already applied,
#   binned x,y,roll, nominal roll and an x,y center of rotation.
#  See FAP's 1/14/87 Memo on Minutes to Aspect meeting Jan. 8 1987.
#  All roll angles should be given in radians, all offsets should be
#  of consistent units - the output units wiull be the same as the
#  input units.
########################################################################
procedure asp_transmatx(asp_solution,bin_offsets,nominal_roll,
				    xcenter,ycenter,tranrot_matrix)

real	asp_solution[ARB]		# i: aspect solution
					#    x offset pixels
					#    y offset pixels
					#    roll in radians
real	bin_offsets[ARB]		# i: binning offsets
real	nominal_roll			# i: nominal roll in radians
real	xcenter				# i: rotation center
real	ycenter				# i: rotation center

real	tranrot_matrix[ARB]		# rotation matrix ( cos,sin,x,y)

real	bin_roll			# l: nominal + binned roll
real	nombinasp_roll			# l: nominal + binned + aspect roll
real	x_aspbs				# l: binned x offset rotated  by aspect
real	x_rot_center			# l: rotated x center
real	y_aspbs				# l: binned y offset rotated by aspect
real	y_rot_center			# l: rotated y center

#real	cos(),sin()
begin
	bin_roll = nominal_roll + bin_offsets(ASP_ROLL)
	tranrot_matrix(1) = cos( bin_roll)
	tranrot_matrix(2) = sin( bin_roll)
 
	call asp_onlyrot( tranrot_matrix, asp_solution(ASP_X), 
			  asp_solution(ASP_Y),
		          x_aspbs, y_aspbs)

	nombinasp_roll = bin_roll + asp_solution(ASP_ROLL)
	tranrot_matrix(1) = cos( nombinasp_roll)
	tranrot_matrix(2) = sin( nombinasp_roll)
      
	call asp_onlyrot( tranrot_matrix, xcenter, ycenter, x_rot_center,
		          y_rot_center)

	tranrot_matrix(3) = x_aspbs + xcenter + bin_offsets(ASP_X) - 
			    x_rot_center
	tranrot_matrix(4) = y_aspbs + ycenter + bin_offsets(ASP_Y) - 
			    y_rot_center
end
########################################################################
#
#   Applies a rotation matrix of THETA radians to a set of coordinates.
#
#
########################################################################
procedure asp_rotcoords(xin, yin, theta, xout, yout)
#
#   Applies a rotation matrix of THETA radians to a set of coordinates.
#
real	xin             # i: input X coordinate
real	yin             # i: input Y coordinate
real	theta		# i: rotation angle in radians

real	xout            # o: rotated X coordinate
real	yout		# o: rotated Y coordinate

begin
	xout = xin * cos(theta) - yin * sin(theta)
	yout = xin * sin(theta) + yin * cos(theta)
end
###############################################################################
#
#  Apply boresight correction to a set of aspect offsets
#
###############################################################################
procedure asp_appbs(bs_offsets, asp_offsets)
real	bs_offsets[3]		#i: boresight offsets x,y,theta
real	asp_offsets[3]		#i/o: aspect offsets x,y,theta

real	xcoord			#l: x coordinate
real	ycoord			#l: y coordinate

begin
	call asp_rotcoords(bs_offsets[1],bs_offsets[2],asp_offsets[3],
			   xcoord,ycoord)

	asp_offsets[1] = asp_offsets[1] + xcoord
	asp_offsets[2] = asp_offsets[2] + ycoord
	asp_offsets[3] = asp_offsets[3] - bs_offsets[3]
end

