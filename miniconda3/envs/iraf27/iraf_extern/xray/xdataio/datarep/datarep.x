#$Header: /home/pros/xray/xdataio/datarep/RCS/datarep.x,v 11.0 1997/11/06 16:33:55 prosb Exp $
#$Log: datarep.x,v $
#Revision 11.0  1997/11/06 16:33:55  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:57:34  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:18:34  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:37:43  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:23:21  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:35:52  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  15:00:13  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:12:15  prosb
#General Release 1.1
#
#Revision 2.1  91/07/21  19:26:42  mo
#MC	7/21/91		Remove the task statement
#
#Revision 2.0  91/03/06  23:35:51  pros
#General Release 1.0
#
# datarep.x
#
# the main task for data representation conversion.
#    move this to package file
#task datarep = t_datarep


# Supported formats and thier input keywords
#
#
define	FORMATS		"|ieee|dg|vax|sun|host|text"

define	IEEE	1
define	DG	2
define	VAX	3
define	SUN	4
define	HOST	5



procedure t_datarep()
#--

int	template, in, out

pointer	ifile, ofile, xfile, tfile			# pointers to names
pointer	iformat, oformat

int	ifmt, ofmt
bool	clobber

string	format FORMATS

pointer	code, datacom()
int	clgwrd(), open()
pointer	sp
bool	clgetb()

begin
	call smark(sp)
	call salloc(iformat, SZ_FNAME, TY_CHAR)
	call salloc(oformat, SZ_FNAME, TY_CHAR)
	call salloc(ifile,   SZ_FNAME, TY_CHAR)
	call salloc(ofile,   SZ_FNAME, TY_CHAR)
	call salloc(xfile,   SZ_FNAME, TY_CHAR)
	call salloc(tfile,   SZ_FNAME, TY_CHAR)

	call clgstr("input",    Memc[ifile], SZ_FNAME)
	call clgstr("output",   Memc[ofile], SZ_FNAME)
	call clgstr("template", Memc[tfile], SZ_FNAME)

	clobber = clgetb ("clobber")
	call clobbername(Memc[ofile], Memc[xfile], clobber, SZ_FNAME)

	ifmt = clgwrd("iformat", Memc[iformat], SZ_FNAME, format)
	ofmt = clgwrd("oformat", Memc[oformat], SZ_FNAME, format)

	if ( ifmt == 0 ) {
		call printf("Unknown format %s\n")
		 call pargstr(Memc[iformat])
		 call flush(STDOUT)
		call error(1, "Datarep bad input format")
	}

	if ( ofmt == 0 ) {
		call printf("Unknown format %s\n")
		 call pargstr(Memc[oformat])
		 call flush(STDOUT)
		call error(1, "Datarep bad output format")
	}


	call datainit()		# init the datarep symbol table


	# Now add the format specific symbols
	#
	##

define	CROSS	( $1 * 16 + $2 )

define	IEEExHOST	21
define	DGxHOST		37
define	VAXxHOST	53
define	SUNxHOST	69

define	VAXxIEEE	49
define	VAXxSUN		52

define	HOSTxTXT	86

	switch ( CROSS(ifmt, ofmt) ) {
	 case SUNxHOST, IEEExHOST:		call iee2host()
	 case VAXxHOST:				call vax2host()
	 case  DGxHOST:				call dg2host()

	 case VAXxIEEE, VAXxSUN:		call vax2iee()

	 case HOSTxTXT:				call hst2txt()

	 default:
		call printf("Don't know how to convert %s to %s\n")
		 call pargstr(Memc[iformat])
		 call pargstr(Memc[oformat])
		 call flush(STDOUT)
		call error(1, "Datarep bad formats")
	}

	# open files

	in  = open(Memc[ifile], READ_ONLY, BINARY_FILE)
	out = open(Memc[xfile], NEW_FILE,  BINARY_FILE)

	template = open(Memc[tfile], READ_ONLY, TEXT_FILE)

	code = datacom(template)
	if ( code != NULL ) call datarun(code, in, out)

	call datazap(code)

	call close(in)
	call close(out)
	call close(template)

	call finalname(Memc[xfile], Memc[ofile])
	call sfree(sp)
end
