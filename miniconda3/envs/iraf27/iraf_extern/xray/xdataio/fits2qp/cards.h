#$Header: /home/pros/xray/xdataio/fits2qp/RCS/cards.h,v 11.0 1997/11/06 16:34:25 prosb Exp $
#$Log: cards.h,v $
#Revision 11.0  1997/11/06 16:34:25  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:58:36  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:20:09  prosb
#General Release 2.3.1
#
#Revision 7.1  94/02/25  11:19:18  mo
#MC	2/25/94		Give CARDVSTR it's own non-equivalenced space
#			so that alloced pointer does not get overwritten
#
#Revision 7.0  93/12/27  18:39:38  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:24:19  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:36:33  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  15:01:18  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:13:53  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:26:14  pros
#General Release 1.0
#
#
# CARDS.H
#

# data types, not found in IRAF, but returned by nextcard()
define TY_VOID		51
define TY_GUESS		52

# size of card record structure
define SZ_CARDINFO	24
# define the card record structure, returned by nextcard()
define CARDNA		Memi[($1) + 0]		# pointer to translated name
define CARDTY		Memi[($1) + 1]		# datatype of card
define CARDID		Memi[($1) + 2]		# card "action code"
define CARDCO		Memi[($1) + 3]		# pointer to comment string
#  The pointer to strings needs a unique space, since the pointer 
#	gets alloced and can't be lost
define CARDVSTR		Memi[($1) + 5]		# pointer to string

#  Skip some space so the following 'equivalences' can be aligned
define CARDVB		Memb[($1) + 8]		# boolean card value
define CARDVS		Mems[P2S(($1) + 8)]	# short card value
define CARDVI		Memi[($1) + 8]		# int card value
define CARDVL		Meml[($1) + 8]		# long card value
define CARDVR		Memr[($1) + 8]		# real card value
define CARDVD		Memd[P2D(($1) + 8)]	# double card value
define CARDVX		Memd[P2X(($1) + 8)]	# double card value
#define CARDVSTR	Memi[($1) + 8]		# pointer to string

# internal to nextcard() routines
define SZ_SYM		12			# returned by cad lookup
define SZ_CARDNA	32			# size of card name string
define SZ_CARDVSTR	72			# size of card value string



# internal to the card patterns
define SZ_PATTERN	20

define	PATTXL		Memi[($1) + 0]
define	PATTTY		Memi[($1) + 1]
define	PATTID		Memi[($1) + 2]
define	PATTNX		Memi[($1) + 3]
define  PATTNA		Memi[($1) + 4]
