#$Header: /home/pros/xray/xtiming/addsine/RCS/addsine.x,v 11.0 1997/11/06 16:44:57 prosb Exp $
#$Log: addsine.x,v $
#Revision 11.0  1997/11/06 16:44:57  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:34:35  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:41:44  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:02:28  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:58:37  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:50:04  prosb
#General Release 2.1
#
#Revision 3.0  91/08/02  02:00:16  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  22:40:00  pros
#General Release 1.0
#

include	<math.h>
include <tbset.h>

procedure t_addsine()
# parameters:
bool	clobber				# clobber existing files?
double	pamp				# portion of average value of column
					# to use as amplitude
			# other sine wave parameters are in units of 2 pi
			# radians (i.e. 2 units makes one full circle)
double	phase				# phase of added sine wave
double	period				# period of added sine wave
int	display				# display level
pointer	tblinnm				# name of input table file
pointer	tbloutnm			# name of output table file
pointer	tcolnm				# table column name
pointer	tcolnms				# names of all columns

# other variables:
double	amp				# amplitude of added sine wave
double	sum				# sum of values in a column

int	colnum				# number of column to change
int	cols				# number of columns in table file
int	rows				# number of rows in table file
int	i

pointer	sp
pointer bfr				# general print buffer
pointer	cptri				# pointer to input table columns
pointer	cptro				# pointer to output table columns
pointer	nullvals			# record of which columns undefined
pointer	tempnm				# temporary file name for clobber
pointer	tpi				# input table file
pointer	tpo				# output table file
pointer	vals				# row values

# valued functions used:
bool	clgetb()			# get boolean-valued parameter
double	clgetd()			# get double-valued parameter
int	clgeti()			# get integer-valued parameter
bool	streq()				# string equals function
int	tbpsta()			# table function to get file info
pointer	tbtopn()			# table open function
begin
	call smark(sp)
	call salloc(tblinnm, SZ_PATHNAME,TY_CHAR)
	call salloc(tbloutnm,SZ_PATHNAME,TY_CHAR)
	call salloc(tempnm,  SZ_PATHNAME,TY_CHAR)
	call salloc(tcolnm,  SZ_LINE,    TY_CHAR)
	call salloc(bfr,     SZ_LINE,    TY_CHAR)

	# get sine wave parameters and some other parameters
	pamp	= clgetd("per_amplitude")
	period	= clgetd("period")
	phase	= clgetd("phase")
	display	= clgeti("display")
	clobber	= clgetb("clobber")

	# find out which column to which to add sine wave
	call clgstr("column",Memc[tcolnm],SZ_LINE)
	if (streq("NONE", Memc[tcolnm]) || streq("",Memc[tcolnm])) {
	  call error(1,"Requires column to which to add sine wave")
	}

	# get input and output table file names
	call clgstr("intable", Memc[tblinnm], SZ_PATHNAME)
	call clgstr("outtable",Memc[tbloutnm],SZ_PATHNAME)

	# check names of files to use to see if they are reasonable
	if (streq("NONE",Memc[tblinnm]) || streq("NONE",Memc[tblinnm])) {
	  call error(1,"requires a table file as input")
	}		# need input file name
	if (streq("NONE",Memc[tbloutnm]) || streq("NONE",Memc[tbloutnm])) {
	  call rootname(tblinnm,tbloutnm,"_asn.tbl",SZ_PATHNAME)
	}		# base output file name on input file name if missing
	if (display >= 5) {
	  call printf("Using file %s as input.\n")
	   call pargstr(Memc[tblinnm])
	}
	# get the output table file name
	call clobbername(Memc[tbloutnm],Memc[tempnm],clobber,SZ_PATHNAME)

	# open the input table file
	tpi	= tbtopn(Memc[tblinnm], READ_ONLY, 0)	# input table file
	if (tbpsta(tpi, TBL_NROWS) <= 0) {		# make sure table
	  call error(1,"Table File empty!!")		# file OK
	}

	# get input file info
	cols =	tbpsta(tpi, TBL_NCOLS)		# total number of colums
	rows =	tbpsta(tpi, TBL_NROWS)		# total number of rows
	#if (cols != TM_NUMCLS) {
	#  call error(1,"temporary error only: not a timing table file")
	# }

	call salloc(cptri,cols,TY_POINTER)	# place to store all column 
	call salloc(cptro,cols,TY_POINTER)	# pointers of tables
	call salloc(vals,cols,TY_REAL)		# and their values
	call salloc(nullvals,cols,TY_BOOL)	# and something else
	call salloc(tcolnms,cols,TY_POINTER)	# and column name array
	for (i=0;i<cols;i=i+1)			# and individual names
	  call salloc(Memi[tcolnms+i],SZ_COLNAME)

	# get column pointers for all columns
	call tim_loadtcol(tpi,tpo,Memc[tbloutnm],cols,Memi[cptri],Memi[cptro],
				Memi[tcolnms],clobber)
	colnum	= 0				# find out which column will
	for (i=0;i<cols;i=i+1) {		# be used for the sine wave
	  if (streq(Memc[tcolnm],Memc[Memi[tcolnms+i]])) {
	    colnum	= i+1
	  }
	}
	if (colnum == 0) {
	  call sprintf(Memc[bfr],SZ_LINE,
			"Couldn't find column %s in table %s.")
	   call pargstr(Memc[tcolnm])
	   call pargstr(Memc[tempnm])
	  call error(2,Memc[bfr])
	}
	if (display >= 5) {
	  call printf("Column  %s is %d.\n")
	   call pargstr(Memc[tcolnm])
	   call pargi(colnum)
	}

	# get average value for chosen column
	sum	= 0.0
	for (i=1;i<=rows;i=i+1) {
	  call tbrgtr(tpi,Memi[cptri+colnum-1],Memr[vals],Memb[nullvals],1,i)
	  sum	= sum + double(Memr[vals])
	}
	amp	= pamp * (sum / double(rows))
	if (display >= 3) {
	  call printf("Average value for column %s is %f.\n")
	   call pargstr(Memc[tcolnm])
	   call pargd(sum)
	}
	if (display >= 5) {
	  call printf("Equation of added sine wave:\n")
	  call printf("  %.4f x SIN(2 PI ( T / %.4f + %.4f ) )\n")
	   call pargd(amp)
	   call pargd(period)
	   call pargd(phase)
	}

	# add new header information
	call tbhadt(tpo,"","")
	call tbhadt(tpo,"ADDINFO","This Info reflects run of addsine task:")
	call tbhadt(tpo,"COLCHNG",Memc[tcolnm])
	call tbhadd(tpo,"AMPADD",amp)
	call tbhadd(tpo,"PERADD",period)
	call tbhadd(tpo,"PHAADD",phase)

	# do actual adding and print to output table
	for (i=1;i<=rows;i=i+1) {
	  call tim_gettab (i,Memi[cptri],cols,tpi,Memr[vals],Memb[nullvals])
	  Memr[vals+colnum-1]	= double(Memr[vals+colnum-1]) + amp *
				sin(2 * PI * (double(i)/period + phase))
	  call tim_filltab(i,Memi[cptro],     tpo,Memr[vals],Memr[vals+1],
			Memr[vals+2],Memr[vals+3],Memr[vals+4],Memr[vals+5],
			Memr[vals+6])
	}

	call tbtclo (tpo)

	call sfree(sp)
end
