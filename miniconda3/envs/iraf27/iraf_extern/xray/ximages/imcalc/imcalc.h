#$Header: /home/pros/xray/ximages/imcalc/RCS/imcalc.h,v 11.0 1997/11/06 16:27:26 prosb Exp $
#$Log: imcalc.h,v $
#Revision 11.0  1997/11/06 16:27:26  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:33:42  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:43:58  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:23:52  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:05:42  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:24:30  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  17:27:50  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:16:44  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:31:21  pros
#General Release 1.0
#
#
# IMCALC.H -- IMCALC definitions.
#

include <imhdr.h>

define	YYMAXDEPTH	 150			# parser stack length
define	MAX_REGISTERS	 200			# max operand registers
define	MAX_IMAGES	 50			# max images in an expr
define	SZ_SBUF		 1024			# size of the string buffer
define  MAX_CALLS        32                     # max function calls
define  MAX_ARGS         32                     # max args in a function
define	LEN_INSTRUCTION	 5			# length of metacode instr.
define  MAX_INSTRUCTIONS 512                    # max instructions

#define	S2C		((($1)-1)*SZ_STRUCT+1)	# struct ptr to char ptr
#define	S2D		((($1)-1)*SZ_STRUCT/SZ_DOUBLE+1)	# to double
#define	S2X		((($1)-1)*SZ_STRUCT/SZ_COMPLEX+1)	# to complex

define INST		c_metacode[1,$1]	# instruction
define ARG1		c_metacode[2,$1]	# arguments ...
define ARG2		c_metacode[3,$1]
define ARG3		c_metacode[4,$1]
define ARG4		c_metacode[5,$1]

# Parser stack structure.  The operand value is stored in a VAL field if the
# operand is a constant, else in the associated register.  Be sure to keep
# the VAL field at an offset aligned to SZ_DOUBLE.

define	LEN_OPERAND	6			# size of operand structure
define	YYOPLEN		LEN_OPERAND		# for the parser

define	O_TYPE		Memi[($1)]		# type of constant, if any
define	O_REGISTER	Memi[($1)+1]		# register pointer, if any
define	O_LBUF		Memi[($1)+4]		# line buffer pointer, if any
define	O_VALB		Memi[($1)+4]		# bool value (stored as int)
define	O_VALC		Memc[Memi[($1)+4]]	# string val (in string buffer)
define	O_VALS		Memi[($1)+4]		# short value (stored as int)
define	O_VALI		Memi[($1)+4]		# int value
define	O_VALL		Meml[($1)+4]		# long value
define	O_VALR		Memr[($1)+4]		# real value
define	O_VALD		Memd[P2D(($1)+4)]	# double value
define	O_VALX		Memx[P2X(($1)+4)]	# complex value


# Register structure.

define	LEN_REGISTER	6			# size of a register
define	R_REGPTR	((($2)-1)*LEN_REGISTER+($1))

define	R_TYPE  	Memi[($1)]		# datatype of register
define	R_LENGTH	Memi[($1)+1]		# length of vector value
                                                # 0 => const, >0 => vector
define	R_LBUF		Memi[($1)+4]		# line buffer pointer, if any
define	R_VALB		Memi[($1)+4]		# bool value (stored as int)
define	R_VALS		Memi[($1)+4]		# short value (stored as int)
define	R_VALI		Memi[($1)+4]		# int value
define	R_VALL		Meml[($1)+4]		# long value
define	R_VALR		Memr[($1)+4]		# real value
define	R_VALD		Memd[P2D(($1)+4)]	# double value
define	R_VALX		Memx[P2X(($1)+4)]	# complex value

# Image descriptor structure.

define	LEN_IMAGE	(5+(IM_MAXDIM*SZ_LONG)+(SZ_FNAME*SZ_CHAR))
define	I_IMPTR		((($2)-1)*LEN_IMAGE+($1))

define	I_IM		Memi[$1]		# IMIO image descriptor
define	I_LBUF		Memi[$1+1]		# last line buffer
define	I_PIXTYPE	Memi[$1+2]		# pixel datatype
define	I_LINELEN	Memi[$1+3]		# line length
define	I_ATEOF		Memi[$1+4]		# positioned to EOF
define	I_V		Meml[$1+5]		# next line vector
define  I_NAME          Memc[P2C($1+5+(IM_MAXDIM*SZ_LONG))]    # file name

# Instruction opcodes.

define  OP_RTN          0
define	OP_LOAD		1
define	OP_STORE	2
define	OP_BNEOF	3
define	OP_SELECT	4
define	OP_CALL		5
define	OP_CHT		6
define	OP_NEG		7
define	OP_ADD		8
define	OP_SUB		9
define	OP_MUL		10
define	OP_DIV		11
define	OP_POW		12
define	OP_BNOT		13
define	OP_BAND		14
define	OP_BOR		15
define  OP_BXOR         16
define	OP_LT		17
define	OP_GT		18
define	OP_LE		19
define	OP_GE		20
define	OP_EQ		21
define	OP_NE		22
define	OP_LNOT		23
define	OP_LAND		24
define	OP_LOR		25
define  OP_PRINT        26
define  OP_BEOF         27
