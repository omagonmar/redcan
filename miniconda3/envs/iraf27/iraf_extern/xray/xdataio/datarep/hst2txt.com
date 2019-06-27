#$Header: /home/pros/xray/xdataio/datarep/RCS/hst2txt.com,v 11.0 1997/11/06 16:33:58 prosb Exp $
#$Log: hst2txt.com,v $
#Revision 11.0  1997/11/06 16:33:58  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:57:43  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:18:46  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:37:55  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:23:35  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:36:03  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  15:00:31  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:12:18  prosb
#General Release 1.1
#
#Revision 2.1  91/08/01  21:55:53  mo
#MC	8/1/91		No change - restructure
#
#Revision 2.0  91/03/06  23:36:05  pros
#General Release 1.0

# hst2txt common block
#

char	pr_buffer[132]
int	pr_call, pr_loop, pr_ret	# Machine opcodes

common	/h2txt/	pr_call, pr_loop, pr_ret, pr_buffer
