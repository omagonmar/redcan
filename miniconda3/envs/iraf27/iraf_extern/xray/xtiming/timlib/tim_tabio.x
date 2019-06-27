#$Header: /home/pros/xray/xtiming/timlib/RCS/tim_tabio.x,v 11.0 1997/11/06 16:45:13 prosb Exp $
#$Log: tim_tabio.x,v $
#Revision 11.0  1997/11/06 16:45:13  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:35:11  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:42:47  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:03:21  prosb
#General Release 2.3
#
#Revision 6.1  93/07/02  14:58:14  mo
#MC	7/2/93		remove redundant ==TRUE (RS6000 port)
#
#Revision 6.0  93/05/24  16:59:34  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  23:06:02  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  15:37:15  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  92/04/23  17:55:01  janet
#*** empty log message ***
#
#Revision 3.0  91/08/02  02:02:32  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  22:50:52  pros
#General Release 1.0
#
# ----------------------------------------------------------------------------
#
# Module:	TIM_TABIO
# Project:	PROS -- ROSAT RSDC
# Purpose:	timing table initialize and output routines
# External:	tim_inittab(), tim_filltab()
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989.  You may do anything you like with this
#		file except remove this copyright
# Modified:	{0} Janet DePonte initial version Apr 1989	
#		{n} <who> -- <does what> -- <when>
#
# ----------------------------------------------------------------------------

include <mach.h>
include <tbset.h>

# ----------------------------------------------------------------------------
#
# Function:	tim_inittab
# Purpose:	open a table file & init columns
# Notes:	column names are: 
#			ctrt, err, exp, src, bkgd, net, neterr
#
# ----------------------------------------------------------------------------
procedure tim_inittab (tabname, clobber, col_cp, tp)

char    tabname[ARB]			# i: table pointer
bool	clobber				# i: clober old table file

pointer	col_cp[ARB]			# o: counts column pointer
pointer tp				# o: table pointer

int	tbtacc()			# l: table access function
pointer tbtopn()

begin

#    Clobber old file if it exists
	if ( tbtacc(tp) == YES )
	{
	   if ( clobber )
	   {
	      iferr ( call tbtdel(tp) )
	         call eprintf("Can't delete old Table\n")
	   }
	   else
	      call eprintf("Table file already exists\n")
	}
	tp = tbtopn (tabname, NEW_FILE, 0)

#    Define Columns
	call tbcdef (tp, col_cp[1], "ctrt", "", "%12.5f", TY_REAL, 1, 1)
	call tbcdef (tp, col_cp[2], "err", "", "%12.5f", TY_REAL, 1, 1)
	call tbcdef (tp, col_cp[3], "exp", "", "%12.5f", TY_REAL, 1, 1)
	call tbcdef (tp, col_cp[4], "src", "", "%12.5f", TY_REAL, 1, 1)
	call tbcdef (tp, col_cp[5], "bkgd", "", "%12.5f", TY_REAL, 1, 1)
	call tbcdef (tp, col_cp[6], "net", "", "%12.5f", TY_REAL, 1, 1)
	call tbcdef (tp, col_cp[7], "neterr", "", "%12.5f", TY_REAL, 1, 1)

#    Now actually create it
	call tbtcre (tp)

end

# ----------------------------------------------------------------------------
#
# Function:	tim_filltab
# Purpose:	write 1 table row to the file
#
# ----------------------------------------------------------------------------
procedure tim_filltab (curbin, col_cp, tp, cnt_rate, ctrt_err, exp, 
		       src_cnts, bk_cnts, net_cnts, net_err)

int	curbin				# i: current table row to write
pointer col_cp[ARB]			# i: column pointers
pointer tp				# i: table pointer
real	cnt_rate			# i: cnt rate for 1 bin
real	ctrt_err 			# i: statistical error for 1 bin 
real	exp				# i: exposure for 1 bin
real	src_cnts			# i: src photons in 1 bin
real	bk_cnts				# i: bkgd photons in 1 bin
real    net_cnts			# i: net cnts
real    net_err				# i: error on src and bkgd cnts

begin

	{
	   call tbrptr (tp, col_cp[1], cnt_rate, 1, curbin)
	   call tbrptr (tp, col_cp[2], ctrt_err, 1, curbin) 
	   call tbrptr (tp, col_cp[3], exp,      1, curbin)
	   call tbrptr (tp, col_cp[4], src_cnts, 1, curbin)
	   call tbrptr (tp, col_cp[5], bk_cnts,  1, curbin)
	   call tbrptr (tp, col_cp[6], net_cnts,  1, curbin)
	   call tbrptr (tp, col_cp[7], net_err,  1, curbin)
	}
end

# ---------------------------------------------------------------------
#
# Function:     tim_initcol
# Purpose:      initialize table column and return pointer
# Pre-cond:     table file opened
# Post-cond:    column initialized
#
# ---------------------------------------------------------------------
procedure tim_initcol (tp, colname, col_tp)

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
# Function:     tbl_minmax
# Purpose:      retrieve column min & max from table header
# Pre-cond:     table file opened
#
# ---------------------------------------------------------------------
procedure tbl_minmax (tp, column, lims)

pointer tp              # i: table pointer
char    column[ARB]     # i: column name
real    lims[2]         # o: column min & max

pointer col
pointer min_label       # l: column min hdr label
pointer max_label       # l: column max hdr label
pointer sp              # l: allocate space pointer
bool    nullflag[25]
int     i, numrows
real    val             # l: column data in min/max search

int     tbpsta()
real    tbhgtr()

begin

        call smark(sp)
        call salloc (min_label, SZ_LINE, TY_CHAR)
        call salloc (max_label, SZ_LINE, TY_CHAR)

#  Build string of defined header min/max column format
        call strcpy (column, Memc[min_label], SZ_LINE)
        call strcat ("mn", Memc[min_label], SZ_LINE)

        call strcpy (column, Memc[max_label], SZ_LINE)
        call strcat ("mx", Memc[max_label], SZ_LINE)

#   Retrieve min & max header values - search file if values not in hdr
        iferr (lims[1] = tbhgtr (tp, Memc[min_label]) ) {
           numrows = tbpsta (tp, TBL_NROWS)
           call tim_initcol (tp, column, col)
           lims[1] = MAX_REAL
           lims[2] = -MAX_REAL
           do i = 1, numrows {
              call tbrgtr (tp, col, val, nullflag, 1, i)
              if (val < lims[1]) lims[1] = val
              if (val > lims[2]) lims[2] = val
          }
        } else {
           iferr (lims[2] = tbhgtr (tp, Memc[max_label]) ) {
              call error (1,"Inconsistent hdr params MIN and MAX")
           }
        }

        call sfree(sp)

end

