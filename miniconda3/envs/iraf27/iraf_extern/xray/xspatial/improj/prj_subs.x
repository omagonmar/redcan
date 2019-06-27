#$Header: /home/pros/xray/xspatial/improj/RCS/prj_subs.x,v 11.0 1997/11/06 16:30:19 prosb Exp $
#$Log: prj_subs.x,v $
#Revision 11.0  1997/11/06 16:30:19  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:47:06  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:57:22  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:29:34  prosb
#General Release 2.3
#
#Revision 6.1  93/07/02  14:40:33  mo
#MC	7/2/93		Remove redunant == TRUE (RS6000 port)
#
#Revision 6.0  93/05/24  16:11:51  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:29:23  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:36:42  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:28:37  prosb
#General Release 1.1
#
#Revision 2.1  91/07/10  11:03:13  janet
#fixed init_table counts format definition from D to F format.
#
#Revision 2.0  91/03/06  23:19:05  pros
#General Release 1.0
#
#------------------------------------------------------------------------------
#
# Module:	PRJ_SUBS
# Project:	PROS -- ROSAT RSDC
# Purpose:	Improj subroutines
# External:	disp_proj(), init_table(), fill_table(), fill_hdr()
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989.  You may do anything you like with this
#		file except remove this copyright
# Modified:	{0} Janet DePonte -- initial version -- October 1988
#		{1} MVH -- added proj_rebin() -- September 1989
#		{2} JD -- fixed init_table counts format definition 
#			  from D to F format - July 1990
#
#------------------------------------------------------------------------------

include <mach.h>	# get EPSILOND

#------------------------------------------------------------------------------
#
# Function:	Disp_proj
# Purpose:	display proj counts & area for each region (use with box)
#
#------------------------------------------------------------------------------
procedure disp_proj (direction, counts, area, indices)

int	direction
double	counts[ARB]			# i: counts in projected area
double  area[ARB]			# i: projected area
int	indices				# i: number of indices

int     i				# l: loop counter
int     row

begin
	row = 0
	call printf("\n")
	if ( direction == 1 ) 
	   call printf("X Projection\n")
	else if ( direction == 2 )
	   call printf("Y Projection\n")
	call printf("-------------\n")
	call printf("\tREGION\tCOUNTS\t\t  PIXELS\tCOUNTS/PIXEL (AVERAGE)\n")
	if ( indices > 0 )
	{
#   Print buffers backwards so that projections go from right to left
#   Reflects the order that the output is written 
 	   do i=indices, 1, -1
	   {  
	      row = row + 1
	      call printf("%10d\t%-13.9g %10d\t%-13.9g\n")
	      call pargi(row)
	      call pargd(counts[i])
	      call pargi(int(area[i]))
	      if( area[i] < EPSILOND )
		 call pargr(0.0)
	      else
		 call pargd(counts[i] / area[i])
	   }
	}

end

#------------------------------------------------------------------------------
#
# Function:	disp_proj_two
# Purpose:	display proj counts & area for both axes (use with field)
#
#------------------------------------------------------------------------------
procedure disp_proj_two (xproj, xarea, xindices, yproj, yarea, yindices)

double	xproj[ARB]			# i: counts in projected area
double  xarea[ARB]			# i: projected area
int	xindices			# i: number of indices
double	yproj[ARB]			# i: counts in projected area
double  yarea[ARB]			# i: projected area
int	yindices			# i: number of indices

int     i				# l: loop counter
int     row, imax

begin
	row = 0
	call printf("\n")
	call printf("INDEX represents column for X vals, row for Y vals\n")
	call printf("--------------------------------------\n")
	call printf("INDEX XPIXELS XCOUNTS XCOUNTS/PIXEL(AVERAGE)")
	call printf(" YPIXELS YCOUNTS YCOUNTS/PIXEL(AV)\n")
	if ( (xindices > 0) || (yindices > 0) )
	{
#  put both x and y on screen at same time, sharing the index
	   imax = max(xindices, yindices)
 	   do i = 1, imax
	   {
	      call printf("%5d")
	       call pargi(i)
	      if( i <= xindices )
#  print the x vals only while there are x vals
		 {
		 call printf(" %6d  %-13.9g  %-12.8g")
		  call pargi(int(xarea[i]))
		  call pargd(xproj[i])
		 if( xarea[i] < EPSILOND )
		    call pargr(0.0)
		 else
		    call pargd(xproj[i] / xarea[i])
		 }
	      else
		 call printf("                                    ")
	      if( i <= yindices )
#  print the y vals only while there are y vals
		 {
		 call printf("  %6d  %-13.9g  %-12.8g\n")
		 call pargi(int(yarea[i]))
		 call pargd(yproj[i])
		 if( yarea[i] < EPSILOND )
		    call pargr(0.0)
		 else
		    call pargd(yproj[i] / yarea[i])
		 }
	      else
		 call printf("\n")
	   }
	}

end

#------------------------------------------------------------------------------
#
# Function:	Init_table 
# Purpose:	initialize the output projection table file 
#
#------------------------------------------------------------------------------
procedure init_table (tbl, tp, clobber, counts_cp, area_cp)

char	tbl[ARB]			# i: table name
pointer tp				# i: table pointer
bool	clobber				# i: clober old table file
pointer	counts_cp[2]			# o: counts column pointer
pointer area_cp[2]			# o: area column pointer

int	tbtacc()			# l: table access function
pointer tbtopn()			# l: table open function

begin

#    Clobber old file if it exists
	if ( tbtacc(tbl) == YES )
	{
	   if ( clobber )
	   {
	      iferr ( call tbtdel(tbl) )
	         call error (1, "Can't delete old Table")
	   }
	   else
	      call error (1, "Table file already exists")
	}

#    Open a New Table
	tp = tbtopn (tbl, NEW_FILE, 0)

#    Define Columns
	call tbcdef (tp,counts_cp[1], "counts_x", "", "%-12.5f", TY_DOUBLE,1,1)
	call tbcdef (tp,area_cp[1], "area_x", "", "%-10d", TY_INT, 1,1)
	call tbcdef (tp,counts_cp[2], "counts_y", "", "%-12.5f", TY_DOUBLE,1,1)
	call tbcdef (tp,area_cp[2], "area_y", "", "%-10d", TY_INT, 1,1)

#    Now actually create it
	call tbtcre (tp)

end

#------------------------------------------------------------------------------
#
# Function:	Fill_table 
# Purpose:	fill the table file with counts and area projection data
#
#------------------------------------------------------------------------------
procedure fill_table (tp, counts, area, stop, counts_cp, area_cp, reverse)

pointer tp			# i: table pointer
double	counts[ARB]		# i: counts in projected area
double  area[ARB]		# i: projected area
int	stop			# i: number of indices
pointer counts_cp		# i: counts column pointer
pointer area_cp			# i: area column pointer
int	reverse			# i: reverse order of regions

int	i				# i: counters
int     row

begin
	if( reverse > 0 )
	{
	   row = 0
#   Output backwards so that projections go from right to left
	   do i=stop, 1, -1
	   {
	      row = row + 1
	      call tbrptd (tp, counts_cp, counts[i], 1, row)
	      call tbrpti (tp, area_cp, int(area[i]), 1, row)
	   }
	}
	else
	{
	   do i=1, stop
	   {
	      call tbrptd (tp, counts_cp, counts[i], 1, i)
	      call tbrpti (tp, area_cp, int(area[i]), 1, i)
	   }
	}
end

#------------------------------------------------------------------------------
#
# Function:	Fill_hdr
# Purpose:	fill the table hdr file with image name, region, and num bins
#
#------------------------------------------------------------------------------
procedure fill_hdr (tp, imname, region, x_bins, y_bins)

pointer	tp				# i: table pointer
char    imname[ARB]			# i: image name
char	region[ARB]			# i: proj region
int	x_bins				# i: bins in x 
int	y_bins				# i: bins in y

begin

	call tbhadt (tp, "imname", imname)
	call tbhadt (tp, "region", region)
	call tbhadi (tp, "x_bins", x_bins)
	call tbhadi (tp, "y_bins", y_bins)

end


# Subroutine:	proj_rebin
# Purpose:	rebin a projection and its areas to a shorter array
procedure proj_rebin ( counts, area, dim, num_bins )

double	counts[ARB]	# i/o: array of counts
double	area[ARB]	# i/o: array of areas
int	dim		# i: number of input bins
int	num_bins	# i: number of output bins

double	step

int	i, j
int	bound

begin
	step = (double(dim) / double(num_bins))
	j = 1
	do i = 1, num_bins
	{
	   counts[i] = counts[j]
	   area[i] = area[j]
#   be sure not to skip the last bin
	   if( i < num_bins )
	      bound = int(double(i) * step)
	   else
	      bound = dim
	   while ( (j < bound) && (j < dim) ) 
	   {
	      j = j + 1
	      counts[i] = counts[i] + counts[j]
	      area[i] = area[i] + area[j]
	   }
	   j = j + 1
	}
end
