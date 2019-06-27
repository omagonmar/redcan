#$Header: /home/pros/xray/xtiming/timplot/RCS/timtabio.x,v 11.0 1997/11/06 16:44:53 prosb Exp $
#$Log: timtabio.x,v $
#Revision 11.0  1997/11/06 16:44:53  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:34:25  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:41:23  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:02:13  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:58:19  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:49:47  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  15:34:54  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  91/08/02  14:33:33  mo
#MC	8/2/91		Fix name conflict by renaming tim_minmax to 
#			tbl_minmax
#			This came from package restructuring
#
#Revision 2.0  91/03/06  22:51:47  pros
#General Release 1.0
#
# ---------------------------------------------------------------------
#
# Module:	TIMTABIO.X
# Project:	PROS -- ROSAT RSDC
# Purpose:	table file handling
# External:	tim_initcol(), tbl_minmax()
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989.  You may do anything you like with this
#		file except remove this copyright
# Modified:	{0} Janet DePonte initial version July 1989
#		{n} <who> -- <does what> -- <when>
#
# ---------------------------------------------------------------------

include <mach.h>
include <tbset.h>

# ---------------------------------------------------------------------
#
# Function:	tim_initcol 
# Purpose:      initialize table column and return pointer 
# Pre-cond:     table file opened	
# Post-cond:	column initialized
#
# ---------------------------------------------------------------------
procedure tim_initcol (tp, colname, col_tp)

pointer tp			# i: table handle
char    colname[ARB]		# i: data column name
pointer col_tp			# o: position table column pointers

pointer buff			# l: local string buffer
pointer sp			# l: stack pointer

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
# Function:	tbl_minmax
# Purpose:      retrieve column min & max from table header
# Pre-cond:     table file opened	
#
# ---------------------------------------------------------------------
procedure tbl_minmax (tp, column, lims)

pointer	tp		# i: table pointer
char    column[ARB]	# i: column name
real    lims[2]		# o: column min & max

pointer col
pointer min_label	# l: column min hdr label
pointer max_label	# l: column max hdr label
pointer sp   		# l: allocate space pointer
bool    nullflag[25]
int     i, numrows
real    val		# l: column data in min/max search

int     tbpsta()
real	tbhgtr()

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
