#$Header: /home/pros/xray/lib/regions/RCS/regnotes.x,v 11.0 1997/11/06 16:19:04 prosb Exp $
#$Log: regnotes.x,v $
#Revision 11.0  1997/11/06 16:19:04  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:26:09  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:44:02  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:07:19  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:38:02  prosb
#General Release 2.2
#
#Revision 5.1  93/04/27  00:02:49  dennis
#Regions system rewrite.
#
#Revision 5.0  92/10/29  21:13:42  prosb
#General Release 2.1
#
#Revision 4.4  92/09/29  20:58:17  dennis
#Freed coordinate transformation structs
#
#Revision 4.3  92/09/08  22:10:34  dennis
#In rg_anote(), correct the comparison of rg_acur with rg_amax.
#
#Revision 4.2  92/08/11  15:32:47  dennis
#In rg_anote1(), polygon case, replaced "cbuf[j] = ' '" with 
#'call strcat(" ", cbuf[j], 1)', to remove possibility of concatenating a 
#run-on cbuf to the rg_astr string.
#Also added the "j < spacesleft" condition to that for loop, to cut off 
#looping through the args once the string buffer is full.
#
#Revision 4.1  92/08/07  17:46:59  dennis
#Prevented overrun of notes string buffers;
#Corrected encoding of polygon notes string (former version always failed);
#Corrected and expanded comments;
#Removed (ineffectual) incorrect initialization of rg_stri.
#
#Revision 4.0  92/04/27  17:19:52  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  91/08/02  10:32:15  mo
#*** empty log message ***
#
#Revision 2.0  91/03/07  00:14:38  pros
#General Release 1.0
#
#

include <regparse.h>
include <qpoe.h>


#
#  RG_NOTE_NEW -- for OP_NEW, extend note string for current region;
#                 if annulus or pie, put its dimensions in note structure, 
#                 and remember having found the annulus or pie
#
procedure rg_note_new(parsing, code, argc, argv)

pointer	parsing			# i: pointer to parsing control structure
int	code            	# i: region type code
int	argc			# i: number of args in argv
real	argv[ARB]		# argument list

pointer	note			# l: pointer to current note structure
char	cbuf[SZ_LINE]		# temp buffer
int	spacesleft		# space available at end of 1-reg note string
int	width			# real parameter field width
int	precision		# real parameter number of significant digits

int	strlen()
int	dtoc()
int	i, j

include "regparse.com"

begin

	# ------------------------------------------------------------------
	# Get the current note structure
	# ------------------------------------------------------------------

	note = LASTONEREGNOTEPTR(parsing)

	# ------------------------------------------------------------------
	# Buffer the shape keyword and its args for this region (in logical 
	#  pixels) in cbuf[]; 
	# If annulus or pie, also store its radii or angles, and remember 
	#  having found an annulus or pie in the descriptor.
	# ------------------------------------------------------------------

	switch ( code ) {
	    case ANNULUS:
		ANNPIEFLAGS(parsing) = or(ANNPIEFLAGS(parsing), ANNFLAG)

		ORN_BEGANN(note) = argv[3]
		ORN_ENDANN(note) = argv[4]

		call sprintf(cbuf, SZ_LINE, "ANNULUS %g %g %g %g ")
		 call pargr(argv[1])
		 call pargr(argv[2])
		 call pargr(argv[3])
		 call pargr(argv[4])

	    case PIE:
		ANNPIEFLAGS(parsing) = or(ANNPIEFLAGS(parsing), PIEFLAG)

		ORN_BEGPIE(note) = argv[3]
		ORN_ENDPIE(note) = argv[4]

		call sprintf(cbuf, SZ_LINE, "PIE %g %g %g %g ")
		 call pargr(argv[1])
		 call pargr(argv[2])
		 call pargr(argv[3])
		 call pargr(argv[4])

	    case CIRCLE:
		call sprintf(cbuf, SZ_LINE, "CIRCLE %g %g %g ")
		 call pargr(argv[1])
		 call pargr(argv[2])
		 call pargr(argv[3])

	    case BOX:
		# (Note: A BOX with a rotation angle has become a ROTBOX 
		#  (via rg_region()).)
		call sprintf(cbuf, SZ_LINE, "BOX %g %g %g %g ")
		 call pargr(argv[1])
		 call pargr(argv[2])
		 call pargr(argv[3])
		 call pargr(argv[4])

	    case ROTBOX:
		call sprintf(cbuf, SZ_LINE, "BOX %g %g %g %g %g ")
		 call pargr(argv[1])
		 call pargr(argv[2])
		 call pargr(argv[3])
		 call pargr(argv[4])
		 call pargr(argv[5])

	    case POINT:
		# (Note that only one point is noted.)
		call sprintf(cbuf, SZ_LINE, "POINT %g %g ")
		 call pargr(argv[1])
		 call pargr(argv[2])

	    case ELLIPSE:
		call sprintf(cbuf, SZ_LINE, "ELLIPSE %g %g %g %g %g ")
		 call pargr(argv[1])
		 call pargr(argv[2])
		 call pargr(argv[3])
		 call pargr(argv[4])
		 call pargr(argv[5])

	    case FIELD:
		call sprintf(cbuf, SZ_LINE, "FIELD ")

	    case POLYGON:
		call sprintf(cbuf, SZ_LINE, "POLYGON ")
		j = 9

		# (It would be possible for a single polygon string to 
		#  overflow our buffers, so we prevent that.)

		# Find out how many spaces are left in the descriptor 
		#  string buffer
		spacesleft = SZ_ONEREGDESC - strlen(ORN_DESCBUF(note))

		for ( i = 1; i <= argc && j <= spacesleft; i = i + 2 ) {
		    width = min(10, spacesleft - j + 1)
		    precision = max(0, width - 1)
		    if (argv[i] < 0 && precision > 0)
			precision = precision - 1
		    if (width > 0) {
			j = j + dtoc(double(argv[i]),   cbuf[j], 0, 
							precision, 'g', width)
		    }
		    if (j <= spacesleft) {
			call strcat(" ", cbuf[j], 1)
			j = j + 1
		    }
		    width = min(10, spacesleft - j + 1)
		    precision = max(0, width - 1)
		    if (argv[i+1] < 0 && precision > 0)
			precision = precision - 1
		    if (width > 0) {
			j = j + dtoc(double(argv[i+1]), cbuf[j], 0, 
							precision, 'g', width)
		    }
		    if (j <= spacesleft) {
			call strcat(" ", cbuf[j], 1)
			j = j + 1
		    }
		}
	}

	# ------------------------------------------------------------------
	# Append to this note structure's descriptor string as much of 
	#  cbuf[]'s contents as will fit.
	# ------------------------------------------------------------------
	call strcat(cbuf, ORN_DESCBUF(note), SZ_ONEREGDESC)

	return
end
