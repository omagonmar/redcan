#$Header: /home/pros/xray/lib/pros/RCS/qpaxlen.x,v 11.0 1997/11/06 16:21:06 prosb Exp $
#$Log: qpaxlen.x,v $
#Revision 11.0  1997/11/06 16:21:06  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:28:12  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:47:01  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:10:31  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:53:57  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:17:22  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  13:49:47  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:01:16  wendy
#General
#
#Revision 2.0  91/03/07  00:07:26  pros
#General Release 1.0
#
#
# Module:       QPAXLEN
# Project:      PROS -- ROSAT RSDC
# Purpose:      read the qpoe or image AXLEN to determint the DIMENSION
# External:     get_qpaxlen, get_imaxlen
# Local:        NONE
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} MC    -- initial version  	-- 1/91
#               {n} <who> -- <does what> -- <when>
#

include <qpoe.h>
include <imhdr.h>
include <math.h>

#
# GET_QPAXLEN -- read  AXLEN from the qpoe header to determine DIMENSION (image)
#							size
#
#

procedure get_qpaxlen(qp, qphead)

pointer qp			# i: qp file descriptor
pointer qphead			# i: qp header struct
#--
int	qp_geti()

begin
	QP_XDIM(qphead) = qp_geti(qp,"axlen[1]")
	QP_YDIM(qphead) = qp_geti(qp,"axlen[2]")
end


procedure get_imaxlen(im, qphead)

pointer im			# i: qp file descriptor
pointer qphead			# i: qp header struct
#--


begin
	QP_XDIM(qphead) = IM_LEN(im,1) 
	QP_YDIM(qphead) = IM_LEN(im,2) 
end



