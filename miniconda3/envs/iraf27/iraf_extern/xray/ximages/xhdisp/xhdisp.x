#$Header: /home/pros/xray/ximages/xhdisp/RCS/xhdisp.x,v 11.0 1997/11/06 16:28:57 prosb Exp $
#$Log: xhdisp.x,v $
#Revision 11.0  1997/11/06 16:28:57  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:35:08  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:46:21  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:27:33  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:08:19  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:27:46  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:31:40  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  91/08/02  10:28:12  mo
#ADD RCS comment character
#
#Revision 3.0  91/08/02  01:18:01  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:27:56  pros
#General Release 1.0
#
#
# XHDISP - display history comments in an image or qpoe file
#

include <qpoe.h>
include <ext.h>


procedure t_xhdisp()

char	ifile[SZ_FNAME]			# input file
char	type[SZ_LINE]			# type of history
pointer	fd				# input handle
int	imaccess()			# check for image existence
pointer	immap()				# open an image file
int	qp_access()			# check for qpoe existence
pointer	qp_open()			# open a qpoe file

begin
	# get parameters
	call clgstr("image", ifile, SZ_FNAME)
	call clgstr("type", type, SZ_FNAME)
	# check for a qpoe file
	if( qp_access(ifile, 0) == YES ){
	    # open the qpoe file
	    fd = qp_open(ifile, READ_ONLY, NULL)
	    # display the history
	    call disp_qphistory(fd, type)
	    # close the qpoe file
	    call qp_close(fd)
	}
	# check for a non-qpoe image file
	else if( imaccess(ifile, 0, 0) == YES ){
	    # open the image file
	    fd = immap(ifile, READ_ONLY, NULL)
	    # display the history
	    call disp_imhistory(fd, type)
	    # close the qpoe file
	    call imunmap(fd)
	}
	# oh well ...
	else
	    call error(1, "input qpoe or image file not found")
end
