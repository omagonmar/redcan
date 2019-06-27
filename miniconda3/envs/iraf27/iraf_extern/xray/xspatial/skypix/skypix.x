#$Header: /home/pros/xray/xspatial/skypix/RCS/skypix.x,v 11.0 1997/11/06 16:32:46 prosb Exp $
#$Log: skypix.x,v $
#Revision 11.0  1997/11/06 16:32:46  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:52:07  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:14:38  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:35:35  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:20:05  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:33:52  prosb
#General Release 2.1
#
#Revision 4.1  92/09/08  17:49:23  mo
#MC	9/8/92		Add message to termination of input lists
#
#Revision 4.0  92/04/27  14:40:56  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:52:22  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:13:19  pros
#General Release 1.0
#
# Module:       SKYPIX
# Project:      PROS -- ROSAT RSDC
# Purpose:      Front end for Precess and MWCS ( world coordinates)
# External:     skypix
# Local:        all others
# Description:  The skypix help file describes all the coordniate
#		transformations allowed by accessing the MWCS ( world
#		coordinate system of the input image files
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} JR    --  initial version Nov 89
#               {1} MC    --  Fixed the IMAGE option by replacing the
#			      call to wcs2str with a simple strcpy   -- 2/13/91
#

include <math.h>
include	<fset.h>
include <qpoe.h>
include <ctype.h>

include <precess.h>

procedure t_skypix()
#--

char	fname[SZ_LINE]			# The current input file name
char 	outfile[SZ_LINE]		# The output file
char	tempname[SZ_LINE]		# The temporary output file.
char	istr[SZ_LINE]			# The full input csystem string
char	ostr[SZ_LINE]			# The full output csystem string
char 	ifstr[20]			# The full input format string
char 	ofstr[20]			# The full output format string

int	inlist				# The input file list descriptor
int	icsystem, ocsystem		# Inout coord system indexes
double	iequix, oequix
double	iepoch, oepoch			# Inout epoch 
int 	ifn, ofn			# Inout format index
int 	out				# Out file descriptors
bool	clobber				# Trash existing files?
int	display
int	i

pointer	ict, oct

int	clpopni(), clgfil(), clgeti(), clgwrd()
bool	streq(), clgetb()
int	open()

begin
	clobber = clgetb("clobber")
        call fseti(STDERR, F_FLUSHNL, YES)

	display = clgeti("display")

	call parsect("isystem", istr, ict, icsystem, iequix, iepoch)
	call parsect("osystem", ostr, oct, ocsystem, oequix, oepoch)
	
	# Check and set default image coordinate transfer
	#
	if ( icsystem == IMAGE )
	    if ( oct == NULL ) call error(1, "Image coordinate default without reference image\n")
	    else {
		icsystem = ocsystem
		iequix	 = oequix
		iepoch	 = oepoch
#	    	call str2wcs(NULL, icsystem, mw, iequix, iepoch, istr)
		call strcpy(ostr,istr,SZ_LINE)
	    }

	if ( ocsystem == IMAGE )
	    if ( ict == NULL ) call error(1, "Image coordinate default without reference image\n")
	    else {
		ocsystem = icsystem
		oequix	 = iequix
		oepoch	 = iepoch
#	    	call str2wcs(NULL, ocsystem, mw, oequix, oepoch, ostr)
		call strcpy(istr,ostr,SZ_LINE)
	    }

	inlist = clpopni("ifile")
	call clgstr("ofile", outfile, SZ_LINE)
	call clobbername(outfile, tempname, clobber, SZ_LINE)
  	out = open(tempname, NEW_FILE, TEXT_FILE)

define	DEGREES	1
define  HOURS	2
define 	RADIANS	3
define	PIXELS	4

	# Get the input/output units type
	#
	if ( ict == NULL ) {
	    ifn = clgwrd("iformat", ifstr, 20, "|degrees|hours|radians|")
	    if ( ifn == 0 )
	    	call error(1, "invalid input format specification") 
	} else {
	    call strcpy("pixels", ifstr, 20)
	    ifn = PIXELS
	}

	if ( oct == NULL ) {
	    ofn = clgwrd("oformat", ofstr, 20, "|degrees|hours|radians|")
	    if ( ofn == 0 )
	    	call error(1, "invalid output format specification") 
	} else {
	    call strcpy("pixels", ofstr, 20)
	    ofn = PIXELS
	}

	# Tell the user what is going on.
	#
	if ( display >= 1 ) {
	    call eprintf("\nConverting from %22s");	call pargstr(istr)
	    call eprintf(" in %s\n");			call pargstr(ifstr)
	    call eprintf("             to %22s");	call pargstr(ostr)
	    call eprintf(" in %s\n\n");			call pargstr(ofstr)
	}

	# Tell the file what is going on
	#
	if ( !streq(outfile, "STDOUT") ) {
	    if ( display >= 1 ) {
		call fprintf(out, "# Xray.Skypix output file\n#\n")
		call fprintf(out, "# from ");

		for ( i = 1; istr[i] != '\0'; i = i + 1 ) 
			if ( istr[i] == '\n' )
				call fprintf(out, "\n#");
			else {  call fprintf(out, "%c");  call pargc(istr[i]) }

		call fprintf(out, " in %s\n");		call pargstr(ifstr)
		call fprintf(out, "#   to ");

		for ( i = 1; ostr[i] != '\0'; i = i + 1 ) 
			if ( ostr[i] == '\n' )
				call fprintf(out, "\n#");
			else {  call fprintf(out, "%c");  call pargc(ostr[i]) }

		call fprintf(out, " in %s\n#\n# ");	call pargstr(ofstr)
	    }

	    if ( display >= 2 ) {
		if ( ict == NULL ) {
		    switch ( icsystem ) {
	    	    case FK4, FK5, J2000, B1950 :
		    	call fprintf(out, "Right Ascention     Declination         ")
		    case ECL, GAL, SGL:
		    	call fprintf(out, "Longitude           Latitude            ")
		    default:
		    	call error(1, "Bad case in header print switch")
	            }
	    	} else	call fprintf(out, "X                   Y                   ")
	    }
	    if ( display >= 1 ) {
	    	if ( oct == NULL ) {
		    switch ( ocsystem ) {
	    	    case FK4, FK5, J2000, B1950 :
		    	call fprintf(out, "Right Ascention     Declination")
		    case ECL, GAL, SGL:
		    	call fprintf(out, "Longitude           Latitude")
		    default:
		    	call error(1, "Bad case in header print switch")
	            }
	        } else    call fprintf(out, "X                   Y")
	    }
	    call fprintf(out, "\n#\n")
	}

	 if( display >= 1){
		call printf("\n(Terminate interactive list with <cntl>-D)\n")
		call flush(STDOUT)
	}

        # Process each coordinate list.  If reading from the standard input,
        # set up the standard output to flush after every output line, so that
        # precessed coords come back immediately when working interactively.

        while ( clgfil(inlist, fname, SZ_LINE) != EOF) {

            if ( ( streq(fname, "STDIN") ) && ( streq(outfile, "STDOUT")) ) {
                call fseti(STDOUT, F_FLUSHNL, YES)
            } else {
                call fseti(STDOUT, F_FLUSHNL, NO)
	    }

            call precess_list(fname, out,
                ict, icsystem, iequix, iepoch, 
		oct, ocsystem, oequix, oepoch,
		ifn, ofn, display)
        }

        call clpcls(inlist)
	call close(out)
	call finalname(tempname, outfile)
end



# PRECESS_LIST -- Precess a list of coordinates read from the stream
# fname, writing the results on the output file.

procedure precess_list(fname, out, ict, icsystem, iequix, iepoch, 
				   oct, ocsystem, oequix, oepoch, ifn, ofn, display)

char	fname[ARB]
int     out                                     # output stream
pointer	ict					# input coords system
int	icsystem
double	iequix
double	iepoch
pointer	oct					# output coords system
int	ocsystem
double	oequix
double	oepoch
int	ifn					# i: output format
int	ofn
int	display
#--

int     in                                      # input stream

real	x, y					# original x,y
double	tx, ty					# transformed x, y
real	rx, ry

char	line[80]

int	n
int	nargs

char	istring[SZ_LINE]
char	ostring[SZ_LINE]

bool	streq()
int     fscan(), nscan(), open()

begin



  	in = open (fname, READ_ONLY, TEXT_FILE)
	n = 0

        # Read successive coordinate pairs from the standard input,
        # precessing and printing the result on the standard output.

        while ( fscan(in) != EOF ) {
            call gargr(x)
            call gargr(y)
	    call gargstr(line, 80)

	    tx = x;  ty = y;	    n = n + 1;

	    switch ( ifn ) {
	    case DEGREES :
	    case HOURS	 :
		tx = tx * 15
	    case RADIANS : 
		tx = RADTODEG(tx)
		ty = RADTODEG(ty) 
	    case PIXELS :
	    default:
		call error(1, "Bad case in iformat switch\n")
	    }


            # If something is wrong with the input coords, print warning, skip
	    #
	    nargs = nscan()
            if( nargs < 2  ) {
	      if( nargs > 0 ){
		call eprintf("Bad entry in coordinate list file: %s")
		 call pargstr(fname)
		call eprintf(" on line %d\n")
		 call pargi(n)
	      }
              next
	    }

            # translate + precess
	    #
	    if ( ict != NULL ) {
		if ( display >= 3 ) call eprintf("Convert image pixels to sky coordinates\n")
		call mw_c2trand(ict, tx, ty, tx, ty, 0) 
	    }

            call precess(tx, ty, icsystem, iequix, iepoch,
			 tx, ty, ocsystem, oequix, oepoch, display)

	    if ( oct != NULL ) {
		if ( display >= 3 ) call eprintf("Convert sky coordinates to image pixels\n")
		call mw_c2trand(oct, tx, ty, tx, ty, 0)
	    }

	    # Print stuff for the user
	    #
	    if ( display > 1 ) {

		call clgstr("istring", istring, SZ_LINE)
		if ( streq(istring, "NONE") ) {
		    switch ( ifn ) {
		    case DEGREES, PIXELS :
			call fprintf(out, "  %-18g  %-18g")
		    case HOURS   :
			call fprintf(out, "  %-18h  %-18h")
		    case RADIANS :
			call fprintf(out, "  %-18g  %-18g")
		    default:
		    }
		} else
			call fprintf(out, istring)

                call pargr(x)
                call pargr(y)
	    }

	    call clgstr("ostring", ostring, SZ_LINE)
	    if ( streq(ostring, "NONE") ) {
	        switch ( ofn ) {
	    	case DEGREES, PIXELS:
		    call fprintf(out, "  %-18g  %-18g")
	    	case HOURS 	:
		    if ( display >= 4 ) call eprintf("Convert degrees to HMS DMS\n")
		    tx = tx / 15
		    call fprintf(out, "  %-18h  %-18h")
	    	case RADIANS :
		    if ( display >= 4 ) call eprintf("Convert degrees to radians\n")
		    tx = DEGTORAD(tx)
		    ty = DEGTORAD(ty)
		    call fprintf(out, "  %-18g  %-18g")
	    	default:
		    call error(1, "Bad case in oformat switch")
		}
	    } else
		    call fprintf(out, ostring)

	    rx = tx				# Cast down to real
	    ry = ty

            call pargr(rx)
            call pargr(ry)

	    call fprintf(out, "%s\n")
	     call pargstr(line)

	}
end




procedure parsect(name, ostring, ct, system, equix, epoch)

char	name[ARB]
char	ostring[ARB]
pointer	ct
int	system
double	equix
double	epoch

#--

char	str[132]

bool	streq()
pointer	mw, mw_sctran()

begin

	call clgstr(name, str, SZ_LINE)

	call str2wcs(str, ostring, mw, system, equix, epoch)

	if ( mw != NULL )
	    if ( streq(name, "isystem" ) )
		ct = mw_sctran(mw, "logical", "world", 3)
	    else 
		ct = mw_sctran(mw, "world", "logical", 3)
	else
	    ct = NULL
end



