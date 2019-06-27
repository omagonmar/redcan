# $Header: /home/pros/xray/xtiming/addsine/RCS/addtabio.x,v 11.0 1997/11/06 16:44:58 prosb Exp $
# $Log: addtabio.x,v $
# Revision 11.0  1997/11/06 16:44:58  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 19:34:37  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  17:41:46  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:02:30  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:58:40  prosb
#General Release 2.2
#
#Revision 5.2  92/11/09  15:36:28  mo
#Fix comments in header
#

# Revision 5.0  92/10/29  22:50:05  prosb
# General Release 2.1

#Revision 3.0  91/08/02  02:00:18  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  22:40:08  pros
#General Release 1.0
#

# ---------------------------------------------------------------------
#
# Module:	TIMTABIO.X
# Project:	PROS -- ROSAT RSDC
# Purpose:	table file handling for addsine routine
# External:	tim_loadtcol(), tim_gettab()
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1990.  You may do anything you like with this
#		file except remove this copyright
# Modified:	{0} Nathan Kronenfeld initial version April, 90
#		{n} <who> -- <does what> -- <when>
#
# ---------------------------------------------------------------------

include <mach.h>
include <tbset.h>

# ----------------------------------------------------------------------------
#
# Function:	tim_loadtcol
# Purpose:	initialize input table file column pointers and copy the 
#		columns and header to an output table file
#
# ----------------------------------------------------------------------------
procedure tim_loadtcol(tpi,tpo,tpo_nm,ncol,col_cpi,col_cpo,col_nm,clobber)
pointer	tpi				# i: current input table file to read
pointer	tpo				# i: current output table file to read
char	tpo_nm[ARB]			# i: name of output data fiel
int	ncol				# i: number of columns in table file
pointer	col_cpi[ARB]			# o: input file column pointers
pointer	col_cpo[ARB]			# o: output file column pointers
pointer	col_nm[ARB]			# o: column names pointer
bool	clobber				# i: clobber existing files

int	i,j
pointer	sp
pointer	unit				# units for columns
pointer	fmt				# print format of column
int	dtp				# data type of column
int	ldt				# length of column data
int	lft				# length og print format
	
int	tbtacc()
pointer	tbcnum()
pointer	tbtopn()
begin
	call smark(sp)
	call salloc(unit,SZ_COLUNITS,TY_CHAR)
	call salloc(fmt,SZ_COLFMT,TY_CHAR)

	# clobber old output file if it exists
        if ( tbtacc(tpo_nm) == YES )
        {
           if ( clobber == TRUE )
           {
              iferr ( call tbtdel(tpo_nm) )
                 call eprintf("Can't delete old Table\n")
           }
           else
              call eprintf("Table file already exists\n")
        }
        tpo	= tbtopn (tpo_nm, NEW_FILE, 0)


	do i=1,ncol {

	  # find ith column column pointer, and then information about column
	  col_cpi[i]	= tbcnum(tpi,i)
	  call tbcinf(col_cpi[i],j,Memc[col_nm[i]],Memc[unit],Memc[fmt],dtp,
			ldt,lft)

	  # open identical columns in output table
	  call tbcdef(tpo,col_cpo[i],Memc[col_nm[i]],Memc[unit],Memc[fmt],dtp,
			ldt,1)
	}

	# now actually create output table file
	call tbtcre(tpo)

	# copy header
	call tbhcal(tpi,tpo)

	call sfree(sp)
end


# ----------------------------------------------------------------------------
#
# Function:	tim_gettab
# Purpose:	read 1 table row from the file
#
# ----------------------------------------------------------------------------
procedure tim_gettab (curbin, col_cp, ncol, tp, vals, nullvals)
int	curbin				# i: current table row to read
pointer	col_cp[ARB]			# i: column pointers
int	ncol				# i: number of columns
pointer	tp				# i: table pointer
real	vals[ARB]			# o: values in columns to be read
bool	nullvals[ARB]			# o: something else

int	i
begin
	for (i=1;i<=ncol;i=i+1) {
	  call tbrgtr(tp, col_cp[i], vals[i], nullvals[i], 1, curbin)
        }
end
