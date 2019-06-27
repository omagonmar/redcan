#$Header: /home/pros/xray/xspatial/imfft/RCS/fourn.x,v 11.0 1997/11/06 16:33:12 prosb Exp $
#$Log: fourn.x,v $
#Revision 11.0  1997/11/06 16:33:12  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:55:41  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:16:05  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:36:59  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:21:44  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:35:12  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:43:58  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:28:01  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:15:53  pros
#General Release 1.0
#
#
# Module:       FOURN.X
# Project:      PROS -- ROSAT RSDC
# Purpose:    	perform n dimensional fft
# External:     four_n()
# Local:        
# Description:  
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} M. VanHilst  initial version 	3 November 1988
#               {n} <who> -- <does what> -- <when>
#

#  fourn.x
#
#  perform n dimensional fft
#
#  Smithsonian Astrophysical Observatory
#  3 November 1988
#  Michael VanHilst
#
#  four_n()


# fourn
#
# the ordering of data is:
# alternating real in imaginary values r[1],i[1],r[2],i[2],.. 
# dimension[1] line[1], dimension[1] line[2], dimension[1] line[3] ...
procedure fourn ( data, nn, ndim, isign )
real	data[ARB]	# multidimensional complex array
int	nn[ndim]	# array giving the lengths of each dimension
int	ndim		# number of dimensions
int	isign		# sign of transform (-1 for inverse transform)

double	wr, wi, wpr, wpi, wtemp, theta	# double for trig recurrences
real	tempr, tempi
int	ntot, idim, n, nprev, nrem
int	ip1, ip2, ip3, i1, i2, i3, i2rev, i3rev
int	k1, k2, ibit, ifp1, ifp2

begin
	ntot = 1
	do idim = 1, ndim {
	    ntot = ntot * nn[idim]
	}
	nprev = 1
	do idim = 1, ndim {
	    n = nn[idim]
	    nrem = ntot / (n * nprev)
	    ip1 = 2 * nprev
	    ip2 = ip1 * n
	    ip3 = ip2 * nrem
	    i2rev = 1
	    do i2 = 1, ip2, ip1 {
		if (i2 < i2rev) {
		    do i1 = i2, i2 + ip1 - 2, 2 {
			do i3 = i1, ip3, ip2 {
			    i3rev = i2rev + i3 - i2
			    tempr = data[i3]
			    tempi = data[i3+1]
			    data[i3] = data[i3rev]
			    data[i3+1] = data[i3rev+1]
			    data[i3rev] = tempr
			    data[i3rev+1] = tempi
			}
		    }
		}
		ibit = ip2 / 2
		while ((ibit > ip1) && (i2rev > ibit)) {
		    i2rev = i2rev - ibit
		    ibit = ibit / 2
		}
		i2rev = i2rev + ibit
	    }
	    ifp1 = ip1
	    while (ifp1 < ip2) {
		ifp2 = 2 * ifp1
		theta = isign * 6.28318530717959d0 / (ifp2 / ip1)
		wpr = -2.d0 * dsin (0.5d0 * theta)**2
		wpi = dsin(theta)
		wr = 1.d0
		wi = 0.d0
		do i3 = 1, ifp1, ip1 {
		    do i1 = i3, i3 + ip1 - 2, 2 {
			do i2 = i1, ip3, ifp2 {
			    k1 = i2
			    k2 = k1 + ifp1
			    tempr = real(wr) * data[k2] - real(wi) * data[k2+1]
			    tempi = real(wr) * data[k2+1] + real(wi) * data[k2]
			    data[k2] = data[k1] - tempr
			    data[k2+1] = data[k1+1] - tempi
			    data[k1] = data[k1] + tempr
			    data[k1+1] = data[k1+1] + tempi
			}
		    }
		    wtemp = wr
		    wr = wr * wpr - wi * wpi + wr
		    wi = wi * wpr + wtemp * wpi + wi
		}
		ifp1 = ifp2
	    }
	    nprev = n * nprev
	}
end
