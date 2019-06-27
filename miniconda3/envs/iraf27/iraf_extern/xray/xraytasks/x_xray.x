#$Header: /home/pros/xray/xraytasks/RCS/x_xray.x,v 11.0 1997/11/06 16:46:34 prosb Exp $
#$Log: x_xray.x,v $
#Revision 11.0  1997/11/06 16:46:34  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:37:13  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:46:43  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:08:27  prosb
#General Release 2.3
#
#Revision 6.1  93/12/22  17:19:40  mo
#MC	12/22/93	add task
#
#Revision 6.0  93/05/24  17:03:15  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  23:08:49  prosb
#General Release 2.1
#
#Revision 4.2  92/10/23  10:11:43  mo
#MC	add task
#
#Revision 4.1  92/09/14  13:21:00  mo
#MC		9/14/92		Add new task name imgclust
#
#Revision 4.0  92/04/27  15:44:08  prosb
#General Release 2.0:  April 1992
#
#Revision 3.3  92/04/23  15:41:16  mo
#MC	4/23/92		Add new task
#
#Revision 3.2  91/10/11  09:16:17  jmoran
#Added clobbername and finalname tasks
#
#Revision 3.1  91/08/02  09:43:38  mo
#ADD RCS comment character
#
#Revision 3.0  91/08/02  01:26:13  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:13:34  pros
#General Release 1.0
#
# Executables for the spectral package.

task    rtname        = t_rootname,
	clobname      = t_clobbername,
	fnlname	      = t_finalname,
	getdevdim     = t_getdevdim,
	imgimage      = t_imgimage,
	imgclust      = t_imgclust,
        keychk        = t_keychk
