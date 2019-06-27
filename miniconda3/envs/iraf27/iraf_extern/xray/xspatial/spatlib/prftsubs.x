# $Header: /home/pros/xray/xspatial/spatlib/RCS/prftsubs.x,v 11.0 1997/11/06 16:31:42 prosb Exp $
# $Log: prftsubs.x,v $
# Revision 11.0  1997/11/06 16:31:42  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:49:53  prosb
# General Release 2.4
#
#Revision 1.1  1994/09/07  17:33:47  janet
#Initial revision
#
#
# Module:       prftsubs.x
# Project:      PROS -- ROSAT RSDC
# Purpose:      prf table lookup routines
# Description:  init_prftab, prf_lookup 
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} JD -- initial version -- 9/92
#
# ----------------------------------------------------------------------------

include <tbset.h>
include <ext.h>

# ----------------------------------------------------------------------------
# Initialize the prf lookup table
# ----------------------------------------------------------------------------
procedure init_prftab (ptp, pcolptr)

pointer ptp                     # i: prf coeff table pointer
pointer pcolptr[ARB]            # i: prf column pointer

pointer prf_fname               # l: prf coeff table name
pointer sp                      # l: salloc pointer

pointer tbtopn()
bool    ck_none()

begin
        call smark(sp)
        call salloc (prf_fname, SZ_PATHNAME, TY_CHAR)

        # Open the prf coefficients table for reading
        call clgstr ("prf_table", Memc[prf_fname], SZ_PATHNAME)
        call rootname ("", Memc[prf_fname], EXT_TABLE, SZ_PATHNAME)
        if ( ck_none (Memc[prf_fname]) ) {
           call error (1, "Reference prf table required!!")
        }
        ptp = tbtopn (Memc[prf_fname], READ_ONLY, 0)

        call tbcfnd (ptp, "mission", pcolptr[1], 1)
        call tbcfnd (ptp, "instr", pcolptr[2], 1)
        call tbcfnd (ptp, "energy", pcolptr[3], 1)
        call tbcfnd (ptp, "eq_code", pcolptr[4], 1)
        call tbcfnd (ptp, "a", pcolptr[5], 1)
        call tbcfnd (ptp, "b", pcolptr[6], 1)
        call tbcfnd (ptp, "c", pcolptr[7], 1)
        call tbcfnd (ptp, "d", pcolptr[8], 1)
        call tbcfnd (ptp, "e", pcolptr[9], 1)
        call sfree(sp)
end

# ----------------------------------------------------------------------------
# Given a Mission, Instrument, and energy lookup and return the corresponding 
# PRF coefficients from the PRF lookup table 
# ----------------------------------------------------------------------------
procedure prf_lookup (ptp, pcolptr, instrument, telescope, energy, display,
                      eqkey, aa, bb, cc, dd, ee)


pointer pcolptr[ARB]            # i: prf table column pointer
pointer ptp                     # i: prf table pointer

char    instrument[ARB]         # i: instrument corresponding to data
char    telescope[ARB]          # i: telescope corresponding to data

int     display                 # i: display level
int     eqkey                   # i: equation key for prf

real    energy                  # i: energy
real    aa,bb,cc,dd,ee          # o: prf coefficients

bool    done                    # l: indicates whether to contimue table search
bool    nullflag[25]

int     index                   # l: table row pointer
int     num_prfs                # l: num rows in table
int     def_prfrow              # l: row with default coefs
int     prfrow                  # l: prf coef row
int     prevrow                 # l: previous row

pointer sp                      # l: salloc pointer
pointer buff
pointer ttel, tinstr            # l: telescope and instrument from table

real    tenergy                 # l: energy from table

bool    streq()
int     tbpsta()

begin

        call smark (sp)
        call salloc (ttel, SZ_LINE, TY_CHAR)
        call salloc (tinstr, SZ_LINE, TY_CHAR)
        call salloc (tenergy, SZ_LINE, TY_CHAR)
        call salloc (buff, SZ_LINE, TY_CHAR)

        num_prfs = tbpsta (ptp, TBL_NROWS)

        done = FALSE
        eqkey=0; aa=0.0; bb=0.0; cc=0.0; dd=0.0; ee=0.0
        def_prfrow = 0
        prevrow = 0
        index = 1


        # PRF coef TABLE : ( assumptions about the prf.tab )
        #    a) the 1st instrument entry is the default with energy = 0.0
        #    b) the other energies follow in ascending order
        #    c) the entries for an instrument are grouped together in 
        #       the table.
        #
        #  Loop through the prf coeff table and look for a match with
        #  telescope, instrument, and energy to uniquely identify an entry
        do while ( ! done ) {

           call tbrgtt (ptp, pcolptr[1], Memc[ttel], nullflag, 10, 1, index)
           call tbrgtt (ptp, pcolptr[2], Memc[tinstr], nullflag, 10, 1, index)
           call tbrgtr (ptp, pcolptr[3], tenergy, nullflag, 1, index)

           # Match the telescope and instrument
           if ( streq (Memc[ttel], telescope ) ) {
              if ( streq (Memc[tinstr], instrument ) ) {

                 # exact match ... we're done
                 if ( tenergy == energy ) {
                    prfrow = index
                    done = TRUE

                 # not exact match ... we want to assign the previous row if 
                 #                     we had one...ascending order assumption.
                 } else if ( tenergy > energy ) {
                     prfrow = def_prfrow
                     done = TRUE
                 }
                 def_prfrow = index
              }
           }
           index = index + 1

           if ( (index > num_prfs) && (!done) ) {
              if ( def_prfrow == 0 ) {
                 call error (1, 
                "No coeffs for input Instrument, specify input param prf_sigma")
              }
              prfrow = def_prfrow
              call sprintf (Memc[buff], SZ_LINE,
                 "Cannot find Entry for PRF coeffs corresponding to Energy %f")
                  call pargr (energy)
              call printf ("\n%s\n")
                  call pargstr (Memc[buff])
              call printf ("Will assign coeffs for default Energy\n\n")

              done = TRUE
           }
        }
        # we've made the match so return the coefficients
        call tbrgti (ptp, pcolptr[4], eqkey, nullflag, 1, prfrow)
        call tbrgtr (ptp, pcolptr[5], aa, nullflag, 1, prfrow)
        call tbrgtr (ptp, pcolptr[6], bb, nullflag, 1, prfrow)
        call tbrgtr (ptp, pcolptr[7], cc, nullflag, 1, prfrow)
        call tbrgtr (ptp, pcolptr[8], dd, nullflag, 1, prfrow)
        call tbrgtr (ptp, pcolptr[9], ee, nullflag, 1, prfrow)

        if ( display >= 3 && display != 10 ) {
           call printf ("PRF Coeffs: a, b, c, d, e = %0.3f %0.3f %0.3f %0.3f %0.3f, eq_code = %d\n\n")
              call pargr (aa)
              call pargr (bb)
              call pargr (cc)
              call pargr (dd)
              call pargr (ee)
              call pargi (eqkey)
        }
        call sfree(sp)
end
