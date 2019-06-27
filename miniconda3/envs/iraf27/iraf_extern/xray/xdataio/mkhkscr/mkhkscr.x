# $Header: /home/pros/xray/xdataio/mkhkscr/RCS/mkhkscr.x,v 11.0 1997/11/06 16:34:23 prosb Exp $
# $Log: mkhkscr.x,v $
# Revision 11.0  1997/11/06 16:34:23  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:58:29  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  15:19:56  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:39:26  prosb
#General Release 2.3
#
#Revision 1.1  93/12/22  17:19:57  janet
#Initial revision
#
#
# Module:       mkhkscr
# Project:      PROS -- ROSAT RSDC
# Purpose:      < opt, brief description of whole family, if many routines>
# External:     < routines which can be called by applications>
# Local:        < routines which are NOT intended to be called by applications>
# Description:  < opt, if sophisticated family>
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} JD - initial version - 9/93
#               {n} <who> -- <does what> -- <when>
#
#******************************************************************************
# we read from a lookup table to match QLM record names to their TSI record
# counterparts.  Some info is in min/max format, while others are bit settings 
# that map to a single TSI variable.  The differentiation is made by column 
# key in the lookup table, where 0 is min/max and 1 is setbit.  The info in 
# the QLM table is written out as a filter string with TSI id's on each status.
#******************************************************************************

include <tbset.h>
include <error.h>
include <ext.h>

define  MINMAX   0
define  SETBITS  1

procedure t_mkhkscr()

bool    clobber         # clobber old file
bool    not_done	# loop control
bool    instr_match	# indicates whether instruments match


int     bitkey		# indicates bit to set from table
int	key		# indicates setbits or minmax type 
int	display		# debug level
int     ii,jj		# loop index
int	nrows		# number of rows in orbit file
int	qrows		# number of rows in orbit file

pointer	instrument	# instrument column name
pointer tsiname		# tsi column name 
pointer qlmname		# qlm column name
pointer lucol[10]
pointer tp_lu		# input table 
pointer tp_qlm		# input table 
pointer sp		# space allocation pointer
pointer flt_fname	# output ascii filter filename
pointer tempname	# temp buffer for output file
pointer optr		# write logical unit


bool    clgetb()        
int 	clgeti()
pointer open()

begin
	call smark  (sp)
        call salloc (flt_fname, SZ_PATHNAME, TY_CHAR)
        call salloc (tempname, SZ_PATHNAME, TY_CHAR)
        call salloc (tsiname, SZ_LINE, TY_CHAR)
        call salloc (qlmname, SZ_LINE, TY_CHAR)
        call salloc (instrument, SZ_LINE, TY_CHAR)

#-------------------------
# Get hidden cl parameters
#-------------------------
	clobber = clgetb("clobber")
	display = clgeti("display")
        call clgstr("instr", Memc[instrument], SZ_LINE)

# ---------------------------------
# open the QLM table for reading
# ---------------------------------
        call open_qlm (tp_qlm, display, qrows)

# ------------------------------------
# open the HK lookup table for reading
# ------------------------------------
        call open_hklookup (tp_lu, lucol, display, nrows)

# ---------------------------------
# open the output ascii filter file
# ---------------------------------
        call clgstr("flt_fname", Memc[flt_fname], SZ_PATHNAME)
        call clobbername(Memc[flt_fname], Memc[tempname], clobber, SZ_PATHNAME)
        optr=open(Memc[tempname], NEW_FILE, TEXT_FILE)

#------------------------------	
# main loop on Quality records
#------------------------------
        do jj = 1, qrows {

           ii = 0
           not_done = TRUE

	   #----------------------------------------------------------------
           # We write out 1 valid filter.  If there is > 1 row in the QLM 
           # table, the other filters are written but commented out 
	   #----------------------------------------------------------------
           if ( jj > 1 ) 
	      call fprintf (optr, "\n# ")
       
	   #-------------------------------------	
	   # loop on tsi/qlm match lookup records 
	   #-------------------------------------
           while ( not_done ) {

              ii = ii + 1

              call rd_lu_row (tp_lu, lucol, ii, Memc[instrument], display, 
		     Memc[tsiname], Memc[qlmname], key, bitkey, instr_match)

	      if ( key == MINMAX && instr_match ) {

	         # -- quality type is min/max, build min/max filter -- #
                 call bld_minmax_filt (tp_qlm, Memc[qlmname], 
				       Memc[tsiname], optr)

	      } else if (key == SETBITS && instr_match ){

	         # -- quality type is bit settings, build logical filter -- #
                 call bld_lg_filt (tp_lu, tp_qlm, lucol, Memc[tsiname], 
				   bitkey, ii, display, optr)

	      }

              if ( ii >= nrows ) {
                 not_done = FALSE
              }

	   
           } # end loop

	   # ---------------------------------------
	   # finish the filter with a carriage ret
	   # ---------------------------------------
           call fprintf (optr, "\n")

  	} # end loop on rows

        if ( display > 0 ) {
	  call printf("%d rows in lookup table.\n")
	    call pargi(nrows)
	  call flush(STDOUT)
        }

        #------------------------------
        # close input and output tables
        #------------------------------
        call tbtclo(tp_lu)
        call tbtclo(tp_qlm)

        call finalname(Memc[tempname], Memc[flt_fname])
        call close (optr)

	call sfree(sp)
end
