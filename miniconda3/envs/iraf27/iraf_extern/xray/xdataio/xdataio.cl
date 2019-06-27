#$Header: /home/pros/xray/xdataio/RCS/xdataio.cl,v 11.0 1997/11/06 16:35:53 prosb Exp $
#$Log: xdataio.cl,v $
#Revision 11.0  1997/11/06 16:35:53  prosb
#General Release 2.5
#
#Revision 9.4  1997/10/03 22:04:21  prosb
#JCC(10/97) - rename qpappend_tsi to qpappend_ftsi.
#
#Revision 9.3  1997/09/15 20:36:07  prosb
#JCC(9/15/97) - Add a new task qpappend_tsi.
#
#Revision 9.2  1997/07/30 17:49:06  prosb
#Add rarc2pros_c and _rdfarc2pros_c for capital filename (eg. *_BAS.FITS)
#
#Revision 9.0  1995/11/16 18:57:17  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:18:03  prosb
#General Release 2.3.1
#
#Revision 7.3  94/05/12  17:50:57  janet
#redefined upqpoerdf as a macro task.
#
#Revision 7.2  94/04/06  13:57:01  janet
#jd - added qpgapmap
#
#Revision 7.1  94/03/17  10:16:15  prosb
#KRM - added efits2qp 
#
#Revision 7.0  93/12/27  18:44:09  prosb
#General Release 2.3
#
#Revision 6.3  93/12/21  14:54:52  mo
#MC	12/22/93		Add errmsg* scripts
#
#Revision 6.2  93/12/15  12:05:27  mo
#MC	12/15/93	Add new hidden tasks, and qpappend
#
#Revision 6.1  93/10/04  12:18:14  dvs
#Added subpackage eincdrom (moved from einbb).
#
#Revision 6.0  93/05/24  16:22:51  prosb
#General Release 2.2
#
#Revision 5.2  93/05/20  09:31:42  mo
#MC	5/20/93		Add new tasks
#
#Revision 5.1  93/01/20  09:39:31  mo
#MC	1/20/93		Add rarc2pros task
#
#Revision 5.0  92/10/29  22:33:11  prosb
#General Release 2.1
#
#Revision 4.2  92/10/21  16:12:00  mo
#MC	10/21/92		Move EINBB and ROSBB
#
#Revision 4.1  92/06/16  16:59:31  mo
#MC	6/16/92		Update the warning message to reflect that
#			only a TABLES installation is checked for
#
#Revision 4.0  92/04/27  14:52:55  prosb
#General Release 2.0:  April 1992
#
#Revision 3.2  92/04/24  14:36:53  mo
#MC	4/24/92		Remove STSDAS load
#
#Revision 3.1  92/02/06  18:03:37  mo
#MC	2/5/92		Add qp2fits task
#
#Revision 3.0  91/08/02  01:11:52  prosb
#General Release 1.1
#
#Revision 1.2  91/07/25  11:22:06  mo
#MC	7/25/91		Add the rfits2pros script task
#
#Revision 1.1  91/07/21  19:20:26  mo
#Initial revision
#
#Revision 2.0  91/03/07  02:17:40  pros
#General Release 1.0
#
# Load necessary packages

print("")
if ( !defpac( "ximages" ))  
{
       ximages
}
;

if ( deftask("tables")) {
    if ( !defpac( "tables" )) {
	tables
    }
}
else {
    print("WARNING: No TABLES installation found!" )
    print("An TABLES installation is required for some tasks" )
}
;

package	xdataio

task	datarep         = "xdataio$x_xdataio.e"
task    hkfilter        = "xdataio$x_xdataio.e"
task    fits2qp	        = "xdataio$x_xdataio.e"
task    _im2bin		= "xdataio$x_xdataio.e"
task    mkhkscr         = "xdataio$x_xdataio.e"
task    mperfits	= "xdataio$x_xdataio.e"
task    qp2fits	        = "xdataio$x_xdataio.e"
task	qpaddaux        = "xdataio$x_xdataio.e"
task    qpappend        = "xdataio$x_xdataio.e"
task    qpappend_ftsi   = "xdataio$x_xdataio.e"
task    qpgapmap        = "xdataio$x_xdataio.e"
task    upimgrdf        = "xdataio$x_xdataio.e"
task    _upqp2rdf       = "xdataio$x_xdataio.e"

task	rfits2pros      = "xdataio$rfits2pros.cl"
task	_rfits2pros0    = "xdataio$_rfits2pros0.cl"
task	_rarc2pros0     = "xdataio$_rarc2pros0.cl"
task	_rdffits2pros   = "xdataio$_rdffits2pros.cl"
task	_rdfarc2pros    = "xdataio$_rdfarc2pros.cl"
task	_rdfrall        = "xdataio$_rdfrall.cl"
task	_errmsg         = "xdataio$_errmsg.cl"
task	_errmsg1        = "xdataio$_errmsg1.cl"
task	_errmsg2        = "xdataio$_errmsg2.cl"
task 	efits2qp	= "xdataio$efits2qp.cl"
task	rarc2pros       = "xdataio$rarc2pros.cl"
task	upqpoerdf       = "xdataio$upqpoerdf.cl"
task	xrfits          = "xdataio$xrfits.cl"
task	xwfits          = "xdataio$xwfits.cl"

task 	eincdrom.pkg	= "eincdrom$eincdrom.cl"

task    rarc2pros_c     = "xdataio$rarc2pros_c.cl"
task    _rdfarc2pros_c  = "xdataio$_rdfarc2pros_c.cl"  

#  Print the opening banner.
if(motd)
type xdataio$xdataio_motd
;

clbye()
