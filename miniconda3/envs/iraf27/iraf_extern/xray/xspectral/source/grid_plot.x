#$Header: /home/pros/xray/xspectral/source/RCS/grid_plot.x,v 11.0 1997/11/06 16:42:16 prosb Exp $
#$Log: grid_plot.x,v $
#Revision 11.0  1997/11/06 16:42:16  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:29:47  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:31:50  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:55:36  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:50:29  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:44:32  prosb
#General Release 2.1
#
#Revision 4.1  92/08/14  14:16:00  prosb
#jso - quick change to get the question mark to work.
#
#Revision 4.0  92/04/27  18:15:11  prosb
#General Release 2.0:  April 1992
#
#Revision 3.3  92/03/19  14:39:50  orszak
#jso - commented out absorption printout.  see ipros_archive 19 mar 92.
#
#Revision 3.2  91/09/22  19:06:06  wendy
#Added
#
#Revision 3.1  91/08/26  15:02:37  mo
#MC	8/26/91		Fixed missing parameter in gtext call
#			caused fatal error when compiled under Fortran 1.4
#
#Revision 3.0  91/08/02  01:58:22  prosb
#General Release 1.1
#
#Revision 2.1  91/07/12  16:14:51  prosb
#jso - made spectral.h system wide and add calls to open new pset parameter
#
#Revision 2.0  91/03/06  23:03:38  pros
#General Release 1.0
#
# Project:      PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
#
#  main routine for task which plots the Chi-square grid results.
#
# John : Dec 89
#	Added interpolation routine.
#	Added extrapolation routine.
#	Futzed with the output of x, y axis titles and legends
#
 
include  <gset.h>
include  <pkg/gtools.h>
include  <ext.h>
include  <spectral.h>

# grid plot structure
define  LEN_GP            7
define  GR_FILES	  Memi[($1)+0]
define  GR_IMODEL	  Memi[($1)+1]
define  GR_BMODEL	  Memi[($1)+2]
define  GR_ABS		  Memi[($1)+3]
define  GR_BESTCHISQ      Memr[($1)+4]
define  GR_BEST_X         Memr[($1)+5]
define  GR_BEST_Y         Memr[($1)+6]

define CHISQ_NO_LEVELS	"number_of_levels"
define XPLOT_SIZE	"xplotsize"
define YPLOT_SIZE	"yplotsize"
define GRIDFILE        "grid"
define DEVICE          "device"
define TITLE		"plot_title"
define XTITLE		"x_axis_title"
define YTITLE		"y_axis_title"
define CURSOR		"cursor"
define FILES		"ifiles"
define IMODEL		"fitmodel"
define BMODEL		"best"
define ABS		"abs"

define  MARK_SIZE	(2.0)
define  LINE_HEIGHT	(0.09)


# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
#  This procedure plots the Chi-square grid with contour levels.

procedure  t_pltgrid ()

pointer	 gp				# graphics pointer
pointer	 sp				# stack pointer
pointer	 np				# parameter pointer
pointer	 x				# X axis data structure
pointer	 y				# Y axis data structure
pointer	 gr				# grid structure
pointer	 chisq_array			# grid data array
pointer	 device				# device name for plotting output
pointer  gridfile			# name of file with grid data
pointer	 root

pointer	plot_array		# interpolation array and size
int	xplotsize
int	yplotsize
int	do_polate

pointer	 title
pointer	xtitle			# X axis title # Life is really to short to 
pointer	ytitle			# Y axis title # worry about things like this

real	x_limits[2]
real	y_limits[2]

real	best_chisq
int	nlevels
real	levels[3]
real	confidences[3]

pointer gopen()
bool	get_grid()
int	clgeti()
real	clgetr()
int	label
real	wx,  wy				# world coordinates
int	wcs				# world coordinate system
int	key				# response key
char	str[SZ_CUR_RESPONSE]		# cursor command string

int     clgcur()
pointer clopset()

begin
	call smark ( sp )
	np = clopset("pkgpars")
	call salloc ( device,   SZ_FNAME, TY_CHAR )
	call salloc ( root,   SZ_FNAME, TY_CHAR )
	call salloc ( gridfile, SZ_LINE, TY_CHAR )
	call salloc ( title, SZ_LINE, TY_CHAR )
	call salloc ( xtitle, SZ_LINE, TY_CHAR )
	call salloc ( ytitle, SZ_LINE, TY_CHAR )

	xplotsize = clgeti( XPLOT_SIZE ) 
	yplotsize = clgeti( YPLOT_SIZE ) 
	call salloc ( plot_array, xplotsize * yplotsize, TY_REAL )

	call clgstr ( GRIDFILE, Memc[gridfile], SZ_FNAME )
	call rootname("", Memc[gridfile], EXT_GRD, SZ_FNAME)

	# Fetch plot titles
	#
	call clgstr (TITLE ,  Memc[title], SZ_PLOT_TITLE)
	call clgstr (XTITLE, Memc[xtitle], SZ_AXIS_TITLE)
	call clgstr (YTITLE, Memc[ytitle], SZ_AXIS_TITLE)

	# Fetch the data from the table file or Die
	#
	if( !get_grid(gridfile, x, y, xtitle, ytitle,
	    gr, chisq_array ) )  {
	    call printf( " Could not find the Chi-squared data grid.\n" )
	    call printf( " You need to run the grid_search task.\n" )
	    call error(1, "grid_plot")
	}

#	call fnroot(Memc[GR_FILES(gr)], Memc[root], SZ_FNAME)

	# Start up the graphics
	#
	call clgstr ( DEVICE, Memc[device], SZ_FNAME )
	gp = gopen( Memc[device], NEW_FILE, STDGRAPH )


	# Compute axis limits
	#
	if( GS_AXISTYPE(x) == LINEAR_AXIS )  {
	    x_limits[1] = GS_PAR_VALUE(x) - GS_DELTA(x)
	    x_limits[2] = GS_PAR_VALUE(x) + GS_DELTA(x)
	} else  {
	    x_limits[1] = GS_PAR_VALUE(x) / GS_DELTA(x)
	    x_limits[2] = GS_PAR_VALUE(x) * GS_DELTA(x)
	}
        if( GS_AXISTYPE(y) == LINEAR_AXIS )  {
            y_limits[1] = GS_PAR_VALUE(y) - GS_DELTA(y)
            y_limits[2] = GS_PAR_VALUE(y) + GS_DELTA(y)
        } else  {
            y_limits[1] = GS_PAR_VALUE(y) / GS_DELTA(y)
            y_limits[2] = GS_PAR_VALUE(y) * GS_DELTA(y)
        }

	# Compute the contour levels
	#
	best_chisq = GR_BESTCHISQ(gr)
	nlevels = clgeti(CHISQ_NO_LEVELS)

	confidences[1] = clgetr("level_delt_1")
	confidences[2] = clgetr("level_delt_2")
	confidences[3] = clgetr("level_delt_3")

	levels[1] = best_chisq + confidences[1]
	levels[2] = best_chisq + confidences[2]
	levels[3] = best_chisq + confidences[3]

	do_polate = clgeti("interpolate")
	if ( do_polate == 1 ) 
	    call interpolate(GS_STEPS(x), GS_STEPS(y), Memr[chisq_array],
			  xplotsize, yplotsize, Memr[plot_array])

	label = YES
	key = 'r'

	repeat { 

	    if ( key == 'q' )				#case quit
		break

	    # Set up graphics 
	    #
	    call gclear(gp)
	    if ( GS_AXISTYPE(x) == LINEAR_AXIS ) call gxlin(gp)
	    else				 call gxlog(gp)
            if ( GS_AXISTYPE(y) == LINEAR_AXIS ) call gylin(gp)
            else				 call gylog(gp)

	    # Set up options
	    #
	    switch ( key ) {
	    case 'l':
		if ( label == YES ) label = NO
		else		    label = YES

	    # case info on keystrokes
	    case '?':
		call gpagefile (gp, "xspectral$grid_plot.key", "")

	    case 'r':
			# ReDraw 
	    default:
		next;
	    }

	    # Execute options and grid			This need for 3 if's on
	    #						label is really beat.
	    if ( label == YES ) {
		call gsetr(gp, G_TXSIZE, 0.7)
		call gfile_label (gp, Memc[GR_FILES(gr)])
		call gsetr(gp, G_TXSIZE, 1.0)
	    }

	    call gswind(gp, x_limits[1], x_limits[2], y_limits[1], y_limits[2])

	    if ( label == YES ) {
		call gsview(gp, .15, .85, .23, .94)
		call grid_label(gp, x, y, gr)
		call glabax(gp, Memc[title], Memc[xtitle], Memc[ytitle])
	    } else {
		call gsview(gp, .15, .85, .15, .94)
   	    	call glabax (gp, "", Memc[xtitle], Memc[ytitle])
	    }

	    if ( label == YES )
	        call grid_legend(gp, x, y, gr, nlevels, levels)

	    call gmark(gp, GR_BEST_X(gr), GR_BEST_Y(gr),
		       GM_CROSS, MARK_SIZE, MARK_SIZE)

	    if ( do_polate == 1 )
	        call draw_grid(gp, x, y, gr, x_limits, y_limits,
			   nlevels, levels,
			   xplotsize, yplotsize, plot_array)
	    else
	        call draw_grid(gp, x, y, gr, x_limits, y_limits,
			   nlevels, levels,
			   GS_STEPS(x), GS_STEPS(y), chisq_array)
	
	    call gflush(gp)

	} until( clgcur(CURSOR, wx, wy, wcs, key, str, SZ_CUR_RESPONSE) == 
			 EOF )

	call gclose(gp)
	call clcpset(np)
	call sfree(sp)
end

# 
#  ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----

bool  procedure  get_grid( gridfile, x, y, xtitle, ytitle,
			   gr, chisq_array)

pointer	gridfile			# i: grid data file
pointer	x				# o: X axis data structure
pointer	y				# o: Y axis data structure
pointer	xtitle				#io: X axis title
pointer	ytitle				#io: Y axis title
pointer	gr				# o: grid plot structure
pointer	chisq_array			# o: grid data

char	cbuf[SZ_LINE]			# l: temp char buffer
char	tbuf[20]			# l: temp char buffer
int	v, h				# l: grid indices
pointer	tp				# l: table handle
pointer	cp				# l: column pointers
bool	response			# l: flag if we found the file
bool	junk				# l: from match_name

int	emission_val()			# l: get emission id from nane
int	tbtacc()			# l: check for table existence
int	tbhgti()			# l: get int table param
pointer	tbtopn()			# l: open a table file
real	tbhgtr()			# l: get real table param
bool	streq()				# l: string compare

begin
	# the smark was done by the calling routine
	# (its a bit weird, but I am too tired to mess with Adam's code!)
	call salloc(x, LEN_GS_AXIS, GS_AXIS_TYPE)
	call salloc(y, LEN_GS_AXIS, GS_AXIS_TYPE)
	call salloc(gr, LEN_GP, TY_STRUCT)
	call salloc(GR_FILES(gr), SZ_LINE, TY_CHAR)
	call salloc(GR_IMODEL(gr), SZ_LINE, TY_CHAR)
	call salloc(GR_BMODEL(gr), SZ_LINE, TY_CHAR)
	call salloc(GR_ABS(gr), SZ_LINE, TY_CHAR)

	# look for the table file
	if( tbtacc( Memc[gridfile], READ_ONLY, TEXT_FILE ) == YES )  {
	    # found it!
	    response = TRUE
	    # open a new table	
	    tp = tbtopn(Memc[gridfile], READ_ONLY, 0)

	    # get info about the grid search
	    call tbhgtt(tp, FILES, Memc[GR_FILES(gr)], SZ_LINE)
	    call tbhgtt(tp, IMODEL, Memc[GR_IMODEL(gr)], SZ_LINE)
	    call cr_to_semi(Memc[GR_IMODEL(gr)])
	    call tbhgtt(tp, BMODEL, Memc[GR_BMODEL(gr)], SZ_LINE)
	    call cr_to_semi(Memc[GR_BMODEL(gr)])
	    call tbhgtt(tp, ABS, Memc[GR_ABS(gr)], SZ_LINE)
	    GR_BESTCHISQ(gr) = tbhgtr(tp, "best_chi")
	    GR_BEST_X(gr) = tbhgtr(tp, "best_x")
	    GR_BEST_Y(gr) = tbhgtr(tp, "best_y")

	    # get x-axis information
	    GS_STEPS(x) = tbhgti(tp, "x_steps")
	    GS_PAR_VALUE(x) = tbhgtr(tp, "x_val")
	    GS_DELTA(x) = tbhgtr(tp, "x_delta")
	    call tbhgtt(tp, "x_model", cbuf, SZ_LINE)
	    GS_MODELTYPE(x) = emission_val(cbuf)
	    if ( streq("", Memc[xtitle]) )	# see if we use defaults
	         call tbhgtt(tp, "x_param", Memc[xtitle], SZ_LINE)
	    call tbhgtt(tp, "x_axistype", cbuf, SZ_LINE)
	    if( streq(cbuf, "linear") )
		GS_AXISTYPE(x)= LINEAR_AXIS
	    else
		GS_AXISTYPE(x)= LOG_AXIS

	    # get y-axis information
	    GS_STEPS(y) = tbhgti(tp, "y_steps")
	    GS_PAR_VALUE(y) = tbhgtr(tp, "y_val")
	    GS_DELTA(y) = tbhgtr(tp, "y_delta")
	    call tbhgtt(tp, "y_model", cbuf, SZ_LINE)
	    GS_MODELTYPE(y) = emission_val(cbuf)
	    if(streq("", Memc[ytitle]))		# see if we use defaults
	        call tbhgtt(tp, "y_param", Memc[ytitle], SZ_LINE)
	    call tbhgtt(tp, "y_axistype", cbuf, SZ_LINE)
	    if( streq(cbuf, "linear") )
		GS_AXISTYPE(y)= LINEAR_AXIS
	    else
		GS_AXISTYPE(y)= LOG_AXIS

	    # allocate a buffer for the chi-square data
	    call salloc ( chisq_array, GS_STEPS(x)*GS_STEPS(y), TY_REAL )
	    # allocate space for the column pointers
	    call salloc(cp, GS_STEPS(x), TY_POINTER)
	    # get column pointers and make sure we have all columns
	    do h = 1, GS_STEPS(x){
		# first get the column name from the header ...
		call sprintf(tbuf, 20, "col_%d")
		call pargi(h)
		call tbhgtt(tp, tbuf, cbuf, SZ_LINE)
		# then try to find the column itself
	        call tbcfnd(tp, cbuf, Memi[cp+h-1], 1)
		# we must have the columns or else!
		if( Memi[cp+h-1] == NULL )
		    call errstr(1, "missing chisquare column", cbuf)
	    }

	    # read the table data
	    do v = 1, GS_STEPS(y)  {
		do h = 1, GS_STEPS(x)  {
		    call tbrgtr(tp, Memi[cp+h-1],
			Memr[chisq_array+((v-1)*GS_STEPS(x)+h-1)],
			junk, 1, v)
		}
	    }
	    # close the table file
	    call tbtclo(tp)
	}
	else
	    response = FALSE

	# return the news
	return (response)
end


# 
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
procedure  draw_grid(gp, x, y, gr, x_limits, y_limits, 
			nlevels, levels,
			xplotsize, yplotsize, plot_array)

pointer	gp			# graphics pointer
pointer	x			# X axis data structure
pointer	y			# Y axis data structure
pointer	gr			# grid data structure
real	x_limits[2]		# 
real	y_limits[2]		#
int	nlevels
real	levels[nlevels]
int	xplotsize
int	yplotsize
pointer	plot_array		# grid data array
#--

real	x_temps[2]
real	y_temps[2]

begin
	if( GS_AXISTYPE(x) == LOG_AXIS )  {
	    x_temps[1] = alog10(x_limits[1])
	    x_temps[2] = alog10(x_limits[2])
	} else {
	    x_temps[1] = x_limits[1]
	    x_temps[2] = x_limits[2]
	}
	if( GS_AXISTYPE(y) == LOG_AXIS )  {
	    y_temps[1] = alog10(y_limits[1])
	    y_temps[2] = alog10(y_limits[2])
	} else {
	    y_temps[1] = y_limits[1]
	    y_temps[2] = y_limits[2]
	}
	if( ( GS_STEPS(x) > 1 ) && ( GS_STEPS(y) > 1 ) )

	    call contor ( gp, x, y, Memr[plot_array], xplotsize, yplotsize,
			  levels, nlevels, x_temps, y_temps )

	else
	    call printf(" You need multi-dimensional arrays for plotting!\n")
end

# 
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----

procedure  reloc ( gp, x, y, xpt, ypt )

pointer	 gp			# graphics pointer
pointer	 x			# X axis structure
pointer	 y			# Y axis structure
real	 xpt			#
real	 ypt			#

begin
	if( GS_AXISTYPE(x) == LOG_AXIS )
	    xpt = 10.0**xpt
	if( GS_AXISTYPE(y) == LOG_AXIS )
	    ypt = 10.0**ypt
	call gamove ( gp, xpt, ypt )
end


procedure  draw ( gp, x, y, xpt, ypt )

pointer  gp                     # graphics pointer
pointer  x                      # X axis structure
pointer  y                      # Y axis structure
real     xpt                    #
real     ypt                    #

begin
        if( GS_AXISTYPE(x) == LOG_AXIS )
            xpt = 10.0**xpt
        if( GS_AXISTYPE(y) == LOG_AXIS )
            ypt = 10.0**ypt
	call gadraw ( gp, xpt, ypt )
end


#  ---------------------------------------------------------------------

procedure  grid_label(gp, x, y, gr)

pointer	 gp		# graphics pointer
pointer	 x,  y		# axis data structures
pointer  gr		# grid data structure
#--

real	xcoord, ycoord
pointer	text
pointer	sp

begin
	call smark (sp)
	call salloc ( text, SZ_LINE, TY_CHAR )

	call gsetr(gp, G_TXSIZE, 0.7)

# Along the bottom 
#
	call sprintf(Memc[text], SZ_LINE, "min Chi-Squared =%6.2f")
	 call pargr(GR_BESTCHISQ(gr))
	call gctran (gp, 0.01, 0.09, xcoord, ycoord, 0, 1)
	call gtext (gp, xcoord, ycoord, Memc[text], "")

	call sprintf(Memc[text], SZ_LINE, "for %s")
	 call pargstr(Memc[GR_BMODEL(gr)])
	call gctran(gp, 0.35, 0.09, xcoord, ycoord, 0, 1)
	call gtext(gp, xcoord, ycoord, Memc[text], "")

	call sprintf(Memc[text], SZ_LINE, "using %s")
	 call pargstr(Memc[GR_IMODEL(gr)])
	call gctran(gp, 0.01, 0.053, xcoord, ycoord, 0, 1)	
	call gtext(gp, xcoord, ycoord, Memc[text], "")

#	call sprintf(Memc[text], SZ_LINE, "%s absorbtion")
#	 call pargstr(Memc[GR_ABS(gr)])
#	call gctran(gp, 0.35, 0.01, xcoord, ycoord, 0, 1)	
#	call gtext(gp, xcoord, ycoord, Memc[text], "")

	call gsetr(gp, G_TXSIZE, 1.0)
	call sfree(sp)
end


procedure grid_legend(gp, x, y, gr, nlevels, levels)

pointer	gp		# graphics pointer
pointer	x,  y		# axis data structures
pointer gr		# grid data structure
int	nlevels
real	levels[nlevels]
#--

int	i
real	xcoord, ycoord
pointer	text
pointer temp

pointer	sp

begin
	call smark (sp)
	call salloc ( text, SZ_LINE, TY_CHAR )
	call salloc ( temp, SZ_LINE, TY_CHAR )

	call gsetr(gp, G_TXSIZE, 0.7)

	# Upper right corner.
	#
	xcoord = GS_PAR_VALUE(x) - 0.9*GS_DELTA(x) + 0.03
	ycoord = GS_PAR_VALUE(y) + 0.9*GS_DELTA(y) - 0.03
#
#	commented out until written outside of data
#
#	# switch ( Memc(GR_ABS(gr) )
#	   if ( streq("morrison_maccammon", Memc[GR_ABS(gr)]) )
#	    	call gtext(gp, xcoord, ycoord,
#			 "Morrison-McCammon absorption", "")
#	    else if ( streq("brown_gould", Memc[GR_ABS(gr)]) )
#	    	call gtext(gp, xcoord, ycoord,
#			 "Brown & Gould absorption", "")
#	    else
#	        call gtext(gp, xcoord, ycoord,
#		         "unknown absorption", "")

	xcoord = GS_PAR_VALUE(x) + 0.50*GS_DELTA(x)
	ycoord = GS_PAR_VALUE(y) - 0.60*GS_DELTA(y)

#	call sprintf( Memc[text], SZ_PATHNAME, "minimum is:")
#	call gtext( gp, xcoord, ycoord, Memc[text], "")
#	ycoord = ycoord - LINE_HEIGHT*GS_DELTA(y)
#	call sprintf( Memc[text], SZ_PATHNAME, "%0.2f")
#	    call pargr(GR_BESTCHISQ(gr))
#	call gtext( gp, xcoord, ycoord, Memc[text], "")
#	ycoord = ycoord - LINE_HEIGHT*GS_DELTA(y)
	call sprintf( Memc[text], SZ_PATHNAME, "contours at:")
	call gtext( gp, xcoord, ycoord, Memc[text], "")
	do i = 1, nlevels  {
	    ycoord = ycoord - LINE_HEIGHT*GS_DELTA(y)
	    call sprintf( Memc[text], SZ_PATHNAME, "+ %6.2f")
		call pargr( levels[i]-GR_BESTCHISQ(gr))
	    call gtext( gp, xcoord, ycoord, Memc[text], "")
	    }

	call gsetr(gp, G_TXSIZE, 1.0)
	call sfree(sp)

end


procedure cr_to_semi(str)

char	str[ARB]
int	i

begin

	for ( i = 1; str[i] != EOS; i = i + 1 )
	    if ( str[i] == '\n' ) 
		str[i] = ';';
end
