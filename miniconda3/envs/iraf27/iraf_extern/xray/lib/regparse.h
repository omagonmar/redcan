#$Header: /home/pros/xray/lib/RCS/regparse.h,v 11.0 1997/11/06 16:25:36 prosb Exp $
#$Log: regparse.h,v $
#Revision 11.0  1997/11/06 16:25:36  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:25:38  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:43:20  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:22:19  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:37:08  prosb
#General Release 2.2
#
#Revision 5.1  93/04/26  23:28:44  dennis
#Regions system rewrite.
#
#Revision 5.0  92/10/29  21:23:10  prosb
#General Release 2.1
#
#Revision 4.2  92/09/02  02:33:27  dennis
#Increased SZ_REGINPUTLINE from SZ_LINE to (3 * SZ_LINE); defined new 
#symbolic constants SZ_REGOUTPUTLINE and SZ_2PATHNAMESPLUS
#
#Revision 4.1  92/08/07  17:12:13  dennis
#Defined new symbolic constants SZ_REGINPUTLINE and SZ_NOTELINE
#for region descriptor line lengths.
#
#Revision 4.0  92/04/27  14:07:01  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  91/08/02  09:25:54  mo
#Add the comment character for RCS
#
# * Revision 3.0  91/08/02  00:46:51  prosb
# * General Release 1.1
# * 
#Revision 2.0  91/03/07  00:14:45  pros
#General Release 1.0
#
#
# REGPARSE.H -- definitions for region parsing
#

include "regions.h"

#---------------------------------------------------------------------------

define  MAX_NESTS       32			# max nesting of region 
						# 	descriptor files

# The region descriptor buffer of size SZ_REGINPUTLINE may contain 
#  abbreviations, which will cause the descriptor to expand when it is 
#  rewritten into a buffer of size SZ_REGOUTPUTLINE.  But what is written 
#  out from SZ_REGOUTPUTLINE may subsequently be read back in to 
#  SZ_REGINPUTLINE (e.g., in rg_plfile()'s call to rg_parse()), so 
#  SZ_REGINPUTLINE needs to be as long as SZ_REGOUTPUTLINE.  (I expect later 
#  to replace them with a single constant, SZ_REGDESCLINE, of size 1022, 
#  with checks in place to notify the user when a line is too long.)  The 
#  maximum allowed value for SZ_REGOUTPUTLINE is 1022; enc_plhead()'s 
#  sprintf(..., "\t\t%s") determines that.

define  SZ_REGINPUTLINE (3 * SZ_LINE)	# region descriptor line limit
define  SZ_REGOUTPUTLINE (3 * SZ_LINE)	# expanded descriptor line limit
define  SZ_ONEREGDESC	70		# width of table column for 
					#  single-region descriptor

define	SZ_2PATHNAMESPLUS (3 * SZ_PATHNAME)	# for text incl. 2 filespecs

define	SZ_SBUF		4096			# size of string scratch buffer
define  MAX_ARGS        4096			# max args for a shape
define  NAMEINC		1024                    # inc size of allnames buffer
define  REGEXT          ".reg"			# default region file extension

#---------------------------------------------------------------------------

# Parsing control structure

define	N_RGPARSE_OPTIONS	5

# The options must be numbered consecutively from 1 through N_RGPARSE_OPTIONS,
#  for RGPARSE_OPT() to work correctly

define	EXPDESC		1
define	OBJLIST		2
define	NEWCOORDS	3
define	ONEREGNOTES	4
define	OPENMASK	5

define	RGPARSE_OPT	Memi[($2)+($1)-1]	# (opt #, request struct ptr)


# Parsing option structures

#				------------

define	LEN_EXPDESC_STRUCT	2
define	EXPDESCPTR	Memi[RGPARSE_OPT(EXPDESC,($1))]		# receives 
			# pointer to expanded region descriptor
define	EXPDESCBUF	Memc[Memi[RGPARSE_OPT(EXPDESC,($1))]]	# receives 
			# expanded region descriptor
define	EXPDESCLPTR	Memi[RGPARSE_OPT(EXPDESC,($1))+1]	# used to 
			# point to buffer for single expanded command
define	EXPDESCLBUF	Memc[Memi[RGPARSE_OPT(EXPDESC,($1))+1]]	# buffer for 
			# single expanded command

#				------------

define	LEN_OBJLIST_STRUCT	2
define	OBJLISTPTR	Memi[RGPARSE_OPT(OBJLIST,($1))]		# receives 
			# pointer to list of object structures
define	LASTOBJPTR	Memi[RGPARSE_OPT(OBJLIST,($1))+1]	# used to 
			# point to last object in list, to know where to put 
			# the next one

#				------------

define	LEN_NEWCOORDS_STRUCT	4
define	SELCOORDS	Memi[RGPARSE_OPT(NEWCOORDS,($1))]	# select 
							# target system
define	MWCSDESC	Memi[RGPARSE_OPT(NEWCOORDS,($1))+1]	# pointer to 
							# MWCS descriptor
define	NEWCOORDSPTR	Memi[RGPARSE_OPT(NEWCOORDS,($1))+2]
			# receives pointer to transformed region descriptor
define	NEWCOORDSBUF	Memc[Memi[RGPARSE_OPT(NEWCOORDS,($1))+2]
			# receives transformed region descriptor
define	NEWCOORDSLPTR	Memi[RGPARSE_OPT(NEWCOORDS,($1))+3]
			# used to point to buffer for single transformed cmd
define	NEWCOORDSLBUF	Memc[Memi[RGPARSE_OPT(NEWCOORDS,($1))+3]]
			# buffer for single transformed command

#				------------

define	LEN_ONEREGNOTES_STRUCT	3
define	ONEREGNOTESPTR	Memi[RGPARSE_OPT(ONEREGNOTES,($1))]	# receives 
			# pointer to list of structures, each containing, for 
			# one region: (1) a pointer to a descriptor string 
			# (in operator-postfix notation, and possibly 
			# truncated (at SZ_ONEREGDESC)); and (2) begin and end 
			# values of angle and/or radius for any slice and/or 
			# any annulus derived from an accelerator
define	LASTONEREGNOTEPTR Memi[RGPARSE_OPT(ONEREGNOTES,($1))+1]	# used to 
			# point to last note in list, to know where to put 
			# the next one
define	ANNPIEFLAGS	Memi[RGPARSE_OPT(ONEREGNOTES,($1))+2]	# receives 
			# flags indicating whether any annulus keyword and/or 
			# any pie keyword appears in the region descriptor tree

define	PIEFLAG		1	# or-able ANNPIEFLAGS() value:  PIE appears
define	ANNFLAG		2	# or-able ANNPIEFLAGS() value:  ANNULUS appears

#				------------

define	LEN_OPENMASK_STRUCT	3
define	SELPLPM		Memi[RGPARSE_OPT(OPENMASK,($1))] # select PL or PM
define	MASKPTR		Memi[RGPARSE_OPT(OPENMASK,($1))+1]	# receives 
						# pointer to PL or PM struct
define	REGNUM		Memi[RGPARSE_OPT(OPENMASK,($1))+2]	# next 
						# region number for mask

define	MSKTY_PL	0	# value for SELPLPM(): .pl file
define	MSKTY_PM	1	# value for SELPLPM(): .pm file

#---------------------------------------------------------------------------

define	YYMAXDEPTH	150			# parser stack length

# Structure for semantic value associated with a symbol.
# The parser-maintained value stack is a stack of such structures.
# When rg_yyparse() (which is derived from iraf lib file yaccpar.x) calls 
#  rg_lex() for a new lookahead token, rg_lex() buffers any value(s) 
#  associated with the token (beyond the identity of the token itself) in 
#  the structure (of this type) pointed to by yylval; yylval is a parameter 
#  in rg_lex(), bound by an argument from rg_yyparse(); the argument is a 
#  local variable (also called yylval) in rg_yyparse().  As long as the token 
#  is the lookahead token, its associated value remains buffered in this 
#  structure pointed to by yylval.  Then on a shift action rg_yyparse() 
#  pushes the yylval structure onto the value stack.  (Some tokens, like ID, 
#  '(', and others, don't need to do anything but identify themselves, so 
#  they don't put any data into their yylval structures.)
# During a reduce action, rg_yyparse() executes the code associated with the 
#  effective syntactic production.  That code buffers the value associated 
#  with the nonterminal symbol that is the left-hand side of the production 
#  in the structure (of this type) pointed to by yyval; yyval is a local 
#  variable in rg_yyparse(); it is represented in the yacc specification by 
#  the special symbol "$$".  Then in the goto action at the end of the reduce 
#  action, rg_yyparse() pushes the yyval structure onto the value stack.  
#  (Again, many nonterminal symbols, like expr, need not pass any data via 
#  yyval structures; labeled common variables accumulate any needed 
#  information developed in reductions to these symbols.  At present only 
#  iflag and reg nonterminal symbols use their associated yyval structures.)

define	YYOPLEN		2	# size of operand (semantic value) structure; 
				# xyacc requires it to be defined as YYOPLEN

define	O_VALR	Memr[($1)]	# real value (for NUMERAL, EQEQUIX)
define	O_VALI	Memi[($1)]	# int value (for '+', '-', iflag, and 
				#  keyword index for REGION, CLEVELS, 
				#  COORDS, EQUATO, PIXSYS, REFFIL)

define  O_NTYPE	Memi[($1)+1]	# type of NUMERAL (e.g., TY_REAL, TY_DEG, etc.)
define	O_ECODE	Memi[($1)+1]	# equinox code (for EQEQUIX)
define	O_KCODE	Memi[($1)+1]	# keyword code (for COORDS (& REGION, ...))
define  O_FNPTR	Memi[($1)+1]	# ptr to file spec (for REGFIL, REFFIL, PIXSYS)
define	O_FNBUF	Memc[Memi[($1)+1]]	# filespec[] pointed to by O_LBUF()
define  O_REG	Memi[($1)+1]	# pointer to reg structure (for reg)

#---------------------------------------------------------------------------

# exclude and include regions (for O_VALI() field in semantic value structure 
#  for '-', '+' tokens and for iflag nonterminal symbol)
#
define EXCLUDE		0
define INCLUDE		1

#---------------------------------------------------------------------------

# NUMERAL types (for O_NTYPE() field in semantic value structure)
#
define	TY_INC		1001	# 'n=<num>' syntax
define	TY_DEG		1002	# degrees
define	TY_RAD		1003	# radians
define	TY_PIX		1004	# pixels
define	TY_HMS		1005	# hours, minutes, seconds
define	TY_MIN		1006	# minutes
define	TY_SEC		1007	# seconds

#---------------------------------------------------------------------------

# reg structure:  details of a simple or multi region specification
#                 (allocated and initially filled at time of reduction to 
#                 reg symbol (i.e., in rg_region())
#                 (O_REG() field of a reg symbol's semantic value structure 
#                 points to a reg structure)
#
define	LEN_REG		4		# size of a reg structure

define	R_CODE		Memi[($1)]	# shape name code
define  R_ARGC		Memi[($1)+1]	# number of args: (1) in initial spec; 
					#  (2) after accelerators expanded; 
					#  (3) for single shape during 
					#  manifestation of a multi
define  R_ARGV		Memi[($1)+2]	# pointer to processed arg list/set
					#  (points in succession to each set 
					#  of args defining a single shape 
					#  during manifestation of a multi; 
					#  otherwise to start of arg list)
define  R_TYPE		Memi[($1)+3]	# TY_REGION | TY_SLICES | TY_ANNULI

#---------------------------------------------------------------------------

# reg types, for multiple-region control of the virtual CPU
#
define TY_REGION	2002		# normal region
define TY_ANNULI	2003		# multi-annuli region
define TY_SLICES	2004		# multi-slice region

#---------------------------------------------------------------------------

# control structure for multiple slices or annuli (filled by rg_newop(), on
#  reduction of reg to expr; used by rg_execute(), to control the virtual CPU)
#
define 	LEN_MULTI	4

define	M_ITER		Memi[($1)]		# number of iterations
define	M_INST		Memi[($1)+1]		# inst whose argv will vary
define	M_BASE		Memi[($1)+2]		# base pointer to argv
define	M_INC		Memi[($1)+3]		# increment for argv pointer

#---------------------------------------------------------------------------

# virtual CPU program

define  MAX_INST	1024			# max instructions
define	LEN_INST	2			# length of metacode instr.

# macros used when compiling instructions
#
define	INST		rg_metacode[1,$1]	# instruction
define	ARG1		rg_metacode[2,$1]	# argument

# virtual CPU instruction opcodes.
#
define  OP_RTN          0	# return
define  OP_NEW		1	# create a new temp plio file
define  OP_MERGE	2	# merge two temp plio files
define  OP_FLUSH	3	# flush (paint) a temp file to real file
define  OP_UNSET	4	# unary not performed on temp plio

#---------------------------------------------------------------------------

# Structure for a virtual CPU program (pointer), its controlling multiple 
#  region structures, and its INCLUDE/EXCLUDE flag.  Combined with the 
#  program and the reg structures it points to, this provides complete 
#  information from a single compiled region command.
# The OBJLIST option returns a linked list of these structures, one for each 
#  compiled command.  To traverse this list, initialize objptr (e.g.) to 
#  OBJLISTPTR(parsing) (where parsing points to the parsing control 
#  structure), and get each next object by setting objptr = V_NEXT(objptr).

define	LEN_VOBJ	4+2*LEN_MULTI	# size of virtual CPU pgm obj struct

define	V_INCL		Memi[($1)]	# INCLUDE flag:  YES or NO
define	V_SLICES	(($1)+1)	# pointer to multiple slices struct
					# M_ITER(V_SLICES()): no. of iterations
					# M_INST(V_SLICES()): inst to vary
					# M_BASE(V_SLICES()): argv base ptr
					# M_INC(V_SLICES()): argv ptr inc
define	V_ANNULI	(($1)+1+LEN_MULTI)
					# pointer to multiple annuli struct
					# M_ITER(V_ANNULI()): no. of iterations
					# M_INST(V_ANNULI()): inst to vary
					# M_BASE(V_ANNULI()): argv base ptr
					# M_INC(V_ANNULI()): argv ptr inc
define	V_NINSTS	Memi[($1)+1+2*LEN_MULTI]
					# number of metacode instructions
define	V_METAPTR	Memi[($1)+2+2*LEN_MULTI]
					# pointer to virtual CPU program
define	V_METABUF	Memi[Memi[($1)+2+2*LEN_MULTI]]
					# virtual CPU program
					# (don't use INST, ARG1 with this)
define	V_INST		Memi[Memi[($2)+2+2*LEN_MULTI]+(($1)-1)*LEN_INST]
					# V_INST(vpc, objptr): inst #vpc
define	V_ARG1		Memi[Memi[($2)+2+2*LEN_MULTI]+(($1)-1)*LEN_INST+1]
					# V_ARG1(vpc, objptr): inst #vpc's arg
define	V_NEXT		Memi[($1)+3+2*LEN_MULTI]
					# pointer to next object structure

#---------------------------------------------------------------------------

# Structure for "note" on a single region.  The note is data for some of 
#  the columns in a table produced by imcnts.
# The data are: (1) pointer to a descriptor string, in operator-postfix 
#  notation, and possibly truncated at SZ_ONEREGDESC; and (2) begin and end 
#  values of angle and/or radius for any slice and/or any annulus derived 
#  from an accelerator.
# The ONEREGNOTES option returns a linked list of these structures, one for 
#  each INCLUDE region defined by the region descriptor.  If parsing points 
#  to the parsing control structure, ONEREGNOTESPTR(parsing) points to the 
#  list of these structures.

define	LEN_ONEREGNOTE	6		# size of 1-region note structure

define	ORN_DESCPTR	Memi[($1)]	# pointer to the descriptor string
define	ORN_DESCBUF	Memc[Memi[($1)]]	# the descriptor string
define	ORN_BEGANN	Memr[($1)+1]	# annulus inner radius
define	ORN_ENDANN	Memr[($1)+2]	# annulus outer radius
define	ORN_BEGPIE	Memr[($1)+3]	# pie slice beginning angle
define	ORN_ENDPIE	Memr[($1)+4]	# pie slice ending angle
define	ORN_NEXT	Memi[($1)+5]	# pointer to next region's note

#---------------------------------------------------------------------------
