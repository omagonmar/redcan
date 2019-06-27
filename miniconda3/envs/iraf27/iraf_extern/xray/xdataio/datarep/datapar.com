#$Header: /home/pros/xray/xdataio/datarep/RCS/datapar.com,v 11.0 1997/11/06 16:33:52 prosb Exp $
#$Log: datapar.com,v $
#Revision 11.0  1997/11/06 16:33:52  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:57:28  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:18:24  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:37:33  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:23:10  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:35:43  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:59:59  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:12:09  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:35:35  pros
#General Release 1.0
#
# datapar common block
#


pointer	textstack	# pointer to code stack
pointer	filestack	# pointer to the file stack
pointer	symbols		# pointer to the symbol table

int	op_call, op_loop, op_ret	# Machine opcodes

int	line

common	/datapar/	textstack, filestack, symbols,
			op_call, op_loop, op_ret,
			line

