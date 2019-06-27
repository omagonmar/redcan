#$Header: /home/pros/xray/ximages/xhadd/RCS/xhadd.x,v 11.0 1997/11/06 16:28:54 prosb Exp $
#$Log: xhadd.x,v $
#Revision 11.0  1997/11/06 16:28:54  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:35:04  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:46:14  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:27:27  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:08:12  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:27:40  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:31:31  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:17:57  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:27:53  pros
#General Release 1.0
#
#
# XHADD - add a history comment to an image or qpoe file
#

include <qpoe.h>
include <ext.h>


procedure t_xhadd()

char	ifile[SZ_FNAME]			# input file
char	type[SZ_LINE]			# type of history
char	task[SZ_LINE]			# task name
char	hist[SZ_LINE]			# history line
int	display				# display level
int	clgeti()			# get cl int
pointer	fd				# input handle
int	imaccess()			# check for image existence
pointer	immap()				# open an image file
int	qp_access()			# check for qpoe existence
pointer	qp_open()			# open a qpoe file

begin
	# get parameters
	call clgstr("image", ifile, SZ_FNAME)
	call clgstr("type", type, SZ_FNAME)
	call clgstr("task", task, SZ_FNAME)
	call clgstr("history", hist, SZ_LINE)
	display = clgeti("display")
	# check for a qpoe file
	if( qp_access(ifile, 0) == YES ){
	    # open the qpoe file
	    fd = qp_open(ifile, READ_WRITE, NULL)
	    # add the history record
	    call put_qphistory(fd, task, hist, type)
	    # display, if necessary
	    if( display ==1 )
	        call disp_qphistory(fd, type)
	    else if( display >1 )
		call disp_qphistory(fd, "")
	    # close the qpoe file
	    call qp_close(fd)
	}
	# check for a non-qpoe image file
	else if( imaccess(ifile, 0, 0) == YES ){
	    # open the image file
	    fd = immap(ifile, READ_WRITE, NULL)
	    # add the history record
	    call put_imhistory(fd, task, hist, type)
	    # display, if necessary
	    if( display ==1 )
	        call disp_imhistory(fd, type)
	    else if( display >1 )
		call disp_imhistory(fd, "")
	    # close the image file
	    call imunmap(fd)
	}
	# oh well ...
	else
	    call error(1, "input qpoe or image file not found")
end
