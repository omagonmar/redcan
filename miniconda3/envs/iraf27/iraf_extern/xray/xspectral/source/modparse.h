#$Header: /home/pros/xray/xspectral/source/RCS/modparse.h,v 11.0 1997/11/06 16:42:55 prosb Exp $
#$Log: modparse.h,v $
#Revision 11.0  1997/11/06 16:42:55  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:30:22  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:33:12  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:56:33  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:51:19  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:45:14  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  18:16:27  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:58:37  prosb
#General Release 1.1
#
#Revision 2.1  91/07/12  16:27:18  prosb
#jso - made spectral.h system wide
#
#Revision 2.0  91/03/06  23:05:30  pros
#General Release 1.0
#
#
# MODPARSE.H -- definitions for spectral model parsing
#

include <spectral.h>
include "ytab.h"

define	YYMAXDEPTH	150			# parser stack length

define	LEN_INST	5			# length of metacode instr.
define  MAX_INST	1024                   # max instructions

define	SZ_SBUF		4096			# size of the string buffer
define  MAX_ARGS        4096                   # max args in a function
define  MAX_CALLS	32                     # max nesting of functions
define  MAX_NESTS       32                     # max nesting of includes
define  NAMEINC		1024                    # inc size of allnames buffer
define  MOD_EXT          ".mod"                 # default region file extension

# Parser stack structure.  The operand value is stored in a VAL field if the
# operand is a constant, else in the associated register.

define	LEN_OPERAND	4			# size of operand structure
define	YYOPLEN		LEN_OPERAND		# for the parser

#the following are returned by lex:
define  O_LBUF          Memi[($1)]           	# line buffer pointer
define	O_VALC		Memc[Memi[($1)]]	# string val (in string buffer)
define	O_VALI		Memi[($1)]		# int value
define	O_VALR		Memr[($1)]		# real value (lower bound)
# the following are returned for a param value:
define  O_LOWER		Memr[($1)+0]		# param's lower bound
define  O_UPPER		Memr[($1)+1]		# param's upper bound
define  O_FIXED		Memi[($1)+2]		# param's fixed/free condition
define  O_LINK		Memi[($1)+3]		# link to another param
# the following are returned by mod_lookup (in lex):
define  O_NAME		Memi[($1)]		# pointer to model name
define  O_CODE		Memi[($1)+1]		# model id
define  O_MINARGS	Memi[($1)+2]		# min args for model
define  O_MAXARGS	Memi[($1)+3]		# max args for model
# the following are used to construct the model stack:
# (mod_setup_model, mod_setup_absorption, mod_setup_list):
define	O_MODEL         Memi[($1)]		# pointer to model struct
define  O_ABSORPTION	Memi[($1)]		# pointer to absorption struct
define	O_LIST		Memi[($1)]		# pointer to model list

# the following functions are defined:
define	MOD_LOG		1
