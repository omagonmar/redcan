#$Header: /home/pros/xray/xspatial/isoreg/RCS/isosubs.x,v 11.0 1997/11/06 16:33:07 prosb Exp $
#$Log: isosubs.x,v $
#Revision 11.0  1997/11/06 16:33:07  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:52:49  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:15:50  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:36:46  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:21:29  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:34:59  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:43:25  prosb
#General Release 2.0:  April 1992
#
#Revision 1.1  92/02/13  12:25:04  janet
#Initial revision
#
#
# Module:       ISOSUBS
# Project:      PROS -- ROSAT RSDC
# Purpose:	Utility routines for task isoregs
# External:
# Local:        all others
# Description:  get_intensity_regions(), assign_region() 
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} JD    initial version  	Feb 1992
# -------------------------------------------------------------------------

include <ctype.h>

# -------------------------------------------------------------------------
procedure get_intensity_regions (clevels, display, nlevs, ilims)

char clevels[ARB]
int  display
int  nlevs
real ilims[ARB]

int     ip		# parsing pointer for clevels
int     i,j,k		#l: loop counters
int     nchars		# number of chars returned from ctor

real    rlims		# returned limit as a real
real    temp		# temporary holder for sort

int     ctor()		# converst from char to real

begin


#   Parse the levels in the character buffer into an array of reals
        nlevs = 0
        ip = 1
        while ( TRUE ) {
           nchars = ctor (clevels, ip, rlims)
           if ( nchars == 0 ) break
           nlevs = nlevs + 1
           ilims[nlevs] = rlims
           if ( display > 5 ) {
              call printf ("input intensity = %.1f, mask id = %d \n")
                call pargr (ilims[nlevs])
                call pargi (nlevs)
           }
           while ((IS_WHITE(clevels[ip])) || (clevels[ip] == ',')) {
              ip = ip+1
	   }
        }

#   Sort list in increasing order 
	for (i=1; i<=nlevs; i=i+1) {
          j=i
	  for ( k=j+1; k<=nlevs; k=k+1) {
             if (ilims[k] < ilims[j]) {
		j=k
	     }
	  }
	  temp=ilims[i]
	  ilims[i]=ilims[j]
	  ilims[j]=temp
	}

#   Print intensity list and equivalent mask ids
        if ( display >= 2 ) {
           call printf ("\n")
           call printf ("Mask Id / Intensity Level Pairs:\n")
           call printf ("--------------------------------\n")
           for (i=1; i<=nlevs; i=i+1) {
              call printf ("   %d	   %.3f\n")
                 call pargi (i)
                 call pargr (ilims[i])
	   }
           call printf ("\n")
        }


end

# -------------------------------------------------------------------------
procedure assign_region (ibuf, ypos, xlen, nlevs, ilims, obuf, display)

real ibuf[ARB]		#i: line buffer with image pixel data
int  ypos		#i: current line number
int  xlen		#i: length of line (number of values in x)
int  nlevs		#i: number of contour levels = mask numbers
real ilims[ARB]		#i: input contour limits
int  obuf[ARB]		#i: output mask buffer
int  display		#i: display level

real curpos		#l: current position
int  xpos		#l: pointer to current position in line
int  i 			#l: loop counter

begin

#  Clear the output buffer before any assignments are made to the line
        call aclri (obuf, xlen)

#  Scan the line
	for (xpos=1; xpos<=xlen; xpos=xpos+1) {

            curpos = ibuf[xpos]

#   ... compare the pixel value to each contour level - 
#       -- levels must be sorted in increasing order for this to work --
           for (i=1; i<=nlevs; i=i+1) {
              if ( curpos >= ilims[i] ) {
                 obuf[xpos] = i

                 if ( display >= 10 ) {
                    call printf ("assigned pix %d,%d = %d\n")
                       call pargi (xpos)
                       call pargi (ypos)
                       call pargi (obuf[xpos])
	         }
              }
           }   
	}

end
