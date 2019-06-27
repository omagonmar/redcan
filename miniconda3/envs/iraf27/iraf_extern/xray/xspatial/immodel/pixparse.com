#$Header: /home/pros/xray/xspatial/immodel/RCS/pixparse.com,v 11.0 1997/11/06 16:30:26 prosb Exp $
#$Log: pixparse.com,v $
#Revision 11.0  1997/11/06 16:30:26  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:47:16  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:57:39  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:29:52  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:12:10  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:29:40  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  17:31:00  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:28:24  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:17:32  pros
#General Release 1.0
#
# The pixel parser common

pointer	c_x				# pointer to x array
pointer c_y				# pointer to y array
pointer c_cnts				# pointer to intensity array
int	c_npix				# number of elements
int	c_max				# max elements in current size

pointer	c_sbuf				# string buffer
pointer c_nextch			# next char in string buffer

int	c_error				# parser error status
int	c_debug				# debug flag

int	c_tokens			# number of tokens parsed in this expression

common	/pixcom/ c_x, c_y, c_cnts, c_npix, c_max,
	c_sbuf, c_nextch, c_error, c_debug, c_tokens


