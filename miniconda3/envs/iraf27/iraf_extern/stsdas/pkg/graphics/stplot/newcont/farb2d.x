# farb2d - Fill area with bicubics for 2d contour plotting
# Description
#   This routine produces contours of the given data on the graphics
#   output.
#   This code is based on the ACM algorithm 671 published in the
#   _ACM_Transactions_of_Mathematical_Software, Vol 15, No. 1, March 1989,
#   Pages 79-89.  The source code itself was retrieved by the Internet mail
#   service netlib located at ornl.gov.  For more information on netlib, send
#   mail with a single line containing "help" to netlib@ornl.gov.
#   NOTE: BESIDES THE COPYRIGHTS OF STSCI/STSDAS, THIS SOFTWARE IS SUBJECT
#   TO COPYRIGHTS OF THE ACM.  CONTACT THE ACM FOR MORE INFORMATION.
#   Below this introduction is the header appended by netlib.  Below that
#   and for each subroutine, the header by the author is also included.
#   Besides the rewrite into SPP and the inclusion of the IRAF GIO graphics
#   interface, the code has not been modified.  This includes the preservation
#   of GOTO's.  Only in the simplest cases have GOTO's been replaced with
#   other constructs.
#   NOTE: A logical change has been made.  The problem is with the routine
#   usrplt, specifically the use of the ncol parameter.  The documentation
#   seemed very clear on the point- ncol is the color (or color index into
#   some color table) to draw the area or line in.  However, in usage, ncol
#   seems to have two distinct usages.  If the mode to draw is fill  area,
#   the usage is consistent with documentation.  However, if the mode is
#   line drawing only, ncol was not set to the color, but was given the
#   contour level index (the value representing which contour level was
#   being drawn).  This is so highly inconsistent that it gives one a
#   massive head trauma thinking about it.  The solution here is to change
#   the calls involving line drawing mode to pass the color index and not
#   the contour index.
#  
# History
#   31Dec90 - Retrieved from netlib.  Prototype for applicability to IRAF.
#             Jonathan D. Eisenhamer, STScI.
#   15Jan91 - Rewritten into SPP. jde
#   21Jan91 - Modified selected calls to usrplt to make the usrplt interface
#             consistent. jde
# Bugs
#   - Though these routines handle both simple contouring by lines and
#     area filling, only the line drawing works.  The IRAF GIO gfill 
#     area filling is not implemented (insert appropriate comments by the
#     reader).  However, if gfill is ever implemented, nothing in these
#     routines should need modifying except to debug the graphics calls
#     for correct usage.
# Intro added by netlib:
# From netlibd@surfer.EPM.ORNL.GOV Mon Dec 31 08:19:16 1990
# To: eisenham@stsci.edu
# Subject: send 671 from toms
# 
# Disclaimer. This on-line distribution of algorithms is not an official
# service of the Association for Computing Machinery (ACM).  This service is
# being provided on a trial basis and may be discontinued in the future.  ACM
# is not responsible for any transmission errors in algorithms received by
# on-line distribution.  Official ACM versions of algorithms may be obtained 
# from:	IMSL, Inc.
# 	2500 ParkWest Tower One
# 	2500 CityWest Blvd.
# 	Houston, TX 77042-3020
# 	(713) 782-6060
# 
# Columns 73-80 have been deleted, trailing blanks removed, and program
# text mapped to lower case.  Assembly language programs have sometimes
# been deleted and standard machine constant and error handling
# routines removed from the individual algorithms and collected
# into the libraries "core" and "slatec".  In a few cases, this trimming
# was overzealous, and will be repaired when we can get back the original
# files. We have tried to incorporate published Remarks; if we missed
# something, please contact Eric Grosse, 201-582-5828, research!ehg or
# ehg@research.att.com.
# 
# The material in this library is copyrighted by the ACM, which grants
# general permission to distribute provided the copies are not made for
# direct commercial advantage.  For details of the copyright and
# dissemination agreement, consult the current issue of TOMS.
# 
# Caveat receptor.  (Jack) dongarra@cs.utk.edu, (Eric Grosse) research!ehg
# Careful! Anything free comes with no guarantee.
# *
# *We would like to thank Sequent Computer Systems Inc. 
# *for the computer used to run netlib.
# *
# *** from netlib, Mon Dec 31 08:20:42 EST 1990 ***
# C      ALGORITHM 671, COLLECTED ALGORITHMS FROM ACM.
# C      THIS WORK PUBLISHED IN TRANSACTIONS ON MATHEMATICAL SOFTWARE,
# C      VOL. 15, NO. 1, PP. 79-89.
#                FARB-E-2D    Version 2.1               10/1988
#  
# End of netlib intro.
# Author intro:
#     fill area with bicubics for 2d contour plotting
#     -----------------------------------------------
#     farb-e-2d  version 2.1, 10/1988
#     t r i p   algorithm              a. preusser
#     author: a. preusser
#             fritz-haber-institut der mpg
#             faradayweg 4-6
#             d-1000 berlin 33
#     input parameters
#     x       array of length lx for x-coordinates of
#             a regular grid
#             in ascending order.
#                     x- and y-coordinates must be given
#                             in centimeters
#                             ==============
#     lx      number of grid lines x= x(i), i=1,lx
#             parallel to y-axis.
#     y       array of length ly for y-coordinates
#             in ascending order.
#     ly      number of grid lines y= y(i), i=1,ly
#             parallel to x-axis.
#     z       2-dimensional array dimensioned z(nxdim,...)
#             defining the z-values at the grid points.
#             the point with the coordinates x(k), y(l)
#             receives the value z(k,l), k=1,lx, l=1,ly.
#     nxdim   first dimension of array z
#     cn      array of length nc for the z-values of
#             the contours (contour levels)
#             in ascending order
#     icol    integer array of length nc+1 for
#             the colours to be used for the lines or areas.
#             values from this array are passed to
#             the user supplied subroutine usrplt.
#             icol(i) is used for the area, where
#                  z  >  cn(i-1)        and
#                  z  <=  cn(i),
#             for i=2,nc.
#             areas, where z <= cn(1)
#             are filled with colour icol(1),
#             and areas, where z > icol(nc)
#             are filled with colour icol(nc+1).
#     nc      number of contour levels, nc <= 100
#     mode          0, fill area only
#                   1, lines only
#                   2, fill area and lines
#     output
#     is performed by calls to the subroutine    usrplt
#     to be supplied by the user (an example for usrplt
#     is included.)
#     parameters of usrplt
#                subroutine usrplt (x,y,n,ncol,mode)
#                x,y     real arrays of length n for
#                        the coordinates of the polygon
#                        to be plotted.
#                n       number of points of polygon
#                ncol    colour to be used
#                        for the area or the line.
#                        for ncol, the program passes
#                        values of icol as described above.
#                mode    1, line drawing
#                        0, fill area
#     -------------------------------------------------------------
#     this module (farb2d) is based on subroutine sfcfit of
#          acm algorithm 474 by h.akima
# End of author intro.  Now to code.
# Define the generic error code.
# Define some labels for gotos.
# Declarations.
# [jde: Sorry about no comments, but there weren't any in the original]
#  to save the old values
# new computation
# End of farb2d
# farbrc - Fill area for a bicubic function on a rectangle
# Description
#   See below and for farb2d.
# History
#  16Jan91 - Rewritten into SPP.  Jonathan D. Eisenhamer, STScI.
#     f ill  ar ea  for a  b icubic function on a  r e c tangle
#     *      **            *                       *   *
#     t r i p   algorithm   a.preusser   farb-e-2d  version 2.1 10/1988
#     author: a. preusser
#             fritz-haber-institut der mpg
#             faradayweg 4-6
#             d-1000 berlin 33
#     this subroutine computes a bicubic function from the
#     values x,y,z,zx,zy,zxy given at the four vertices of
#     a rectangle, and plots contours for the z-values cn[i],
#     i=1,nc, using the colours icol[i].
#     area filling, set by parameter mode, is an optional feature.
#     input parameters - See below
#     ============================
#     output
#     ======
#     is performed by calls to the subroutine    usrplt
#     to be supplied by the user (an example for usrplt
#     is included).
#     parameters of usrplt
#                subroutine usrplt (x,y,n,ncol,mode)
#                x,y     real arrays of length n for
#                        the coordinates of the polygon
#                        to be plotted.
#                n       number of points of polygon
#                ncol    index  defining the colour for
#                        the area or the line
#                mode    1, line drawing
#                        0, fill area
#     if a rectangle receives only one colour,
#     the area is not filled at once.
#     instead, a 'fill area buffer' is opened
#     or updated, until a rectangle with a
#     different colour is encountered.
#     therefore, if the next call to farbrc
#     is not for a right-hand-neighbor,
#     or if it is the last call, subroutine
#            frbfcl
#     must be called by the user
#            call frbfcl(icol)  ,
#     in order to clear the fill area buffer,
#     and to fill the area of the rectangle.
#            denomination of the vertices and sides of the
#                           rectangle
#            y
#                            side(3)
#  vertex(2) * -------------------------------0-------- * vertex(1)
#            (                             .            )
#            (                           .              )
#            (                          .               )
#    side(4) (                          . ride          ) side(2)
#            (                           .              )
#            (                             .            )
#            (                                .         )
#  vertex(3) * ----------------------------------0----- * vertex(4)
#                            side(1)                        x
#     the sides are parallel to the cartesian x-y-system.
#   -----------------------------------------------------------------
#   end of user documentation
#   -----------------------------------------------------------------
#           some nomenclature
#     station      zero on a side
#     ride         move from one station to another inside rect.
#     transfer     move from one station to the next on side
#     trip         sequence of rides and transfers
#     round trip   successful trip that ended at its start
#     horror trip  trip that does not find an end
#     journey      sequence of trips starting from the same
#                  type of stations (same value of istatz)
#                  and having the same orientation.
#                  there may be three journeys.
#                  the first two are counter-clockwise and
#                  start at stations with istatz=0 and =2,
#                  respectively. the third journey is carried
#                  out only in case of numerical difficulties,
#                  when areas are unfilled after the first two.
#                  it starts at stations with istatz=1 or =0 and
#                  is clockwise.
# Declarations
# Function declarations.
# /frbcof/ contains variables which are passed to function
# frbeva as parameters
# frbcrd contains variables that are passed to frbrid
# or that are retained for the next call to farbrc (nside=3)
#              call usrplt(xx,yy,2,kcl,1)
#                call usrplt(xpol,ypol,npol1,ncl1,1)
#                 call usrplt(xpol[jpol+1],ypol[jpol+1],
#                             np,nclzr[jza2,jsa2],1)
#            call usrplt(xpol[jpoll1],ypol[jpoll1],np,nclzr[jz,js],1)
# End of farbrc
# frbfcl - Clear fill area buffer
# Description
#   See above in farb2d.
# History
#  17Jan91 - Rewritten into SPP.  Jonathan D. Eisenhamer, STScI.
# Declarations
# End of frbfcl
# frbrid - trace contour from side jsa to side jsa2 (ride from jsa,jza to jsa2,jza2)
# Description
#   See above in farb2d and below.
# Author
#   t r i p   algorithm   a.preusser   farb-e-2d  version 2.1 10/1988
# 
# 
#   author: a. preusser
#   fritz-haber-institut der mpg
#   faradayweg 4-6
#   d-1000 berlin 33
# 
# History
#  17Jan91 - Rewritten into SPP. Jonathan D. Eisenhamer, STScI.
# Declarations
# Function declarations.
# ds01= ds
# tracing stopped
# End of frbrid
# frbfop - open fill area buffer
# Description
#   See farb2d.
# History
#   17Jan91 - Rewritten into SPP. Jonathan D. Eisenhamer, STScI.
# Declarations
# End of frbfop
# frbfup - update fill area buffer
# Description
#   See farb2d.
# History
#   17Jan91 - Rewritten into SPP. Jonathan D. Eisenhamer, STScI.
# Declarations
# End of frbfup
# frbzer - Computer zero between limits.
# Description
#   The method is a combination of the regula falsi
#   and the midpoint method
# 
#   It is a modified version of the vim- (control data
#   user group) routine with catalog identification
#   c2bkyzero
#   written by loren p. meissner, 1965
# 
# Author
#   t r i p   algorithm   a.preusser   farb-e-2d  version 2.1 10/1988
# History
#   17Jan91 - Rewritten into SPP. Jonathan D. Eisenhamer, STScI.
# Declarations
# Function declarations.
# End of frbzer
# frbeva - function evaluation
# 
# Description
#   See farb2d.
# Author
#   t r i p   algorithm   a.preusser   farb-e-2d  version 2.1 10/1988
# 
#   author      : a. preusser
#   fritz-haber-institut
#   der max-planck-gesellschaft
#   faradayweg 4-6
#   d-1000 berlin 33
# History
#   17Jan91 - Rewritten into SPP.  Jonathan D. Eisenhamer, STScI.
# Declarations.
# variabels in /frbcof/ are used as arguments # for an explanation see
# subroutine farbrc 
# End of frbeva

###  Proprietary source code removed  ###
