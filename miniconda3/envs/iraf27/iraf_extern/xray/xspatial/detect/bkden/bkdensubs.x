#Header:
#Log:
#
#JCC(3/98) - print '0.0**0.0' in 'compute_thresh'
#          ( no need - if y=0, set x**y to one in 'compute_thresh()')
#JCC(2/98) - change the error message.
#
# ---------------------------------------------------------------------
#
# Module:       BKDENSUBS.X
# Project:      PROS -- ROSAT RSDC
# Purpose:      misc procedures to support bkden task
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} Janet DePonte -- Feb 1992 -- initial version
#               {1} JD -- Oct 1992-- added define_defreg routine
#
# ---------------------------------------------------------------------

include <imhdr.h>
include <mach.h>
include <ext.h>
include <pmset.h>

define  MARK_REJECTED  1
define  ELIMINATED     2
define  x 1
define  y 2

# ---------------------------------------------------------------------------
# define_defreg:
# ---------------
procedure define_defreg (im, regname)

pointer im			# i: image handle
char    regname[ARB]		# o: encoded default region 

real    cen[2]                  # l: image center in logical coords
real    radius			# l: radius in arc minutes

real    clgetr ()

begin

        # read the radius (arc-minutes)
        radius = clgetr ("radius") 

        # compute the center in logical coords
        cen[x] = IM_LEN(im,x) / 2.0
        cen[y] = IM_LEN(im,y) / 2.0

	# build a default region ... radius is in arc minutes
        call sprintf (regname, SZ_LINE, "circle %.2f %.2f %.2f'\n")
         call pargr (cen[x])
         call pargr (cen[y])
         call pargr (radius)

end
#----------------------------------------------------------------------------
#cnt_msked_pixels:
#-----------------
procedure cnt_msked_pixels (mp, display, num_cells)

pointer	mp		# i: mask pointer
int	display		# i: display level
int	num_cells	# o: number of elements in cellbuff

int     mval		# l: mask parameter
int     npix		# l: number of pixels in segment read
int     status		# l: eof status

pointer v		# l: mask vector
pointer pp		# l: returned data buffer
pointer sp		# l: space allocation buffer


int     mio_glsegr()	# l: return the data elements in a masked data line

begin

#   Allocate buffer space for input vector
	call smark (sp)
	call salloc (v, PM_MAXDIM, TY_LONG)

#   Init some variables
        num_cells=0
        call aclrl (Meml[v],  PM_MAXDIM)
        status = OK

#   Read the pixels and tally the number of cells in the region.
        while ( status != EOF ) {
           status = mio_glsegr (mp, pp, mval, Meml[v], npix)
           if (status != EOF) {
	      num_cells = num_cells + npix 
	   }
	}

#   If no cells have data the rest of the processing isn't very useful
	if ( num_cells == 0 ) {
	   call error (1, "No area in specified regions")
        }
      
	call sfree(sp)

end

#----------------------------------------------------------------------------
#get_msked_pixels:
#-----------------
procedure get_msked_pixels (mp, display, cellbuff, num_cells)

pointer	mp		# i: mask pointer
int	display		# i: display level
real    cellbuff[ARB]	# o: buffer with counts in each element of region
int	num_cells	# o: number of elements in cellbuff

int     i		# l: loop counter
int     mval		# l: mask parameter
int     npix		# l: number of pixels in segment read
int     status		# l: eof status

pointer v		# l: mask vector
pointer pp		# l: returned data buffer
pointer sp		# l: space allocation buffer

real    cnts		# l: count tally

int     mio_glsegr()	# l: return the data elements in a masked data line

begin

#   Allocate buffer space for input vector
	call smark (sp)
	call salloc (v, PM_MAXDIM, TY_LONG)

#   Init some variables
        num_cells=0
        cnts=0.0
        call aclrl (Meml[v],  PM_MAXDIM)
        status = OK

#   Read the pixel region into our buffer
        while ( status != EOF ) {
           status = mio_glsegr (mp, pp, mval, Meml[v], npix)
           if (status != EOF) {
	      do i=0, (npix-1) {
                 cellbuff[num_cells+i] = Memr[pp+i]
		 cnts = cnts + cellbuff[num_cells+i]
	      }
	      num_cells = num_cells + npix 
	   }
	}


#   display number of cells & tot cnts read, useful for debugging.
#   Numbers should match with imcnts on the same region
        if ( display > 0 ) {
	   if ( display > 2 ) {
	      call printf ("read %d cells from specified region, total cnts = %f\n")
	        call pargi (num_cells)
		call pargr (cnts)
	   }

#   display total counts that we've accumulated, immediately after the read
#   --- massive output for debugging purposes ---
	   if ( display >= 5 ) {
	      do i = 1, num_cells {
                 if ( cellbuff[i] > 0.0 ) {
	            call printf ("cellbuff[%d]=%f\n")
                       call pargi (i)
                       call pargr (cellbuff[i])
	         }
	      }
	   }
	}
	call flush(STDOUT)

#   If no cells have data the rest of the processing isn't very useful
	if ( num_cells == 0 ) {
	   call error (1, "NO area in specified regions") #JCC(2/98)
        }
      
	call sfree(sp)

end


#----------------------------------------------------------------------------
#Get Avg Counts:
#---------------
procedure  get_avg_cnts (cellbuff, rejbuff, num_cells, display, avg_cnts)

real 	cellbuff[ARB]		# i: counts within the region of interest
short   rejbuff[ARB]		# i: buffer with reject markers assoc with data
int     num_cells		# i: number of cells in cellbuff
int     display			# i: display level

real    avg_cnts		# o: computed average counts

int     i			# l: loop counter
real    cnts			# l: tally of counts in cellbuff
real	cnts_to_avg 		# l: number of elements in average

begin

        cnts=0.0
	cnts_to_avg=0.0

#   sum the counts in the region buffer (cellbuff), don't look at elements
#   associated with rejected or eliminated markers (from rejbuff).  
	for (i=1; i<=num_cells; i=i+1) {

	   if ( rejbuff[i] != ELIMINATED ) {
	      if ( rejbuff[i] != MARK_REJECTED ) {
 	         cnts = cnts + cellbuff[i]
		 cnts_to_avg = cnts_to_avg + 1.0
	      }
	   }
	}

#   compute the avg counts, be careful of 0 counts
	if ( cnts > 0.0 ) {
	   avg_cnts = cnts / cnts_to_avg
	} else {
	   avg_cnts = 0.0
	}

	if ( display >= 3 ) {
	   call printf ("cnts=%f, cnts_to_avg=%f, avg_cnts=%f \n")
	   call pargr (cnts)
	   call pargr (cnts_to_avg)
	   call pargr (avg_cnts)
	}

end

#----------------------------------------------------------------------------
#Compute Thresh:
#---------------

procedure compute_thresh (avg_cnts, fconst, display, thresh, tcnts)

real	avg_cnts		# i: computed average counts
real    fconst			# i: fluctuation constant
int	display			# i: display level

double  thresh			# o: computed threshold value
int     tcnts			# o: total counts above threshold

double  sum			# l: sum 

double  nfact()			# l: factorial function
double  yyy 

begin

#   compute thresh limit
	thresh = exp(avg_cnts) * fconst
        if ( display  > 3 ) {
	   call printf ("avg_cnts= %f, fconst= %f, thresh= %f\n")
              call pargr (avg_cnts)
              call pargr (fconst)
              call pargd (thresh)
	}

	sum = 0.0d0
	tcnts= -1

#   determine the counts within the threshold limit
#no need :  JCC(3/98) - if y=0, set x**y to one in 'compute_thresh()'

	while (sum <= thresh ) {
	   tcnts = tcnts + 1
           #**if (tcnts == 0) {                   #JCC(3/98)
           #**  sum = sum + 1.0d0 / nfact(tcnts)  #JCC(3/98)
           #**}                                   #JCC(3/98)
           #**else  {                             #JCC(3/98)
             sum = sum + (avg_cnts**double(tcnts)) / nfact(tcnts)
           #**}                                   #JCC(3/98)

	   if ( display >= 5 ) {
	      call printf ("In Loop: tcnts= %d, sum=%f\n")
                call pargi (tcnts)
	        call pargd (sum)
	   }
	}

        if ( display > 3 ) {
	   call printf ("compute_thresh: Threshold cnts= %d, Sum = %f\n")
	   call pargi (tcnts)
	   call pargr (sum)
	}

#JCC(3/98) - print '0.0**0.0' in 'compute_thresh'
        if ( display >= 5 ) {
           yyy = 0.0**0.0
           call printf("compute_thresh: 0.0**0.0= %f \n")
           call pargd(yyy)
        }
end

#----------------------------------------------------------------------------
#Screen Cells:
#-------------

procedure screen_cells (cellbuff, rejbuff, tcnts, num_cells, display, rejected)

real 	cellbuff[ARB]		# i: region image data
short   rejbuff[ARB]		# i: associated reject element marker buffer
int     tcnts			# i: threshold 
int     num_cells		# i: number of cells 
int	display			# i: display level
bool    rejected		# o: indicates if any cells are below thresh

int	dispcnt			# l: count for display purposes
int	i			# l: loop counter

real    counts                  # l: threshold counts

begin
        i=0
	dispcnt = 0

        counts = float (tcnts)
	
	while ( i < num_cells ) { 
	   i=i+1

#   clean up old rejected buffers and mark as eliminated so that they
#   are not part of current evaluation
           if ( rejbuff[i] == MARK_REJECTED ) {
	      rejbuff[i] = ELIMINATED
	   }

#   Mark the cell as rejected if the counts are greater than the threshold
           if ( cellbuff[i] > counts && rejbuff[i] != ELIMINATED ) {
		rejected = TRUE
                rejbuff[i] = MARK_REJECTED
	        dispcnt = dispcnt + 1
	   }
	}
	
	if ( display >= 3 ) {
	   call printf ("Number rejected = %d\n\n")
	   call pargi (dispcnt)
	}
	   
end

#----------------------------------------------------------------------------
#Function Fact:
#--------------

double procedure nfact(n)

int  	n			#i: factorial input val

int     i			#l: loop counter

begin

        nfact = 1.0d0

	for (i=1; i<=n; i=i+1) {
	   nfact = nfact * i
        }

	return (nfact)

end
