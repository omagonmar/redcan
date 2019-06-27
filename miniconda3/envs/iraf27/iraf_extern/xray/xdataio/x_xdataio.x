#$Header: /home/pros/xray/xdataio/RCS/x_xdataio.x,v 11.0 1997/11/06 16:37:45 prosb Exp $
#$Log: x_xdataio.x,v $
#Revision 11.0  1997/11/06 16:37:45  prosb
#General Release 2.5
#
#Revision 9.3  1997/10/03 22:03:08  prosb
#JCC(10/97) - rename qpappend_tsi to qpappend_ftsi.
#
#Revision 9.2  1997/09/15 20:34:35  prosb
#JCC(9/15/97) - Add a new task qpappend_tsi.
#
#Revision 9.0  1995/11/16 18:57:15  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:18:00  prosb
#General Release 2.3.1
#
#Revision 7.1  94/05/12  17:49:18  janet
#added upqpoerdf as a macro, and qpgapmap moved in from xproto.
#
#Revision 7.0  93/12/28  16:05:01  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:22:48  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:33:08  prosb
#General Release 2.1
#
#Revision 4.1  92/10/21  16:13:54  mo
#MC	10/21/92	Add new task
#
#Revision 4.0  92/04/27  14:52:50  prosb
#General Release 2.0:  April 1992
#
#Revision 3.3  92/04/07  15:29:39  jmoran
#JMORAN no changes
#
#Revision 3.2  92/04/07  15:00:40  jmoran
#JMORAN added upqpoe210
#
#Revision 3.1  92/02/06  18:06:52  mo
#PROS new task addition
#
#Revision 3.0  91/08/02  01:11:52  prosb
#General Release 1.1
#
#Revision 1.1  91/07/21  19:22:20  mo
#Initial revision
#
#Revision 2.0  91/03/06  23:40:30  pros
#General Release 1.0
#
task fits2qp = t_fits2qp,
     hkfilter = t_hkfilter,
     im2bin  = t_im2bin,
     mkhkscr = t_mkhkscr,
     qpaddaux = t_qpaddaux,
     qpappend = t_qpappend,
     qpappend_ftsi = t_qpappend_ftsi,
     qpgapmap = t_qpgapmap,
     qp2fits = t_qp2fits,
     mperfits = t_mperfits,
     datarep = t_datarep,
     upimgrdf = t_upimgrdf,
     upqp2rdf = t_upqpoerdf
