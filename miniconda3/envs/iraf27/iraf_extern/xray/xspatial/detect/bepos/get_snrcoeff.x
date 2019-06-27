#$Header: /home/pros/xray/xspatial/detect/bepos/RCS/get_snrcoeff.x,v 11.0 1997/11/06 16:32:05 prosb Exp $
#$Log: get_snrcoeff.x,v $
#Revision 11.0  1997/11/06 16:32:05  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:50:54  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:12:43  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:32:32  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:14:30  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:31:50  prosb
#General Release 2.1
#
#Revision 4.1  92/10/06  10:58:56  janet
#added header.
#
#Revision 4.0  92/04/27  14:38:55  prosb
#General Release 2.0:  April 1992
#
#Revision 1.1  92/03/29  14:33:12  janet
#Initial revision
#
#Revision 3.0  91/08/02  01:20:24  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:00:39  pros
#General Release 1.0
# ---------------------------------------------------------------------------
#
# Module:       get_snrcoeff.x
# Project:      PROS -- ROSAT RSDC
# Purpose:
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} JD -- initial version - converted to SPP -- 7/92
#               {n} <who> -- <does what> -- <when>
#
# ---------------------------------------------------------------------------
procedure get_snrcoeff (cell_area, num_coeffs, snr_coeffs, snr_min)

int	cell_area 		# i: area of a subcell in arc seconds
int	num_coeffs		# o: of snr cooefs for the cell
real	snr_coeffs[0:ARB]	# o: snr cooefs for the cell
real 	snr_min			# o: snr thresh lower limit

int     i			# l: loop counter
pointer plabel			# l: print buffer
pointer sp			# l: space allocation pointer

int    	clgeti()
real	clgetr()

begin

	call smark(sp)
	call salloc (plabel, SZ_LINE, TY_CHAR)
 
#    Build snr cooeficients parameter names and read from par file
       	call sprintf (Memc[plabel], SZ_LINE, "num_snr_coeffs")
      	num_coeffs = clgeti (Memc[plabel])

      	do i = 1, num_coeffs {
           call sprintf (Memc[plabel], SZ_LINE, "snr_%d_coeffs")
	     call pargi(i)
	   snr_coeffs[i-1] = clgetr(Memc[plabel])
	}

        call sprintf (Memc[plabel], SZ_LINE, "snr_thresh_min")
	snr_min = clgetr(Memc[plabel])

	call sfree(sp)
end
