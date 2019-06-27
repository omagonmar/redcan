#$Header: /home/pros/xray/ximages/RCS/prntdoc.cl,v 11.0 1997/11/06 16:29:01 prosb Exp $
#$Log: prntdoc.cl,v $
#Revision 11.0  1997/11/06 16:29:01  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:32:40  prosb
#General Release 2.4
#
;;; Revision 8.0  1994/06/27  14:42:10  prosb
;;; General Release 2.3.1
;;;
;;; Revision 7.0  93/12/27  18:25:45  prosb
;;; General Release 2.3
;;; 
;;; Revision 6.0  93/05/24  16:03:48  prosb
;;; General Release 2.2
;;; 
;;; Revision 5.0  92/10/29  21:26:09  prosb
;;; General Release 2.1
;;; 
;;; Revision 4.0  92/04/27  14:14:23  prosb
;;; General Release 2.0:  April 1992
;;; 
;;; Revision 3.0  91/08/02  01:15:27  prosb
;;; General Release 1.1
;;; 
#Revision 2.0  91/03/06  23:24:06  pros
#General Release 1.0
#
procedure  prntdoc (subj)

	string subj	{prompt="Subject: "}

begin
	string topic, tapes, rfits

	print ("Current list of topics: tapes, rfits")

	topic = subj
	tapes = "tapes"
	rfits = "rfits"

	if( topic == tapes )  {
		!ptroff -ms /iraf/local/tasks/xray/doc/tapememo
		}

	if( topic == rfits )  {
		!latex /iraf/local/tasks/xray/doc/rfits_la.tex
		!pstex rfits_la.dvi
		}
end


