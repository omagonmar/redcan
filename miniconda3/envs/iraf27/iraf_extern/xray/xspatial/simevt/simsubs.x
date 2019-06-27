# JCC(5/5/98) - change YES/NO(int) to TRUE/FALSE(bool) for linux.
#
# Module:       simsubs.x
# Project:	PROS -- ROSAT RSDC
# Purpose:	General purpose routines for simevt.x program
# Description:	includes subroutines qpfill, init_stab, get_srcinfo,
#		pr_srcinfo, pr_qpinfo, mk_hdr
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1994.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} KRM -- initial version -- 8/94
#
# -----------------------------------------------------------------------

include "simevt.h"
include <qpoe.h>
include <tbset.h>
include <coords.h>
include <fset.h>

define DEGTOSA                  (3600.0*($1))

# -----------------------------------------------------------------------
#
# qpfill
#
# Input :
#
# Output : pointer to xray header
#	   pointer to qpinfo structure
#
# Description : Opens the reference QPOE file and fills the xray
# header structure and the QPOE info structure
#
###

procedure qpfill(refhead, qpinfo)

pointer refhead		# pointer to qpoe header structure
pointer qpinfo		# pointer to local qpoe info structure

pointer refqp		# name of reference qpoe file
pointer qpptr		# pointer to reference qpoe file

pointer sp

pointer qp_open()
bool streq()


begin

    # allocate space for qpoe file name and the QPOE info structure

    call smark(sp)

    call salloc(refqp, SZ_PATHNAME, TY_CHAR)

    call calloc(qpinfo, SIM_QPLEN, TY_STRUCT)
    call malloc(SIM_TPTR(qpinfo), SZ_LINE, TY_CHAR)
    call malloc(SIM_IPTR(qpinfo), SZ_LINE, TY_CHAR)

    # get name of qpoe file and open

    call clgstr("refqp", Memc[refqp], SZ_PATHNAME)

    qpptr = qp_open(Memc[refqp], READ_ONLY, 0)

    # read the header from the qpoe file and close

    call get_qphead(qpptr, refhead)

    call qp_close(qpptr)

    # read information into qp info structure
    # save the LIVETIME from the reference QPOE file

    SIM_QPAPPX(qpinfo) =  real(DEGTOSA(abs(QP_CDELT1(refhead))))
    SIM_REFLVT(qpinfo) = QP_LIVETIME(refhead)
    SIM_QPLVT(qpinfo) = 0.0

    call strcpy(QP_MISSTR(refhead), SIM_TEL(qpinfo), SZ_LINE)
    call inst_itoc(QP_INST(refhead), QP_SUBINST(refhead), SIM_INST(qpinfo), SZ_LINE)

    if (streq(SIM_INST(qpinfo), "HRI" )) {
        SIM_QPLL(qpinfo) = HRI_LL
        SIM_QPUL(qpinfo) = HRI_UL
	SIM_QPCENX(qpinfo) = HRI_CENX
  	SIM_QPCENY(qpinfo) = HRI_CENY
    }
    else {
        call eprintf("SIMEVT currently does not run for the %s instrument\n")
        call pargstr(QP_INST(refhead))
        call error(1, "")
    }

    call sfree(sp)

end    

# -----------------------------------------------------------------------
#
# init_stab
#
# Input :
#
# Output : iptr - pointer to source table file
#	   icolptr - pointer to table columns
#	   numsrcs - number of rows in source table
#
# Description : Open the input source table file and locate the columns.
#
# Read the number of rows and exit with an error if numsrcs = 0.
#      
###

procedure init_stab(iptr, icolptr, numsrcs)

pointer iptr		
pointer icolptr[ARB]
int numsrcs

pointer srctab          # name of input source table

pointer sp
pointer tbtopn()
int tbpsta()

begin

    # open the input table file, find the number of sources

    call smark(sp)
    call salloc(srctab, SZ_PATHNAME, TY_CHAR)
    call clgstr("srctab", Memc[srctab], SZ_PATHNAME)

    iptr = tbtopn(Memc[srctab], READ_ONLY, 0)
    numsrcs = tbpsta(iptr, TBL_NROWS)

    if ( 0 == numsrcs ) {
	call error(1, "No sources found in input table!")
    }

    # define the table columns

    call tbcfnd(iptr, "x", icolptr[XLOC], 1)
    call tbcfnd(iptr, "y", icolptr[YLOC], 1)
    call tbcfnd(iptr, "itype", icolptr[TYPE_LOC], 1)
    call tbcfnd(iptr, "intensity", icolptr[INT_LOC], 1)
    call tbcfnd(iptr, "prf_type", icolptr[PRF_LOC], 1)
    call tbcfnd(iptr, "prf_param", icolptr[PAR_LOC], 1)

    call sfree(sp)

end 
    
# -----------------------------------------------------------------------
#
# get_src_info
#
# Input : 	iptr 	- pointer to source table file
#	  	icolptr - array of column pointers
#	  	srcno 	- table row number
#               qpinfo  - pointer to qpoe info structure
#	  
# Output : 	srcinfo - pointer to source info structure
#		good_src - boolean to indicate that source position lies
#			   within defined field boundaries
#
# Description : Parse one rows worth of data from the source table
# and fill the srcinfo structure.  Allocate the data structure when
# reading the first source.
#
# Check that specified source center is within the defined field limits,
# (for non-bkgd sources only!) and set the flag good_src to NO if it falls 
# outside.
#
##

procedure get_src_info(iptr, icolptr, srcno, qpinfo, srcinfo, good_src)

pointer iptr
pointer icolptr[ARB]
pointer qpinfo
int srcno

pointer srcinfo
bool good_src

bool streq()

begin

    good_src = TRUE

    # if this is the first time through, we need to allocate the
    # memory for the structure

    if ( 1 == srcno ) {
        call calloc(srcinfo, LEN_SRC, TY_STRUCT)
        call calloc(IPTR(srcinfo), SZ_LINE, TY_CHAR)
        call calloc(PPTR(srcinfo), SZ_LINE, TY_CHAR)
    }

    # fill the structure with this row's info

    SRCNO(srcinfo) = srcno
    call tbegti(iptr, icolptr[XLOC], srcno, SRCX(srcinfo))
    call tbegti(iptr, icolptr[YLOC], srcno, SRCY(srcinfo))
    call tbegtt(iptr, icolptr[TYPE_LOC], srcno, ITYPE(srcinfo), SZ_LINE)
    call tbegtr(iptr, icolptr[INT_LOC], srcno, INTENS(srcinfo))
    call tbegtt(iptr, icolptr[PRF_LOC], srcno, PTYPE(srcinfo), SZ_LINE)
    call tbegtr(iptr, icolptr[PAR_LOC], srcno, PRFPAR(srcinfo))
    
    if ( streq(PTYPE(srcinfo), "bkgd" ) ) {
	SRCTYPE(srcinfo) = RAN_BKGD
	SRCPAR(srcinfo) = 0
    }
    else {
	# need to check that source position is valid 

    	if ( (SRCX(srcinfo) < SIM_QPLL(qpinfo)) || 
	     (SRCX(srcinfo) > SIM_QPUL(qpinfo)) || 
	     (SRCY(srcinfo) < SIM_QPLL(qpinfo)) || 
	     (SRCY(srcinfo) > SIM_QPUL(qpinfo)) ) {

	    good_src = FALSE
	}
    }

end

# -----------------------------------------------------------------------
#
# pr_srcinfo
#
# Description : print the contents of the srcinfo structure
#
###

procedure pr_srcinfo(srcinfo)

pointer srcinfo

begin

    call printf("\tSRCNO : %s    SRCCTS is : %d \n")
      call pargi(SRCNO(srcinfo))
      call pargi(SRCCTS(srcinfo))
    call printf("\tXPOS : %d    YPOS : %d \n")
      call pargi(SRCX(srcinfo))
      call pargi(SRCY(srcinfo))
    call printf("\tITYPE : %s    INTENS : %.2f \n")
      call pargstr(ITYPE(srcinfo))
      call pargr(INTENS(srcinfo))
    call printf("\tPTYPE : %s    PRFPAR : %.2f \n")
      call pargstr(PTYPE(srcinfo))
      call pargr(PRFPAR(srcinfo))
    call printf("\tSRCTYPE : %s  SRCPAR : %.2f \n\n")
      call pargi(SRCTYPE(srcinfo))
      call pargr(SRCPAR(srcinfo))

    call fseti (STDOUT, F_FLUSHNL, YES)

end

###
#
# pr_qpinfo
#
# Description : print the contents of the qpinfo structure
#
###

procedure pr_qpinfo(qpinfo)

pointer qpinfo

begin

    call printf("\nContents of QPOE info structure : \n\n")
    call printf("\tField Center : %d %d \n")
      call pargi(SIM_QPCENX(qpinfo))
      call pargi(SIM_QPCENY(qpinfo))
    call printf("\tLower limit : %d    Upper limit : %d \n")
      call pargi(SIM_QPLL(qpinfo))
      call pargi(SIM_QPUL(qpinfo))
    call printf("\t#arcsec/pix : %.2f  Ref. QPOE Livetime : %.2f \n")
      call pargr(SIM_QPAPPX(qpinfo))
      call pargr(SIM_REFLVT(qpinfo))
    call printf("\tTelescope : %s      Inst : %s \n\n")
      call pargstr(SIM_TEL(qpinfo))
      call pargstr(SIM_INST(qpinfo))

    call fseti (STDOUT, F_FLUSHNL, YES)

end

# -----------------------------------------------------------------------
# 
# mk_hdr
#
# Description : Write out the ascii header template that can be used
# by QPCREATE
#
##

procedure mk_hdr(refhead, qpinfo, ohd)

pointer refhead
pointer qpinfo
int ohd

begin

    call fprintf(ohd, "NAXES 	i 2 \n")
    call fprintf(ohd, "TALEN1	i %d \n")
      call pargi(QP_XDIM(refhead))
    call fprintf(ohd, "TALEN2	i %d \n")
      call pargi(QP_YDIM(refhead))
    call fprintf(ohd, "TCTYP1	t RA---TAN \n")
    call fprintf(ohd, "TCTYP2	t DEC--TAN \n")
    call fprintf(ohd, "TCRPX1	d %d \n")
      call pargd(QP_CRPIX1(refhead))
    call fprintf(ohd, "TCRPX2	d %d \n")
      call pargd(QP_CRPIX2(refhead))
    call fprintf(ohd, "TCROT1	d 0. \n")
    call fprintf(ohd, "TCROT2	d 0. \n")
    call fprintf(ohd, "TCRVL1   d %f \n")
      call pargd(QP_CRVAL1(refhead))
    call fprintf(ohd, "TCRVL2	d %f \n")
      call pargd(QP_CRVAL2(refhead))
    call fprintf(ohd, "TCDLT1	d %e \n")
      call pargd(QP_CDELT1(refhead))
    call fprintf(ohd, "TCDLT2 	d %e \n")
      call pargd(QP_CDELT2(refhead))
    call fprintf(ohd, "TELESCOP	t %s \n")
      call pargstr(SIM_TEL(qpinfo))
    call fprintf(ohd, "INSTRUME	t %s \n")
      call pargstr(SIM_INST(qpinfo))
    call fprintf(ohd, "EQUINOX	d %.1f \n")
      call pargr(QP_EQUINOX(refhead))
    call fprintf(ohd, "RADECSYS	t %s \n")
      call pargstr(QP_RADECSYS(refhead))
    call fprintf(ohd, "FILTER	t %s \n")
      call pargstr(QP_FILTER(refhead))
    call fprintf(ohd, "MJDREFI	i %d \n")
      call pargi(QP_MJDRDAY(refhead))
    call fprintf(ohd, "MJDREFF	d %f \n")
      call pargd(QP_MJDRFRAC(refhead))

    # for the simulated data, we assume that the dead time correction
    # factor is 1, and therefore the ONTIME is the same as the LIVETIME.
    # we need the keyword ONTIME for running QPAPPEND

    call fprintf(ohd, "ONTIME   d %.2f \n")
      call pargr(SIM_QPLVT(qpinfo))
    call fprintf(ohd, "LIVETIME	d %.2f \n")
      call pargr(SIM_QPLVT(qpinfo))

end
