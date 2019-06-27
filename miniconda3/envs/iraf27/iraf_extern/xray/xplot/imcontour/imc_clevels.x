#$Header: /home/pros/xray/xplot/imcontour/RCS/imc_clevels.x,v 11.0 1997/11/06 16:38:04 prosb Exp $
#$Log: imc_clevels.x,v $
#Revision 11.0  1997/11/06 16:38:04  prosb
#General Release 2.5
#
#Revision 9.1  1997/06/11 17:55:02  prosb
#JCC(6/11/97) - change INDEF to INDEFR.
#
#Revision 9.0  1995/11/16 19:08:50  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:02:03  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:48:25  prosb
#General Release 2.3
#
#Revision 6.1  93/10/20  15:14:33  janet
#jd - fixed bug in computing contour levels for type 'linear'.
#
#Revision 6.0  93/05/24  16:40:56  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:35:02  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  17:32:25  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  92/01/15  13:30:35  janet
#*** empty log message ***
#
#Revision 3.0  91/08/02  01:23:59  prosb
#General Release 1.1
#
#Revision 1.1  91/07/26  03:02:29  wendy
#Initial revision
#
#Revision 2.3  91/05/30  12:41:00  janet
#added 1 more place of precision on contour level debug display (.3->.4)
#
#Revision 2.2  91/04/03  12:03:15  janet
#Updated Dertermined Contour level list format to 3 decimals.
#
#Revision 2.1  91/03/26  10:33:31  janet
#Changed definition of input contour line to ptr with allocated space.
#
#Revision 2.0  91/03/06  23:20:47  pros
#General Release 1.0
#
# --------------------------------------------------------------------------
# Module:	IMC_CLEVELS.X
# Project:	PROS -- ROSAT RSDC
# Purpose:	routines to interpret contour level input
# External:	imc_get_clevels()
# Local:	imc_cunits(), prnt_struct(), interp_clevels(), 
#		peak_to_pix(), imc_linear(), imc_log()
# Copyright:	Property of Smithsonian Astrophysical Obsevatory
#		You may do anything you like with this
#		file except remove this copyright
# Modified:	{0} Janet DePonte  October 1989  initial version
#		{n} <who> -- <when> -- <does what>
# --------------------------------------------------------------------------

include	<imhdr.h>
include <math.h>
include <mach.h>
include "clevels.h"
include "imcontour.h"

# --------------------------------------------------------------------------
# Function:	get_contour_levels
# Purpose:	Parse and Interpret the users contour level input command.
# Returns:	pointer to structure with contour levels list
# Uses:		lex and yacc parser to read contour levels input
# Notes:	< optional >
#
# --------------------------------------------------------------------------
procedure get_contour_levels(sptr, debug)

pointer sptr		# i: contour level struct pointer
int     debug		# i: debug level

bool    parse_failed    # l: false when parse successful
#char	s[SZ_LINE]	# l: clevel inpur string
pointer clevelstr	# l: clevel input string
pointer	ptr		# l: yacc pointer

int	clev_parse()	# lexical parser 

begin

#   Clear and allocate the contour level input string
	call calloc (clevelstr, SZ_LINE, TY_CHAR)

#   Retrieve the contour units
	call imc_cunits(sptr)

#   Parse the contour level input 
  	parse_failed = TRUE
        while ( parse_failed ) {
  	   call clgstr("clevel", Memc[clevelstr], SZ_LINE)
	   if ( clev_parse(Memc[clevelstr], ptr, 0) == YES ) {
	     parse_failed = FALSE
	   }
	}

#   Print the contour level input that got saved in a a structure
	if ( debug >= 5 ) {
	   call prnt_struct (sptr) 
	}

end

# --------------------------------------------------------------------------
# Function:	imc_cunits
# Purpose:	Input the units to which the contour levels command is applied.
# Updates:	structure with contour levels list and units
# Notes:	Units are: pixel, peak, or sigma
#
# --------------------------------------------------------------------------
procedure imc_cunits(sptr)

pointer sptr		# i: contour level struct pointer

pointer unitbuf		# l: buffer for units input
pointer sp		# l: stack pointer

bool    streq()		# l: function that test string equality

begin

	call smark(sp)
	call salloc (unitbuf, SZ_LINE, TY_CHAR)

#  Prompt for contour level units
	call clgstr ("units", Memc[unitbuf], SZ_LINE)
	call rootname("", Memc[unitbuf], "", SZ_LINE)
	if ( streq("NONE", Memc[unitbuf]) | streq("", Memc[unitbuf]) ) {
	   call error (1, "requires unit input: PIXEL, PEAK or SIGMA")
#  Input unit = PIXEL 
	} else if ( streq("PIXEL", Memc[unitbuf]) | 
		    streq("pixel", Memc[unitbuf]) ) {
	   UNITS(sptr) = PIXELS
#  Input unit = PEAK
	} else if ( streq("PEAK", Memc[unitbuf]) | 
		    streq("peak", Memc[unitbuf] ) ) {
 	   UNITS(sptr) = PEAK
#  Input unit = SIGMA 
	} else if ( streq("SIGMA", Memc[unitbuf]) | 
		    streq("sigma", Memc[unitbuf] ) ) {
 	   UNITS(sptr) = SIGMA 
	} else {
	   call error (1, "Choose PIXEL, PEAK or SIGMA for units")
	} 

	call sfree(sp)

end

# --------------------------------------------------------------------------
#
# Function:	prnt_struct
# Purpose:	Debug printout of contour level structure
#
# --------------------------------------------------------------------------
procedure prnt_struct (sptr)

pointer sptr		# i: contour level struct pointer

int   i			# l: loop counter

begin

    call printf ("Parser Input:\n")

    call printf ("units = %d\n")
       call pargi (UNITS(sptr))

    call printf ("func = %d\n")
       call pargi (FUNC(sptr))

    call printf ("num params = %d\n")
       call pargi (NUM_PARAMS(sptr))

    do i = 1, NUM_PARAMS(sptr)  {
    
       call printf ("params = %f\n")
         call pargr (PARAMS(sptr,i))
    }

end

# --------------------------------------------------------------------------
# Function:	interp_clevels
# Purpose:	Interpret the contour level input command and determine 
#		the list of contour levels.
# Updates:	structure with contour command to a list of levels
# Notes:	Units are: pixel, peak, or sigma
#		Commands are: list of levels
#			      linear start stop steps
#			      log start stop steps
#
# --------------------------------------------------------------------------
procedure interp_clevels(sptr, photons, plt_const, debug)

pointer sptr		# i: contour level struct pointer
pointer photons		# i: image photons pointer 
pointer plt_const	# i: plot constants structure
int     debug		# i: debug level

real	low		# l: contour param lower limit
real    high		# l: contour param upper limit
real    incr		# l: increment between contour limits

begin

#  All levels are specified if function type is LEVELS
	if (FUNC(sptr) == LEVELS) {

#  Reassign levels to percentage of the peak
	   if (UNITS(sptr) == PEAK) {
	      call peak_to_pix (photons, plt_const, debug, NUM_PARAMS(sptr), PARAMS(sptr,1))
	   }
#  Either LINEAR or LOG which both take 3 arguments
	} else if (NUM_PARAMS(sptr) == 3) {

#  Compute the increment & determine contour levels for LINEAR
	   if (FUNC(sptr) == LINEAR) {
	      if (UNITS(sptr) == PEAK) {
	         call peak_to_pix (photons, plt_const, debug, 2, PARAMS(sptr,2))
	      }
	      low = PARAMS(sptr,LO)
	      high = PARAMS(sptr,HI)
	      incr = (PARAMS(sptr,HI)-PARAMS(sptr,LO))/PARAMS(sptr,STEPS)
	      call imc_linear (sptr, low, high, incr)

#  Compute the increment & determine contour levels for LOG
	   } else if (FUNC(sptr) == LOG) {
	      if (UNITS(sptr) == PEAK) {
	         call peak_to_pix (photons, plt_const, debug, 2, PARAMS(sptr,2))
	      }
              if ( PARAMS(sptr,LO) <= EPSILONR ) {
                 PARAMS(sptr,LO) = 1.0
                 if ( PARAMS(sptr,HI) <= EPSILONR ) {
                    PARAMS(sptr,HI) = 1.0
                 }
                 call printf("\n-- Log 0 Undefined. Using 'log %.1f %.1f %.1f' --\n")
                   call pargr (PARAMS(sptr,LO))
                   call pargr (PARAMS(sptr,HI))
                   call pargr (PARAMS(sptr,STEPS))
                 call printf ("   (lowest possible value = 0.0) \n\n") 
              }
	      low = PARAMS(sptr,LO)
	      high = PARAMS(sptr,HI)
	      incr =(log10(PARAMS(sptr,HI))-log10(PARAMS(sptr,LO)))/
                        PARAMS(sptr,STEPS)
	      call imc_log (sptr, low, high, incr)
	   }
#  Determine contour levels for LINEAR & LOG 

	} else {
#  Error if LOG or LINEAR & args not equal to 3
	   call prnt_struct (sptr)
	   call error(1, "LOG or LINEAR must have 3 args - lo, hi, steps")
	}  
	if ( debug >= 2 ) {
	   call imc_displev(sptr)
	}

end

# --------------------------------------------------------------------------
#
# Function:	peak_to_pix
# Purpose:	Determine the contour levels in a pixel position from input 
#               expressed as a percentage of the peak.
# Notes:	contour level = (input_level / 100.0) * array_max
#
# --------------------------------------------------------------------------
procedure peak_to_pix (photons, plt_const, debug, num_vals, vals)

pointer photons 	# i: pointer to image
pointer plt_const	# i: pointer to constants struct
int     debug		# i: debug level
int	num_vals	# i: number of levels 
real	vals[ARB]	# i/o: updated contour levels 

int     i		# l: loop counter
real 	max		# l: array max

begin

#  Retrieve the image min and max value
	call imc_maxval (photons, plt_const, max)
	if (debug >= 3) {
	   call printf ("Image Peak: %.2f\n")
	    call pargr (max)
	 }

#  Compute the pixel contour level from the peak percentage
	do i=1, num_vals {
	   vals[i] = (vals[i]/100.0) * max
	}

end

# --------------------------------------------------------------------------
#
# Function:	   imc_linear
# Purpose:	   Determine the linear contour levels given the range 
#                  and increment.
# Post-condition:  Contour level structure updated with computed levels
#
# --------------------------------------------------------------------------
procedure imc_linear (sptr, low, high, incr)

pointer sptr		# i: contour level struct pointer
real	low		# i: contour param lower limit
real    high		# i: contour param upper limit
real    incr		# i: increment between contour limits


bool    not_done        # l: bool loop control
int	j		# l: array counter
real    nxtlev          # l: computed contour levels
real    lower_limit     # l: minimum level test value with epsilonr 

begin

#   Init variables
	if ( incr <= EPSILONR ) {
	   not_done = FALSE
	} else {
	   not_done = TRUE
           lower_limit = low
        }

#   Compute linear contour levels until we reach our lower limit
#   The params structure is updated with the computed levels
	if ( not_done ) {
	   j = 0
           nxtlev = high + incr

	   do while ( not_done ) {
	      nxtlev = nxtlev - incr
              lower_limit = lower_limit - EPSILONR

#             call printf ("nxtlev=%f, low=%f, high=%f, incr=%f\n")
#              call pargr (nxtlev)
#              call pargr (low)
#              call pargr (high)
#              call pargr (incr)
#             call flush (STDOUT)
	   
	      if ( nxtlev >= lower_limit ) {
	         j = j+1
	         PARAMS(sptr,j) = nxtlev
	      } else {
	         not_done = FALSE
	      }
	   } 
	}
 	NUM_PARAMS(sptr) = j

# --- old code - replaced 7/20/93  - jd (bug 602)
#	j = 0
#	for ( i=high; i>= low; i=i-incr) {
#	   j = j+1
#	   PARAMS(sptr,j) = i
#	}
#	NUM_PARAMS(sptr) = j
# --- old code - replaced 7/20/93  - jd

end

# --------------------------------------------------------------------------
#
# Function:	   imc_log
# Purpose:	   Determine the logarithmic contour levels given the range 
#                  and increment.
# Post-condition:  Contour level structure updated with computed levels
#
# --------------------------------------------------------------------------
procedure imc_log (sptr, low, high, incr)

pointer sptr		# i: contour level struct pointer
real	low		# i: contour param lower limit
real    high		# i: contour param upper limit
real    incr		# i: increment between contour limits

bool    not_done        # l: loop while true
real    lower_limit	# l: how low do we go
real    nxtlev		# l: current computed clevel
int	j		# l: array indexer

begin

#   Init variables
	if ( incr <= EPSILONR ) {
	   not_done = FALSE
	} else {
	   not_done = TRUE
        }

	if ( not_done ) {
	   j = 0
	   lower_limit = 10**log10(low)

#   Compute logarithmic contour levels until we reach our lower limit
#   The params structure is updated with the computed levels
	   do while (not_done) {
	      nxtlev = 10**(log10(high) - (real(j) * incr) )
              lower_limit = lower_limit - EPSILONR
	   
	      if (nxtlev >= lower_limit) {
	         j = j+1
	         PARAMS(sptr,j) = nxtlev
	      } else {
	         not_done = FALSE
	      }
	   } 
	}
	NUM_PARAMS(sptr) = j
end

# -------------------------------------------------------------------
# IMC_MAXVAL -- Determine the maximum pixel value of an image.
# -------------------------------------------------------------------
procedure imc_maxval (photons, plt_const, max_pix)

pointer	photons		# i: image descriptor
pointer plt_const	# i: structure pointer
real	max_pix		# o: max pixel value in image 

int     i, j, k		# l: row pointer for loop
real	minval, maxval	# l: min and max val in 1 line

begin

	max_pix = -INDEFR      #JCC(6/97) - change INDEF to INDEFR
	j = int ( IMPIXX(plt_const) )
	k = int ( IMPIXY(plt_const) )

	do i = 1, k  {
	   call alimr (Memr[photons+(i-1)*j], j, minval, maxval)
	   if (maxval > max_pix) {
	      max_pix = maxval
	   }
	}
end

# -------------------------------------------------------------------
# IMC_DISPLEV -- Display the contour levels.
# -------------------------------------------------------------------
procedure imc_displev (sptr)

pointer sptr	# i: struct pointer of contour levels

int   	i	# l: loop counter

begin
        call printf ("Determined Contour Levels: \n")
 	call printf ("(")
        do i = NUM_PARAMS(sptr), 1, -1 {
	   if ( i > 1 ) {
              call printf ("%.4f,")
	   } else {
              call printf ("%.4f")
	   }
           call pargr (PARAMS(sptr,i))
        }
 	call printf (")\n")
 	call printf ("\n")
end 

