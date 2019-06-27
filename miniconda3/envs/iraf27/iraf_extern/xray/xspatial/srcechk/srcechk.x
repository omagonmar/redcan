# $Header: /home/pros/xray/xspatial/srcechk/RCS/srcechk.x,v 11.0 1997/11/06 16:33:36 prosb Exp $
# $Log: srcechk.x,v $
# Revision 11.0  1997/11/06 16:33:36  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:56:23  prosb
# General Release 2.4
#
#Revision 1.2  1994/10/24  16:23:13  prosb
#krm - added some missing back slashes.
#
#Revision 1.1  94/10/24  16:17:40  prosb
#Initial revision
#
#Revision 1.2  94/10/24  16:11:11  prosb
#krm - added "bkgd" as an acceptable prf_type.
#
#Revision 1.1  94/10/24  15:28:00  prosb
#Initial revision
#
#
# Module:       srcechk.x
# Project:      PROS -- ROSAT RSDC
# Description:  does error checking on the input table file to task qpsim
#               - there is hardwired code in here that represents the 
#		  acceptable input for the qpsim input table, if QPSIM
#	          changes this code must also be updated.
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} JD - initial version - 8/94 
#
# ---------------------------------------------------------------------------
include <tbset.h>

procedure t_srcechk()

pointer tabname		# pointer to name of input source table
pointer itptr		# pointer to the table itself
int 	numsrcs		# number of rows in the table
pointer	icolptr[6]	# holds pointers to the table columns

pointer	itype		# "type" for intensity col
pointer prf_type	# type of source to generate

bool    fnderr		# triggers when error found
bool    first		# first time through indicator
int     display		# display level 
int	srcno		# loop invariant
int     num_errs	# tallies number of errors found in file
int 	xpos,ypos	# x/y position
real    intensity	# intensity parameter
real    prf_param	# prf parameter
   
pointer sp		# for the salloc calls

pointer tbtopn()
int     clgeti()
int 	tbpsta()
bool    streq()

begin

    # open the input table file and get the number of rows 
    call smark(sp)
    call salloc(tabname,  SZ_PATHNAME, TY_CHAR)
    call salloc(itype, 	  SZ_LINE,     TY_CHAR)
    call salloc(prf_type, SZ_LINE,     TY_CHAR)

    call clgstr("intab", Memc[tabname], SZ_PATHNAME)
    itptr = tbtopn(Memc[tabname], READ_ONLY, 0)
    numsrcs = tbpsta(itptr, TBL_NROWS)

    if ( numsrcs == 0 ) {
	call error(1, "No sources found in input table!")
    }

    display = clgeti("display")
    if ( display >= 2 ) {
       call printf("Number of rows : %d \n\n")
         call pargi(numsrcs)
    }

    # find pointers to the table columns
    call tbcfnd(itptr, "x", icolptr[1], 1)
    call tbcfnd(itptr, "y", icolptr[2], 1)
    call tbcfnd(itptr, "itype", icolptr[3], 1)
    call tbcfnd(itptr, "intensity", icolptr[4], 1)
    call tbcfnd(itptr, "prf_type", icolptr[5], 1)
    call tbcfnd(itptr, "prf_param", icolptr[6], 1)

    num_errs = 0

    # read over each source and print out it's information
    for ( srcno = 1; srcno <= numsrcs; srcno = srcno + 1 ) {

        fnderr = FALSE
        first = TRUE

	# read in source parameters
	call tbegti(itptr, icolptr[1], srcno, xpos)
	call tbegti(itptr, icolptr[2], srcno, ypos)
	call tbegtt(itptr, icolptr[3], srcno, Memc[itype], SZ_LINE)
	call tbegtr(itptr, icolptr[4], srcno, intensity)
	call tbegtt(itptr, icolptr[5], srcno, Memc[prf_type], SZ_LINE)
	call tbegtr(itptr, icolptr[6], srcno, prf_param)

        # check itype errs - we accept "rate" and "counts"
	if ( !streq(Memc[itype],"rate")) {	
	   if ( !streq(Memc[itype],"counts")) {	
	     call printf ("Row %d: itype err - \"%s\"  ") 
               call pargi (srcno)
	       call pargstr(Memc[itype])
	     fnderr=TRUE
	     first=FALSE
	     num_errs = num_errs + 1
	   }
	}
	
        # check prf_type errs - we accept "roshri", "gauss_oaa", "gauss_sig"
	# and "bkgd"
	if ( !streq(Memc[prf_type],"roshri")) {	
	   if ( !streq(Memc[prf_type],"gauss_oaa")) {	
	      if ( !streq(Memc[prf_type],"gauss_sig")) {	
		if ( !streq(Memc[prf_type],"bkgd")) {
	             # do we need a row id#, or has it already been 
		     # written above?
                     if ( first ) {
			call printf ("Row %d: \n") 
	                  call pargi (srcno)
		     }
	             call printf (" prf_type err - \"%s\" \n")
		       call pargstr(Memc[prf_type])
		     fnderr=TRUE
		     num_errs = num_errs + 1
	 	}
	      }
	   }
	}

	if ( !(fnderr) && (display > 1) ){
	   call printf ("Row %d: OK\n")
	      call pargi (srcno)
        }
    }

    # if there we're errors found - give the user some info
    if (num_errs > 0 ) {
	call printf ("\n       -----: Found %d errors in table !! :------\n\n")
          call pargi(num_errs)

	call printf (">>> ----------------------------------------------------------------- <<<\n")
	call printf (">>> Please Note:                                                      <<<\n")
	call printf (">>> Correct your ascii input list & rerun SIMTAB before running QPSIM <<<\n")
	call printf (">>>   Acceptable columns for:                                         <<<\n")
	call printf (">>>        itype = \"counts\" -or- \"rate\"                               <<<\n")
	call printf (">>>     prf_type = \"roshri\" -or- \"gauss_oaa\" -or- \"gauss_sig\" -or- \"bkgd\"        <<<\n")

	call printf (">>> ----------------------------------------------------------------- <<<\n\n")

	# set whether errors were found do that we can pass the info to the cl
        call clpstr ("tab_err", "yes")
    } else {
        call clpstr ("tab_err", "no")
    }

    call sfree(sp)
    call tbtclo(itptr)

end
