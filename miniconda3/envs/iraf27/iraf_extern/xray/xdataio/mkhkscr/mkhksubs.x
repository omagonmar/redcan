# $Header: /home/pros/xray/xdataio/mkhkscr/RCS/mkhksubs.x,v 11.0 1997/11/06 16:34:24 prosb Exp $
# $Log: mkhksubs.x,v $
# Revision 11.0  1997/11/06 16:34:24  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:58:31  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  15:19:59  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:39:29  prosb
#General Release 2.3
#
#Revision 1.1  93/12/22  17:20:35  janet
#Initial revision
#
#
# Module:       mkhksubs.x
# Project:      PROS -- ROSAT RSDC
# Purpose:      subroutines to support mkhkscr task
# Local:        tab_initcol(), open_qlm(), open_hklookup(), 
#		rd_lu_row(), bld_minmax_filt(), bld_lg_filt() 
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} jd -- initial version -- 11/93
#               {n} <who> -- <does what> -- <when>
#
# ---------------------------------------------------------------------
include <error.h>
include <ext.h>
include <tbset.h>

define TNAME  	1
define QNAME 	2
define TKEY	3
define BKEY	4
define INST	5

# ---------------------------------------------------------------------
#
# Function:     tab_initcol
# Purpose:      initialize table column and return pointer
# Pre-cond:     table file opened
# Post-cond:    column initialized
#
# ---------------------------------------------------------------------
procedure tab_initcol (tp, colname, col_tp)

pointer tp                      # i: table handle
char    colname[ARB]            # i: data column name
pointer col_tp                  # o: position table column pointers

pointer buff                    # l: local string buffer
pointer sp                      # l: stack pointer

begin

        call smark(sp)
        call salloc(buff, SZ_LINE, TY_CHAR)

#   get column pointer
        iferr (call tbcfnd (tp, colname, col_tp, 1)) {
          call sprintf(Memc[buff],SZ_LINE,"Column %s does NOT EXIST in Table")
             call pargstr (colname)
          call error(1, Memc[buff])
        }
        if (col_tp == NULL) {
          call sprintf(Memc[buff],SZ_LINE,"Column %s does NOT EXIST in Table")
             call pargstr (colname)
          call error(1, Memc[buff])
        }

        call sfree(sp)
end

# ---------------------------------------------------------------------
#
# Function:     open_qlm
# Purpose:      open the QLM table and return the file pointer
# Pre-cond:     table file opened
#
# ---------------------------------------------------------------------
procedure open_qlm (tp_qlm, display, qrows)

pointer tp_qlm          # qlm table pointer
int     display		# display level
int     qrows           # number of rows in orbit file

pointer qlm_fname       # qlm table name
pointer sp              # allocation pointer

bool    ck_none()
int     tbtacc()
int     tbpsta()
pointer tbtopn()

begin

        call smark(sp)
        call salloc (qlm_fname, SZ_PATHNAME, TY_CHAR)

        call clgstr("qlmtab", Memc[qlm_fname], SZ_PATHNAME)

        call rootname("", Memc[qlm_fname], EXT_TABLE, SZ_PATHNAME)
        if (ck_none(Memc[qlm_fname]) )
           call error (EA_FATAL, "Requires lookup table as input.")

        if (tbtacc(Memc[qlm_fname]) == YES)
           tp_qlm = tbtopn (Memc[qlm_fname], READ_ONLY, 0)
        else
           call error(EA_FATAL, "Qlm table not found.")

        if (display >= 2)
        {
          call printf("Opening file: %s\n")
          call pargstr(Memc[qlm_fname])
          call flush(STDOUT)
        }

        #----------------------
        # Check for empty table
        #----------------------
        qrows = tbpsta (tp_qlm, TBL_NROWS)

        if (qrows <= 0) {
           call error (EA_FATAL, "Table file empty.")
#        } else if (qrows != 1 ) {
#           call error (EA_FATAL, "Can only work on tables with 1 row.")
        }

        call sfree(sp)

end

# ---------------------------------------------------------------------
#
# Function:     open_hklookup
# Purpose:      open the lookup table and return the file pointer
#               The lookup table matches QLM and TSI names and id's
#               the QLM entries as type MINMAX or SETBIT.
# Pre-cond:     table file opened
#
# ---------------------------------------------------------------------
procedure open_hklookup (tp_lu, lucol, display, nrows)

pointer tp_lu           #i: qlm table pointer
pointer lucol[ARB]      #i: lookup table column pointers
int     display		#i: display level
int     nrows           #o: number of rows in orbit file

pointer sp              #l: allocation pointer
pointer lu_fname        #l: lookup file name

bool    ck_none()
int     tbtacc()
int     tbpsta()
pointer tbtopn()

begin
        call smark(sp)
        call salloc (lu_fname, SZ_PATHNAME, TY_CHAR)

        call clgstr("hklookup", Memc[lu_fname], SZ_PATHNAME)

        call rootname("", Memc[lu_fname], EXT_TABLE, SZ_PATHNAME)
        if (ck_none(Memc[lu_fname]) )
           call error (EA_FATAL, "Requires lookup table as input.")

        if (tbtacc(Memc[lu_fname]) == YES)
           tp_lu = tbtopn (Memc[lu_fname], READ_ONLY, 0)
        else
           call error(EA_FATAL, "HK Lookup table not found.")

        if (display >= 2)
        {
          call printf("Opening file: %s\n")
          call pargstr(Memc[lu_fname])
          call flush(STDOUT)
        }

        #----------------------
        # Check for empty table
        #----------------------
        nrows = tbpsta (tp_lu, TBL_NROWS)

        if (nrows <= 0)
           call error (EA_FATAL, "Table file empty.")

        #--------------------
        # get column pointers
        #--------------------
        call tab_initcol(tp_lu, "tsiname", lucol[TNAME])
        call tab_initcol(tp_lu, "qlmname", lucol[QNAME])
        call tab_initcol(tp_lu, "key",     lucol[TKEY])
        call tab_initcol(tp_lu, "bitkey",  lucol[BKEY])
        call tab_initcol(tp_lu, "instr",   lucol[INST])

end

# ---------------------------------------------------------------------
# Function:     rd_lu_row
# Purpose: read row in tsi/qlm calib table
#               tsiname : is the tsi identifier
#               qlmname : is the corresponing name in the qlm extension
#               key     : indicate whether is bit or min/max type
#               bitkey  : indicates which bit to set
#               instr   : indicates which instrument
# Pre-cond:     table file opened
# ---------------------------------------------------------------------
procedure rd_lu_row (tp_lu, lucol, row, instrument, display, tsiname, 
		     qlmname, key, bitkey, instr_match)

pointer tp_lu		#i: lookup table pointer
pointer lucol[ARB]	#i: lookup table column pointers
int     row		#i: current row number
char    instrument[ARB] #i: instrument name
int     display		#i: display level
char    tsiname[ARB]	#o: tsi column name
char    qlmname[ARB]	#o: corresponding qlm column name
int     key		#o: indicates type: minmax or setbit
int     bitkey		#o: which bit to set for type setbits
bool    instr_match	#o: indicates whether we have a valid row for instr

pointer sp
pointer instr		#l: input instrument from lookup table row
bool    streq()

begin

        call smark (sp)
        call salloc (instr, SZ_LINE, TY_CHAR)

        call tbegtt(tp_lu, lucol[TNAME], row, tsiname, 20)
        call tbegtt(tp_lu, lucol[QNAME], row, qlmname, 20)
        call tbegti(tp_lu, lucol[TKEY], row, key)
        call tbegti(tp_lu, lucol[BKEY], row, bitkey)
        call tbegtt(tp_lu, lucol[INST], row, Memc[instr], 10)

        # -- only find qlims for lookup entry when instruments match -- #
	instr_match = streq(Memc[instr],instrument)

        if ( display >= 3 && instr_match ) {
          call printf ("tsiname=%12s, qlmname=%12s, key=%2d, bitkey=%2d, instr=%8s\n")
          call pargstr (tsiname)
          call pargstr (qlmname)
          call pargi (key)
          call pargi (bitkey)
          call pargstr (Memc[instr])

          call flush (STDOUT)
        }
        call sfree (sp)
end

# ---------------------------------------------------------------------
#
# Function:     bld_minmax_filt
# Purpose:      build a MINMAX type filter and add it to the ascii
#		file we are building with each entry. 
# Pre-cond:     table file opened
# Post-cond:    column initialized
#
# ---------------------------------------------------------------------
procedure bld_minmax_filt (tp_qlm, qlmname, tsiname, optr)

pointer tp_qlm		#i: qlim table pointer
char    qlmname[ARB]	#i: qlm column name
char    tsiname[ARB]	#i: corresponding tsi name
pointer optr		#i: ascii output filter file

pointer buf		#l: local string buffer
pointer sp		#l: space allocation pointer

pointer mncol, mxcol	#l: min/max qlm column pointers
int     mnval, mxval	#l: min/max qlm values

begin
        call smark(sp)
        call salloc (buf, SZ_LINE, TY_CHAR)

        # ---------------------------------------
        # initialize the qlm column
        # ---------------------------------------
        call sprintf (Memc[buf], SZ_LINE, "mn_%s")
          call pargstr (qlmname)
        call tab_initcol(tp_qlm, Memc[buf], mncol)

        call sprintf (Memc[buf], SZ_LINE, "mx_%s")
          call pargstr (qlmname)
        call tab_initcol(tp_qlm, Memc[buf], mxcol)

        # ---------------------------------------
        # read min and max
        # ---------------------------------------
        call tbegti(tp_qlm, mncol, 1, mnval)
        call tbegti(tp_qlm, mxcol, 1, mxval)

        # ---------------------------------------
        # write it out with tsiname for filter
        # ---------------------------------------
        call fprintf (optr, "%s=%d:%d,")
          call pargstr (tsiname)
          call pargi (mnval)
          call pargi (mxval)
        call flush (STDOUT)

        call sfree(sp)

end

# ---------------------------------------------------------------------
#
# Function:     bld_minmax_filt
# Purpose:      build a MINMAX type filter and add it to the ascii
#		file we are building with each entry. 
# Pre-cond:     table file opened
# Post-cond:    column initialized
#
# ---------------------------------------------------------------------
procedure bld_lg_filt (tp_lu, tp_qlm, lucol, tsiname, bitkey, ii, display, optr)

pointer tp_lu		#i: lookup table pointer
pointer tp_qlm		#i: qlm table pointer
pointer lucol[ARB]	#i: qlm table column pointers
char    tsiname[ARB]	#i: tsi column names
int     bitkey		#i: bit to set
int     ii		#i: lookup table row we're on
int     display		#i: display level
pointer optr		#i: output ascii filter file pointer

short   logval		#l: logical value for filter
int     numbits         #l: num bits to set
int     bit		#l: bit loop counter
int     onoff           #l: bit value from table
pointer qlmname		#l: qlmname
pointer sp		#l: space allocation pointer
pointer qlmcol		#l: qlm column pointer

begin

        call smark (sp)
        call salloc (qlmname, SZ_LINE, TY_CHAR)

        if ( display >= 3 ) {
          call printf ("In SETBITS, bitkey= %d\n")
            call pargi(bitkey)
          call flush(STDOUT)
        }

        numbits = bitkey-1
        logval = 0

        # ---------------------------------------------------------
        # the next numbits in calib table should have the bit info
        # ---------------------------------------------------------
        do bit = 0, numbits {

          ii = ii + 1

          # --------------------------------
          # read the qlm name and bit to set
          # --------------------------------
          call tbegtt(tp_lu, lucol[QNAME], ii, Memc[qlmname], 20)
          call tbegti(tp_lu, lucol[BKEY], ii, bitkey)

          if ( display >= 3 ) {
            call printf ("qlmname= %12s, bitkey= %d ")
              call pargstr (Memc[qlmname])
              call pargi (bitkey)
            call flush (STDOUT)
          }
          # -------------------------------------------------
          # Initialize the qlm column and read the bit value
          # -------------------------------------------------
          call tab_initcol(tp_qlm, Memc[qlmname], qlmcol)
          call tbegti(tp_qlm, qlmcol, 1, onoff)

          if ( display >= 2 ) {
            call printf("tsiname=%10s, bit=%2d, onoff %2d\n")
              call pargstr (tsiname)
              call pargi (bitkey)
              call pargi (onoff)
            call flush (STDOUT)
          }

          # --------------------
          # Set the bit when ON
          # --------------------
          if ( onoff == 1 ) {
            switch (bitkey) {
              case 0:
                logval = or(logval,1X)
              case 1:
                logval = or(logval,2X)
              case 2:
                logval = or(logval,4X)
              case 3:
                logval = or(logval,8X)
              case 4:
                logval = or(logval,10X)
              case 5:
                logval = or(logval,20X)
              case 6:
                logval = or(logval,40X)
              case 7:
                logval = or(logval,80X)
             }
           }
        }
        # ---------------------------------------
        # write is out with tsiname for filter
        # ---------------------------------------
        call fprintf (optr, "%s=%%%xX,")
          call pargstr (tsiname)
            call pargs (logval)
          call flush (STDOUT)

end
