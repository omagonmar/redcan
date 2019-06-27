#$Header: /home/pros/xray/xplot/imcontour/RCS/imc_subs.x,v 11.0 1997/11/06 16:38:11 prosb Exp $
#$Log: imc_subs.x,v $
#Revision 11.0  1997/11/06 16:38:11  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:09:01  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:02:19  prosb
#General Release 2.3.1
#
#Revision 7.2  94/05/15  11:55:21  janet
#jd - added title to wcslab call ... a blank string.
#
#Revision 7.1  94/03/01  11:23:32  janet
#jd - fixed sprintf statements, coordinated char sizes.
#
#Revision 7.0  93/12/27  18:48:44  prosb
#General Release 2.3
#
#Revision 6.1  93/12/17  08:55:57  janet
#*** empty log message ***
#
#Revision 6.0  93/05/24  16:41:14  prosb
#General Release 2.2
#
#Revision 5.1  93/04/06  11:55:33  janet
#interfaced with new wcslab code.
#
#Revision 5.0  92/10/29  22:35:17  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  17:32:52  prosb
#General Release 2.0:  April 1992
#
#Revision 3.2  92/01/15  13:31:41  janet
#*** empty log message ***
#
#Revision 3.1  91/08/06  20:46:36  prosb
#fixed for vax version, float(h) to double(h) in sign function
#
#Revision 3.0  91/08/02  01:24:05  prosb
#General Release 1.1
#
#Revision 1.1  91/07/26  03:02:43  wendy
#Initial revision
#
# ---------------------------------------------------------------------
#
# Module:       IMC_SUBS.X
# Project:      PROS -- ROSAT RSDC
# Purpose:      Imcontour Subroutines 
# Includes:     prad_hms(), prad_dms(), parse_wcs(), wcs_skymap(),
#               parse_section(), initcol()
# Modified:     {0} Janet DePonte -- May 1991 -- 
#               {1} JD -- July 1991 -- Added parse_wcs routine to create
#                         a subsection for wcslab call. Combines input 
#                         subsection with scale subsection
#               {2} JD -- Sept 1991 -- Added initcol for src table input
#               {n} <who> -- <when> -- <does what>
#
# ---------------------------------------------------------------------
include <ctype.h>
include <math.h>
include <mach.h>
include <gset.h>
include <imhdr.h>
include "imcontour.h"
include "clevels.h"
#----------------------------------------------------------------------
#
# Function:     prad_hms
# Purpose:      convert from radians to hr/mins/secs. Seconds have 
#               precision to 2 decimals.
#
# ---------------------------------------------------------------------
procedure prad_hms (rarad, hms, units, maxch)

double  rarad
char    hms[ARB]
char    units[ARB]
int     maxch

int     h, m
real    s
double  temp
char    ch[4], cm[4], cs[6]

begin
        units[1] = EOS
        hms[1]   = EOS

        if (rarad == 0.0) {
            # 0 hours RA
            call strcpy ("0 ", hms,   maxch)
            call strcpy (" h", units, maxch)
            return
        }

        temp = RADTOHRS (rarad)
        h = temp

        temp = temp - double (h)
        temp = temp * 60.0D0
        m = temp

        temp = temp - float (m)
        s = 60.D0 * temp

        h = sign(double(h), rarad)

        # Format fields - Hours:Minutes:Seconds
        if (h > 0) {
            # Non-zero hours
            call sprintf (ch, 4, " %02d ")
                call pargi (h)
            call strcat (ch, hms, maxch)
        } else {
            # Zero hours
            call strcat ("  0 ", hms, maxch)
        }
        call strcat ("   h", units, maxch)

        if (m > 0) {
            # Non-zero Minutes
            call sprintf (cm, 4, "%02d ")
                call pargi (m)
            call strcat (cm, hms, maxch)
        } else {
            # Zero minutes
            call strcat (" 0 ", hms, maxch)
        }
        call strcat ("  m", units, maxch)

        # Non-zero Seconds
        call sprintf (cs, 6, "%05.2f ")
           call pargr (s)
        call strcat (cs, hms, maxch)
        call strcat ("     s", units, maxch)

end


# ---------------------------------------------------------------------
#
# Function:     prad_dms
# Purpose:      convert from radians to deg/min/sec buffer. Seconds
#               have precision to 2 decimals.
#
# ---------------------------------------------------------------------
procedure prad_dms (arcrad, dms, units, maxch)

double  arcrad
char    dms[ARB]
char    units[ARB]
int     maxch

int     d, m
real    s
char    cd[4], cm[4], cs[6]
int     sec
double  temp

define  NDEC    0

begin
        units[1] = EOS
        dms[1]   = EOS

        # Integer seconds of arc
        sec = nint (RADTOSA(arcrad))

        # Sign of declination
        if (sec > 0)
            # North
            call strcpy ("+", dms, maxch)
        else if (sec < 0) {
            # South
            call strcpy ("-", dms, maxch)
            sec = -sec
        } else {
            # Zero declination
            call strcpy ("0 ", dms, maxch)
            call strcpy (" o", units, maxch)
            return
        }

	temp = abs (RADTODEG (arcrad))
        d = temp
	temp = temp - float(d)
	temp = temp * 60.0D0
	m = temp
	temp = temp - float(m)
	s = abs (60.0D0 * temp)

        # Degrees
        if (d > 0) {
            # Non-zero
            call sprintf (cd, 4, "%02d ")
                call pargi (d)
            call strcat (cd, dms, maxch)
        } else {
            call strcat (" 0 ", dms, maxch)
        }
        call strcpy ("   o", units, maxch)

        # Minutes of arc
        if (m > 0) {
            call sprintf (cm, 4, "%02d\'")
                call pargi (m)
            call strcat (cm, dms, maxch)
        } else {
            call strcat (" 0\'", dms, maxch)
        }
        call strcat ("   ", units, maxch)

        # Seconds of arc
        call sprintf (cs, 6, "%05.2f\"")
           call pargr (s)
        call strcat (cs, dms, maxch)
        call strcat ("      ", units, maxch)

end

#----------------------------------------------------------------------
#
# Function:     wcs_skymap
# Purpose:      Draw the skymap for an image.  Skymap code developed
#               at ST and called in routine wcslab.
#----------------------------------------------------------------------

procedure wcs_skymap (gp, img_fname, display)

pointer gp			#i: graphics pointer
char    img_fname[ARB]		#i: input image filename
int     display			#i: display level

int     il, ir, ib, it
pointer sp			# l: memory alloc pointer
pointer upd_fname		# l: updated filename
pointer im, mw			# l: image pointer
pointer title                   # l: title buffer
real    vl, vr, vb, vt		# l: virtual graphics pointers
real    wl, wr, wb, wt		# l: defined windo pointers
real    c1, c2, l1, l2

pointer immap()
pointer mw_openim()

begin

        call smark (sp)
        call salloc (upd_fname, SZ_PATHNAME, TY_CHAR)
	call salloc (title, SZ_LINE, TY_CHAR)

# Get plot attributes for a pixel windo
        call gseti (gp, G_WCS, PIX_WCS)
        call ggview (gp, vl, vr, vb, vt)
        call ggwind (gp, wl, wr, wb, wt)

#	call printf ("vl = %f, vr = %f, vb = %f, vt = %f\n")
#          call pargr (vl)
#          call pargr (vr)
#          call pargr (vb)
#          call pargr (vt)
#        call flush(STDOUT)

# Parse the image name and create a new image with subsections based
# on the combination of the user's input and the limits determined by
# imposing a scale on the image
 	call parse_section (img_fname, int(wl+0.5), int(wr+0.5), 
                   int(wb+0.5), int(wt+0.5), display, il, ir, ib, it,
                   Memc[upd_fname])

# Open the image with the adjusted subsection on it
        im = immap (Memc[upd_fname], READ_ONLY, 0)
        mw = mw_openim(im)

# call the wcslab code to draw the skymap
	c1= 1.0; c2 = real(IM_LEN(im,1))
        l1 = 1.0; l2 = real(IM_LEN(im,2))
	call strcpy (" ", Memc[title], SZ_LINE)
        call gseti (gp, G_WCS, MM_R_WCS)
        call wcslab (mw, c1, c2, l1, l2, gp, Memc[title])

#  old wcslab call
#       call wcslab(im, gp, Memc[upd_fname], " ", vl, vr, vb, vt)

# Get plot attributes for a pixel windo
        call gseti (gp, G_WCS, PIX_WCS)
        call ggview (gp, vl, vr, vb, vt)
        call ggwind (gp, wl, wr, wb, wt)

	call sfree(sp)
end

#----------------------------------------------------------------------
#
# Function:     parse_section
# Purpose:      Parse an image section of form "[50:150,50:150]"
#       	The image section input by the user and the image min and 
#               max determined by the code based on the scale (w[l,r,b,t]
#               variables, must be combined when calling the wcslab code so 
# 	        that the correct portion of the sky is display on top of 
#               the image.
#
# ---------------------------------------------------------------------

procedure  parse_section (img_fname, wl, wr, wb, wt, display, 
                          il, ir, ib, it,  upd_fname)

char		img_fname[ARB]		# i: input image file name
int		wl, wr, wb, wt		# i: window limits
int	        il, ir, ib, it		# l: image window limits
int             display                 # i: display level for print stmts
char		upd_fname[ARB]		# o: updated image file name

pointer isection , img_rootname		# l: image section specification
pointer sp, cluster, ksection
int     cl_index, cl_size
int     strlen()
int     ch, n, id, val[10], i, ip
int     hdist, vdist

begin

        call smark (sp)
        call salloc (cluster,  SZ_PATHNAME, TY_CHAR)
        call salloc (ksection, SZ_FNAME,    TY_CHAR)
	call salloc (isection, SZ_LINE,     TY_CHAR)
	call salloc (img_rootname,  SZ_LINE,     TY_CHAR)

#   Parse the image name and separate the name from the subsection
        call imparse (img_fname, Memc[img_rootname], SZ_PATHNAME,
            Memc[ksection], SZ_FNAME, Memc[isection], SZ_FNAME, 
            cl_index, cl_size)

        i = 1
        n = 0
        id = BEG 
        ip = 0

#       Determine the left, right, bottom, and top min's and max's
        for (ch= Memc[isection]; ch != EOS ; ch=Memc[isection+ip]) {
            if (IS_DIGIT(ch)) {
               n = (n * 10) + TO_INTEG(ch)
            } else if ( (ch == ':') | (ch == ',') ) {
                id = DONE
            } else if (ch == ']') {
		id = DONE
            }

	    if ( id == DONE ) {
	       val[i] = n
               i = i + 1
               id = BEG
               n = 0
	    }
            ip = ip + 1

        }

	if ( display >= 4 ) {

           call printf ("ksection = %s, cl_index = %d, cl_size = %d\n")
             call pargstr (Memc[ksection])
             call pargi (cl_index)
             call pargi (cl_size)

#   Display the input image subsection 
           call printf ("Subsection = %d %d %d %d\n")
             call pargi (val[1]) ;  call pargi (val[2])
             call pargi (val[3]) ;  call pargi (val[4])

#   Display the windo coords determined by the code
           call printf ("Windo Coords - %d %d %d %d\n")
	     call pargi (wl) ; call pargi (wr)
             call pargi (wb) ; call pargi (wt)
	}

#   Compute the new subsection, combining the input subsection with
#   the windo coordinates for the wcslab code

#   If no image section input - take the windo coords as the subsection
        if ( strlen (Memc[isection]) == 0 ) {
           il = wl
           ir = wr
           ib = wb
           it = wt

#   Image section input - combine with windo coordinates
        } else {
           hdist = wr - wl
           il = val[1] + wl - 1
           ir = il + hdist
           vdist = wt - wb
           ib = val[3] + wb - 1
           it = ib + vdist
        }

#   Store the new name with image section into the buffer for return
	   call sprintf (upd_fname, SZ_LINE, "%s%s[%d:%d,%d:%d]")
             call pargstr (Memc[img_rootname])
             call pargstr (Memc[ksection])
             call pargi (il)
	     call pargi (ir)
             call pargi (ib)
 	     call pargi (it)

#   Display the New image file name with subsection
	if ( display >= 4 ) {
           call printf ("New Image Name = %s\n")
             call pargstr (upd_fname)
	}

        call sfree (sp)
end

# ---------------------------------------------------------------------
#
# Function:     initcol
# Purpose:      initialize table column and return pointer
# Pre-cond:     table file opened
# Post-cond:    column initialized
#
# ---------------------------------------------------------------------
procedure initcol (tp, colname, col_tp)

pointer tp                      # i: table handle
char    colname[ARB]            # i: data column name
pointer col_tp                  # o: position table column pointers

pointer buff                    # l: local string buffer
pointer sp                      # l: stack pointer

begin

        call smark(sp)
        call salloc(buff, SZ_LINE, TY_CHAR)

#   get column pointer
        iferr (call tbcfnd (tp, colname, col_tp, 1)) {
          call sprintf(Memc[buff],SZ_LINE,"Column %s does NOT EXIST in Table")
             call pargstr (colname)
          call error(1, Memc[buff])
        }
        if (col_tp == NULL) {
          call sprintf(Memc[buff],SZ_LINE,"Column %s does NOT EXIST in Table")
             call pargstr (colname)
          call error(1, Memc[buff])
        }

        call sfree(sp)
end


