# $Header: /home/pros/xray/lib/regions/RCS/regprecheck.x,v 11.0 1997/11/06 16:19:06 prosb Exp $
# $Log: regprecheck.x,v $
# Revision 11.0  1997/11/06 16:19:06  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:26:19  prosb
# General Release 2.4
#
#Revision 8.2  1994/08/19  15:25:10  dennis
#Corrected typos (wrong comment characters) in previous check-in.
#
#Revision 8.1  94/08/19  15:17:42  dennis
#Partially converted to using rg_qpwcsset(), rg_wcsset(), rg_wcsfree() in 
#rgcreate.x.
#
#Revision 8.0  94/06/27  13:44:17  prosb
#General Release 2.3.1
#
#Revision 1.1  94/05/18  18:23:03  dennis
#Initial revision
#
#
# Module:	regprecheck.x
# Project:	PROS -- ROSAT RSDC
# Purpose:	give prompt feedback on region descriptor syntactic or 
#		semantic error
# External:	reg_precheck()
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1994.  You may do anything you like with this
#		file except remove this copyright
# Modified:	{0} dennis  initial version May 1994
#		{n} <who> -- <does what> -- <when>
#

include	<qpset.h>
include	<regparse.h>

#
# REG_PRECHECK -- return true if the region descriptor compiles OK, 
#                  else false
#
#	THIS IS A (KLUDGY) TEMPORARY ROUTINE.
#
#	It is usable only for region descriptors associated with QPOE files.
#
#	User MUST call error() on return of 'false'
#
bool procedure reg_precheck(regdesc, qp, qph, io)

char	regdesc[ARB]		# i: region descriptor
pointer	qp			# i: QPOE file pointer
pointer	qph			# i: QPOE header struct
pointer	io			# i: event list pointer

pointer	sp			# l: stack pointer
##int	block			# l: block factor
pointer	imh			# l: local QPOE header struct pointer
int	err			# l: MWCS setup error flag
int	rdlen			# l: length of region descriptor
pointer	rdbuf			# l: local region descriptor buffer
pointer	plname			# l: (possible) .pl file spec
int	index			# l: char posn of 1st ';' in regdesc
bool	rtn			# l: buffer for return value
pointer	parsing			# l: parsing control structure
bool	bjunk			# l: unneeded return from bool function

##int	qpio_stati()
pointer	qp_loadwcs()
pointer	mw_sctran()
int	rg_ftype()
pointer	rg_open_parser()
bool	rg_objlist_req()
bool	rg_parse()
int	stridx()
int	strlen()

include	"rgwcs.com"
include	"regparse.com"

begin
	call smark (sp)

##	block = qpio_stati(io, QPOE_BLOCKFACTOR)
##	if( block == 0 ){
##	    call printf("block factor is 0: did you setenv the qmfiles?\n")
##	    call error(1, "illegal block factor")
##	}
##	else if( block != 1 )
##	    call printf("\nblock factor not equal to 1 will be ignored\n")

## begin near-copy of rg_qpwcsset() in rgcreate.x
	imh = qph
	err = 0
	ifnoerr ( rg_imwcs = qp_loadwcs(qp) )
	    rg_ctwcs = mw_sctran(rg_imwcs, "world", "logical", 0)
	else
	    err = 1
	if ( err == 1 || rg_imwcs == NULL ) {
	    call eprintf("no WCS in QPOE file\n")
	    imh = NULL
	}
## end near-copy of rg_qpwcsset() in rgcreate.x

	call rg_wcsset(imh)

	rdlen = strlen(regdesc)
	call salloc(rdbuf, rdlen, TY_CHAR)
	call salloc(plname, SZ_PATHNAME, TY_CHAR)
	call strcpy(regdesc, Memc[rdbuf], rdlen)
	index = stridx(";", Memc[rdbuf])
	if( index != 0 )
	    Memc[rdbuf + index - 1] = EOS
	if( rg_ftype(Memc[rdbuf], Memc[plname], SZ_PATHNAME) == 2 )
	    rtn = true
	else {
	    parsing = rg_open_parser()
	    bjunk = rg_objlist_req(parsing)
	    rtn = rg_parse(parsing, regdesc, 0)
	    call rg_close_parser(parsing)
	}

## begin near-copy of rg_wcsfree() in rgcreate.x
	if ( imh != NULL )
	    call mw_close(rg_imwcs)
## end near-copy of rg_wcsfree() in rgcreate.x

	call sfree(sp)
	return (rtn)
end
