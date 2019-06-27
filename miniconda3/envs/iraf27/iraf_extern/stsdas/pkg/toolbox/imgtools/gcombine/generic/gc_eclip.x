include	"../gcombine.h"

define	MINCLIP		2	# Mininum number of images for algorithm


# G_AERRCLIP -- Reject pixels using error about the weighted
# average. The error is taken from the error map
#
# CYZhang 19 May

procedure g_aerrclips (data, id, errdata, nimages, n, npts, average, szuw)

pointer	data[nimages]		# Data pointers
pointer	errdata[nimages]		# Error pointers
pointer	id[nimages]		# Image id pointers
int	n[npts]			# Number of good pixels
int	nimages			# Number of images
int	npts			# Number of output points per line
real	average[npts]		# Average
pointer	szuw

int	i, j, k, l, n1, n2, nk, idj, id1, id2, minkeep, lrej, ii
real	d1, d2, e1, e2, sum, a, low, high, s, r, one, zero
data	one, zero /1.0, 0.0/
pointer	sp, resid, dp1, dp2, ep1, ep2, ip1, ip2

include	"../gcombine.com"

begin
	# If there are insufficient pixels go on to the combining
	if (NKEEP < 0)
	    minkeep = max (0, nimages + NKEEP)
	else
	    minkeep = min (nimages, NKEEP)
	lrej = max (MINCLIP, minkeep+1)
	if (nimages < lrej) {
	    docombine = true
	    return
	} 
	
	# Since the unweighted average is computed here possibly skip combining
	# When weighted average or median is required, must call combine
	if (DOWTS || G_COMBINE == C_MEDIAN)
	    DOCOMBINE = true
	else
	    DOCOMBINE = false


	# Save the residuals and the sigma scaling corrections if needed.
	call smark (sp)
	call salloc (resid, nimages+1, TY_REAL)

	# Do error clipping.
	do i = 1, npts {
	    k = i - 1
	    n1 = n[i]
	    if (NKEEP < 0)
		minkeep = max (0, n1 + NKEEP)
	    else
		minkeep = min (n1, NKEEP)
	    lrej = max (MINCLIP, minkeep)
	    # If there are not enough pixels simply compute the average.
	    if (n1 < lrej) {
		if (!DOCOMBINE) {
		    if (n1 == 0)
			average[i] = BLANK
		    else {
			sum = Mems[data[1]+k]
			do j = 2, n1
			    sum = sum + Mems[data[j]+k]
			average[i] = sum / real(n1)
		    }
		}
		next
	    }

	    if (n1 == 2) {
		dp1 = data[1]+k
		ep1 = errdata[1]+k
		ip1 = id[1]+k
		d1 = Mems[dp1]
		id1 = Memi[ip1]
		e1 = Mems[ep1]
		d2 = Mems[data[2]+k]
		id2 = Memi[id[2]+k]
		e2 = Mems[errdata[2]+k]
		if (!DOCOMBINE)
		    average[i] = (d1 + d2) / 2.0
		if ((d1>0. && d1<=HSIGMA*e1 || d1<0. && d1>=-LSIGMA*e1) &&
		    (d2>0. && d2<=HSIGMA*e2 || d2<0. && d2>=-LSIGMA*e2)) 
		    next
		if (d1 < d2 && d1>-LSIGMA*e1) {
		    s = sqrt (e1**2 + e2**2)
		    if (s <= zero) 
			call error (0, "Noise map incorrect")
		    r = (d2 - d1) / s
		    if (r > HSIGMA) {
			if (!DOCOMBINE)
			    average[i] = d1
			n[i] = 1
		    } 
		    next
		} else if (d1>d2&& d2>-LSIGMA*e2) {
		    s = sqrt (e1**2 + e2**2)
		    if (s <= zero) 
			call error (0, "Noise map incorrect")
		    r = (d1 - d2) / s
		    if (r > HSIGMA) {
			n[i] = 1
			dp2 = data[2]+k
			ep2 = errdata[2]+k
			ip2 = id[2]+k
			Mems[dp1] = d2
			Mems[dp2] = d1
			Mems[ep1] = e2
			Mems[ep2] = e1
			Memi[ip1] = id2
			Memi[ip2] = id1
			if (!DOCOMBINE)
			    average[i] = d2	
		    }
		    next
		} else if (d1<-LSIGMA*e1 && d2<-LSIGMA*e2 && d1<d2) {
		    n[i] = 1
		    dp2 = data[2]+k
		    ep2 = errdata[2]+k
		    ip2 = id[2]+k
		    Mems[dp1] = d2
		    Mems[dp2] = d1
		    Mems[ep1] = e2
		    Mems[ep2] = e1
		    Memi[ip1] = id2
		    Memi[ip2] = id1
		    if (!DOCOMBINE) 
			average[i] = d2
		    next
		} else if (d1<-LSIGMA*e1 && d2<-LSIGMA*e2 && d1>d2) {
		    n[i] = 1
		    if (!DOCOMBINE) 
			average[i] = d1
		    next
		} else if (d1<-LSIGMA*e1 && d2>HSIGMA*e2 && abs(d1)>d2) {
		    n[i] = 1
		    dp2 = data[2]+k
		    ep2 = errdata[2]+k
		    ip2 = id[2]+k
		    Mems[dp1] = d2
		    Mems[dp2] = d1
		    Mems[ep1] = e2
		    Mems[ep2] = e1
		    Memi[ip1] = id2
		    Memi[ip2] = id1
		    if (!DOCOMBINE) 
			average[i] = d2
		    next
		} else if (d1<-LSIGMA*e1 && d2>HSIGMA*e2 && abs(d1)<d2) {
		    n[i] = 1
		    if (!DOCOMBINE) 
			average[i] = d1
		    next
		} else if (d1>HSIGMA*e1 && d2<-LSIGMA*e2 && abs(d2)<d1) {
		    n[i] = 1
		    dp2 = data[2]+k
		    ep2 = errdata[2]+k
		    ip2 = id[2]+k
		    Mems[dp1] = d2
		    Mems[dp2] = d1
		    Mems[ep1] = e2
		    Mems[ep2] = e1
		    Memi[ip1] = id2
		    Memi[ip2] = id1
		    if (!DOCOMBINE) 
			average[i] = d2
		    next
		} else if (d1>HSIGMA*e1 && d2<-LSIGMA*e2 && abs(d2)>d1) {
		    n[i] = 1
		    if (!DOCOMBINE) 
			average[i] = d1
		    next
		}
	    }

	    # Iteratively reject pixels
	    # Compact the data and keep track of the image IDs if needed.

	    repeat {
		# Average of the only two good pixels
		if (n1 == 2) {
		    sum = Mems[data[1]+k]
		    sum = sum + Mems[data[2]+k]
		    a = sum / 2
	    	} else {
	    	# Unweighted average with the high and low rejected
		    low = Mems[data[1]+k]
		    high = Mems[data[2]+k]
		    if (low > high) {
			d1 = low
			low = high
			high =d1
		    }
	        # Find low and high with masked bad pixels excluded
		    sum = zero
		    do j = 3, n1 {
		        d1 = Mems[data[j]+k]
		        if (d1 < low) {
			    sum = sum + low
			    low = d1
			} else if (d1 > high) {
			    sum = sum + high
			    high = d1
			} else
			    sum = sum + d1
	    	    }
		    a = sum / real(n1 - 2)
		    sum = sum + low + high
	    	}	
		n2 = n1
		# Reject pixels.  Save the residuals and data values.
		for (j=1; j<=n1; j=j+1) {
		    dp1 = data[j] + k
		    ep1 = errdata[j]+k
		    d1 = Mems[dp1]
		    e1 = Mems[ep1]
		    r = (d1 - a) / e1
		    if (r < -LSIGMA || r > HSIGMA) {
			Memr[resid+n1] = abs (r)
			if (j < n1) {
			    dp2 = data[n1] + k
			    Mems[dp1] = Mems[dp2]
			    Mems[dp2] = d1
			    ep2 = errdata[n1] + k
			    Mems[ep1] = Mems[ep2]
			    Mems[ep2] = e1
			    ip1 = id[j] + k
			    ip2 = id[n1] + k
			    idj = Memi[ip1]
			    Memi[ip1] = Memi[ip2]
			    Memi[ip2] = idj
			    j = j - 1
			}
			n1 = n1 - 1
		    }
		}
	    } until (n1 == n2 || n1 < lrej)

	    # If too many pixels are rejected add some back.
	    # All pixels with equal residuals are added back.
	    if (n1 < minkeep) {
		nk = minkeep
		for (j=n1+1; j<=nk; j=j+1) {
		    dp1 = data[j] + k
		    ep1 = errdata[j] + k
		    r = Memr[resid+j]
		    ii = 0
		    do l = j+1, n2 {
			s = Memr[resid+l]
			if (s < r + TOL) {
			    if (s > r - TOL)
				ii = ii + 1
			    else {
				ii = 0
				Memr[resid+l] = r
				r = s
				dp2 = data[l] + k
				d1 = Mems[dp1]
				Mems[dp1] = Mems[dp2]
				Mems[dp2] = d1
				ep2 = errdata[l] + k
				e1 = Mems[ep1]
				Mems[ep1] = Mems[ep2]
				Mems[ep2] = e1
				ip1 = id[j] + k
				ip2 = id[l] + k
				idj = Memi[ip1]
				Memi[ip1] = Memi[ip2]
				Memi[ip2] = idj
			    }
			}
		    }
		    n1 = n1 + 1
		    nk = max (nk, j+ii)
		}
	    }

	    # Save the average if needed.
	    n[i] = n1
	    if (!DOCOMBINE) {
		if (n1 == 0)
		    average[i] = BLANK
		else {
		    sum = Mems[data[1]+k]
		    do j = 2, n1
			sum = sum + Mems[data[j]+k]
		    average[i] = sum / real(n1)
		}
	    }
	}

	call sfree (sp)
end


# G_MERRCLIP -- Reject pixels using error clipping about the median
#  The weighted average sigma about median is computed based on the error
# taken from th error maps
#
# CYZhang 19 May 1994

procedure g_merrclips (data, id, errdata, nimages, n, npts, median, szuw)

pointer	data[nimages]		# Data pointers
pointer	errdata[nimages]	# Error pointers
pointer	id[nimages]		# Image IDs
int	n[npts]			# Number of good pixels
int	nimages			# Number of images
int	npts			# Number of output points per line
real	median[npts]		# Median
pointer	szuw

int	i, j, k, l, n1, n2, n3, nl, nh, id1, id2, minkeep, lrej
pointer	sp, resid
real	d1, d2, e1, e2, med, r, s, one, zero
data	one, zero /1.0, 0.0/
pointer	dp1, dp2, ep1, ep2, ip1, ip2

include	"../gcombine.com"

begin
	# If there are insufficient pixels go on to the combining
	if (NKEEP < 0)
	    minkeep = max (0, nimages + NKEEP)
	else
	    minkeep = min (nimages, NKEEP)
	lrej = max (MINCLIP, minkeep+1)
	if (nimages < lrej) {
	    DOCOMBINE = true
	    return
	}

	# Save the residuals and sigma scaling corrections if needed.
	call smark (sp)
	call salloc (resid, nimages+1, TY_REAL)

	# Compute median and sigma and iteratively clip.

	do i = 1, npts {
	    k = i - 1
	    n1 = n[i]
	    if (NKEEP < 0)
		minkeep = max (0, n1 + NKEEP)
	    else
		minkeep = min (n1, NKEEP)
	    lrej = max (MINCLIP, minkeep+1)

	    if (n1 == 2) {
		dp1 = data[1]+k
		ep1 = errdata[1]+k
		ip1 = id[1]+k
		d1 = Mems[dp1]
		id1 = Memi[ip1]
		e1 = Mems[ep1]
		d2 = Mems[data[2]+k]
		id2 = Memi[id[2]+k]
		e2 = Mems[errdata[2]+k]
		if (!DOCOMBINE)
		    median[i] = (d1 + d2) / 2.0
		if ((d1>0. && d1<=HSIGMA*e1 || d1<0. && d1>=-LSIGMA*e1) &&
		    (d2>0. && d2<=HSIGMA*e2 || d2<0. && d2>=-LSIGMA*e2)) 
		    next
		if (d1 < d2 && d1>-LSIGMA*e1) {
		    s = sqrt (e1**2 + e2**2)
		    if (s <= zero) 
			call error (0, "Noise map incorrect")
		    r = (d2 - d1) / s
		    if (r > HSIGMA) {
			if (!DOCOMBINE)
			    median[i] = d1
			n[i] = 1
		    } 
		    next
		} else if (d1>d2&& d2>-LSIGMA*e2) {
		    s = sqrt (e1**2 + e2**2)
		    if (s <= zero) 
			call error (0, "Noise map incorrect")
		    r = (d1 - d2) / s
		    if (r > HSIGMA) {
			n[i] = 1
			dp2 = data[2]+k
			ep2 = errdata[2]+k
			ip2 = id[2]+k
			Mems[dp1] = d2
			Mems[dp2] = d1
			Mems[ep1] = e2
			Mems[ep2] = e1
			Memi[ip1] = id2
			Memi[ip2] = id1
			if (!DOCOMBINE)
			    median[i] = d2	
		    }
		    next
		} else if (d1<-LSIGMA*e1 && d2<-LSIGMA*e2 && d1<d2) {
		    n[i] = 1
		    dp2 = data[2]+k
		    ep2 = errdata[2]+k
		    ip2 = id[2]+k
		    Mems[dp1] = d2
		    Mems[dp2] = d1
		    Mems[ep1] = e2
		    Mems[ep2] = e1
		    Memi[ip1] = id2
		    Memi[ip2] = id1
		    if (!DOCOMBINE) 
			median[i] = d2
		    next
		} else if (d1<-LSIGMA*e1 && d2<-LSIGMA*e2 && d1>d2) {
		    n[i] = 1
		    if (!DOCOMBINE) 
			median[i] = d1
		    next
		} else if (d1<-LSIGMA*e1 && d2>HSIGMA*e2 && abs(d1)>d2) {
		    n[i] = 1
		    dp2 = data[2]+k
		    ep2 = errdata[2]+k
		    ip2 = id[2]+k
		    Mems[dp1] = d2
		    Mems[dp2] = d1
		    Mems[ep1] = e2
		    Mems[ep2] = e1
		    Memi[ip1] = id2
		    Memi[ip2] = id1
		    if (!DOCOMBINE) 
			median[i] = d2
		    next
		} else if (d1<-LSIGMA*e1 && d2>HSIGMA*e2 && abs(d1)<d2) {
		    n[i] = 1
		    if (!DOCOMBINE) 
			median[i] = d1
		    next
		} else if (d1>HSIGMA*e1 && d2<-LSIGMA*e2 && abs(d2)<d1) {
		    n[i] = 1
		    dp2 = data[2]+k
		    ep2 = errdata[2]+k
		    ip2 = id[2]+k
		    Mems[dp1] = d2
		    Mems[dp2] = d1
		    Mems[ep1] = e2
		    Mems[ep2] = e1
		    Memi[ip1] = id2
		    Memi[ip2] = id1
		    if (!DOCOMBINE) 
			median[i] = d2
		    next
		} else if (d1>HSIGMA*e1 && d2<-LSIGMA*e2 && abs(d2)>d1) {
		    n[i] = 1
		    if (!DOCOMBINE) 
			median[i] = d1
		    next
		}
	    }

	    nl = 1
	    nh = n1

	    repeat {
		n2 = n1
		n3 = nl + n1 / 2

		if (n1 == 0)
		    med = BLANK
		else if (mod (n1, 2) == 0)
		    med = (Mems[data[n3-1]+k] + Mems[data[n3]+k]) / 2.
		else
		    med = Mems[data[n3]+k]

		if (n1 >= lrej) {
		    # Reject pixels and save the residuals.
		    for (; nl <= n2; nl = nl + 1) {
			d1 = Mems[data[nl]+k]
			e1 = Mems[errdata[nl]+k]
                        # Must test explicitly for error == 0 (IB, 1/18/99)
			if (e1 < 0.0) {
			    call eprintf ("Warning: noise should not be negative")
			    break
			} else if (e1 == 0.0)
                            r = 0.0
                        else 
			    r = (med - d1) / e1
			if (r <= LSIGMA)
			    break
			Memr[resid+nl] = r
			n1 = n1 - 1
		    }
		    for (; nh >= nl; nh = nh - 1) {
			d1 = Mems[data[nh]+k]
			e1 = Mems[errdata[nh]+k]
                        # Must test explicitly for error == 0 (IB, 1/18/99)
			if (e1 < 0.0) {
			    call eprintf ("Warning: noise should not be negative")
			    break
			} else if (e1 == 0.0)
                            r = 0.0
                        else
			    r = (d1 -  med) / e1
			if (r <= HSIGMA)
			    break
			Memr[resid+nh] = r
			n1 = n1 - 1
		    }
		}
	    } until (n1 == n2 || n1 < lrej)

	    # If too many pixels are rejected add some back.
	    # All pixels with equal residuals are added back.
	    while (n1 < minkeep) {
		if (nl == 1)
		    nh = nh + 1
		else if (nh == n[i])
		    nl = nl - 1
		else {
		    r = Memr[resid+nl-1]
		    s = Memr[resid+nh+1]
		    if (r < s) {
			nl = nl - 1
			r = r + TOL
			if (s <= r)
			    nh = nh + 1
			if (nl > 1) {
			    if (Memr[resid+nl-1] <= r)
				nl = nl - 1
			}
		    } else {
			nh = nh + 1
			s = s + TOL
			if (r <= s)
			    nl = nl - 1
			if (nh < n2) {
			    if (Memr[resid+nh+1] <= s)
				nh = nh + 1
			}
		    }
		}
		n1 = nh - nl + 1
	    }

	    # Only set median and reorder if needed
	    n[i] = n1
	    if (n1 > 0 && nl > 1 && G_COMBINE != C_MEDIAN) {
		j = max (nl, n1 + 1)
		do l = 1, min (nl-1, n1) {
		    Mems[data[l]+k] = Mems[data[j]+k]
		    Mems[errdata[l]+k] = Mems[errdata[j]+k]
		    Memi[id[l]+k] = Memi[id[j]+k]
		    j = j + 1
		}
	    }

	    if (G_COMBINE == C_MEDIAN)
		median[i] = med
	}

	# Flag that the median has been computed.
	if (G_COMBINE == C_MEDIAN)
	    DOCOMBINE = false
	else
	    DOCOMBINE = true

	call sfree (sp)
end

# G_AERRCLIP -- Reject pixels using error about the weighted
# average. The error is taken from the error map
#
# CYZhang 19 May

procedure g_aerrclipi (data, id, errdata, nimages, n, npts, average, szuw)

pointer	data[nimages]		# Data pointers
pointer	errdata[nimages]		# Error pointers
pointer	id[nimages]		# Image id pointers
int	n[npts]			# Number of good pixels
int	nimages			# Number of images
int	npts			# Number of output points per line
real	average[npts]		# Average
pointer	szuw

int	i, j, k, l, n1, n2, nk, idj, id1, id2, minkeep, lrej, ii
real	d1, d2, e1, e2, sum, a, low, high, s, r, one, zero
data	one, zero /1.0, 0.0/
pointer	sp, resid, dp1, dp2, ep1, ep2, ip1, ip2

include	"../gcombine.com"

begin
	# If there are insufficient pixels go on to the combining
	if (NKEEP < 0)
	    minkeep = max (0, nimages + NKEEP)
	else
	    minkeep = min (nimages, NKEEP)
	lrej = max (MINCLIP, minkeep+1)
	if (nimages < lrej) {
	    docombine = true
	    return
	} 
	
	# Since the unweighted average is computed here possibly skip combining
	# When weighted average or median is required, must call combine
	if (DOWTS || G_COMBINE == C_MEDIAN)
	    DOCOMBINE = true
	else
	    DOCOMBINE = false


	# Save the residuals and the sigma scaling corrections if needed.
	call smark (sp)
	call salloc (resid, nimages+1, TY_REAL)

	# Do error clipping.
	do i = 1, npts {
	    k = i - 1
	    n1 = n[i]
	    if (NKEEP < 0)
		minkeep = max (0, n1 + NKEEP)
	    else
		minkeep = min (n1, NKEEP)
	    lrej = max (MINCLIP, minkeep)
	    # If there are not enough pixels simply compute the average.
	    if (n1 < lrej) {
		if (!DOCOMBINE) {
		    if (n1 == 0)
			average[i] = BLANK
		    else {
			sum = Memi[data[1]+k]
			do j = 2, n1
			    sum = sum + Memi[data[j]+k]
			average[i] = sum / real(n1)
		    }
		}
		next
	    }

	    if (n1 == 2) {
		dp1 = data[1]+k
		ep1 = errdata[1]+k
		ip1 = id[1]+k
		d1 = Memi[dp1]
		id1 = Memi[ip1]
		e1 = Memi[ep1]
		d2 = Memi[data[2]+k]
		id2 = Memi[id[2]+k]
		e2 = Memi[errdata[2]+k]
		if (!DOCOMBINE)
		    average[i] = (d1 + d2) / 2.0
		if ((d1>0. && d1<=HSIGMA*e1 || d1<0. && d1>=-LSIGMA*e1) &&
		    (d2>0. && d2<=HSIGMA*e2 || d2<0. && d2>=-LSIGMA*e2)) 
		    next
		if (d1 < d2 && d1>-LSIGMA*e1) {
		    s = sqrt (e1**2 + e2**2)
		    if (s <= zero) 
			call error (0, "Noise map incorrect")
		    r = (d2 - d1) / s
		    if (r > HSIGMA) {
			if (!DOCOMBINE)
			    average[i] = d1
			n[i] = 1
		    } 
		    next
		} else if (d1>d2&& d2>-LSIGMA*e2) {
		    s = sqrt (e1**2 + e2**2)
		    if (s <= zero) 
			call error (0, "Noise map incorrect")
		    r = (d1 - d2) / s
		    if (r > HSIGMA) {
			n[i] = 1
			dp2 = data[2]+k
			ep2 = errdata[2]+k
			ip2 = id[2]+k
			Memi[dp1] = d2
			Memi[dp2] = d1
			Memi[ep1] = e2
			Memi[ep2] = e1
			Memi[ip1] = id2
			Memi[ip2] = id1
			if (!DOCOMBINE)
			    average[i] = d2	
		    }
		    next
		} else if (d1<-LSIGMA*e1 && d2<-LSIGMA*e2 && d1<d2) {
		    n[i] = 1
		    dp2 = data[2]+k
		    ep2 = errdata[2]+k
		    ip2 = id[2]+k
		    Memi[dp1] = d2
		    Memi[dp2] = d1
		    Memi[ep1] = e2
		    Memi[ep2] = e1
		    Memi[ip1] = id2
		    Memi[ip2] = id1
		    if (!DOCOMBINE) 
			average[i] = d2
		    next
		} else if (d1<-LSIGMA*e1 && d2<-LSIGMA*e2 && d1>d2) {
		    n[i] = 1
		    if (!DOCOMBINE) 
			average[i] = d1
		    next
		} else if (d1<-LSIGMA*e1 && d2>HSIGMA*e2 && abs(d1)>d2) {
		    n[i] = 1
		    dp2 = data[2]+k
		    ep2 = errdata[2]+k
		    ip2 = id[2]+k
		    Memi[dp1] = d2
		    Memi[dp2] = d1
		    Memi[ep1] = e2
		    Memi[ep2] = e1
		    Memi[ip1] = id2
		    Memi[ip2] = id1
		    if (!DOCOMBINE) 
			average[i] = d2
		    next
		} else if (d1<-LSIGMA*e1 && d2>HSIGMA*e2 && abs(d1)<d2) {
		    n[i] = 1
		    if (!DOCOMBINE) 
			average[i] = d1
		    next
		} else if (d1>HSIGMA*e1 && d2<-LSIGMA*e2 && abs(d2)<d1) {
		    n[i] = 1
		    dp2 = data[2]+k
		    ep2 = errdata[2]+k
		    ip2 = id[2]+k
		    Memi[dp1] = d2
		    Memi[dp2] = d1
		    Memi[ep1] = e2
		    Memi[ep2] = e1
		    Memi[ip1] = id2
		    Memi[ip2] = id1
		    if (!DOCOMBINE) 
			average[i] = d2
		    next
		} else if (d1>HSIGMA*e1 && d2<-LSIGMA*e2 && abs(d2)>d1) {
		    n[i] = 1
		    if (!DOCOMBINE) 
			average[i] = d1
		    next
		}
	    }

	    # Iteratively reject pixels
	    # Compact the data and keep track of the image IDs if needed.

	    repeat {
		# Average of the only two good pixels
		if (n1 == 2) {
		    sum = Memi[data[1]+k]
		    sum = sum + Memi[data[2]+k]
		    a = sum / 2
	    	} else {
	    	# Unweighted average with the high and low rejected
		    low = Memi[data[1]+k]
		    high = Memi[data[2]+k]
		    if (low > high) {
			d1 = low
			low = high
			high =d1
		    }
	        # Find low and high with masked bad pixels excluded
		    sum = zero
		    do j = 3, n1 {
		        d1 = Memi[data[j]+k]
		        if (d1 < low) {
			    sum = sum + low
			    low = d1
			} else if (d1 > high) {
			    sum = sum + high
			    high = d1
			} else
			    sum = sum + d1
	    	    }
		    a = sum / real(n1 - 2)
		    sum = sum + low + high
	    	}	
		n2 = n1
		# Reject pixels.  Save the residuals and data values.
		for (j=1; j<=n1; j=j+1) {
		    dp1 = data[j] + k
		    ep1 = errdata[j]+k
		    d1 = Memi[dp1]
		    e1 = Memi[ep1]
		    r = (d1 - a) / e1
		    if (r < -LSIGMA || r > HSIGMA) {
			Memr[resid+n1] = abs (r)
			if (j < n1) {
			    dp2 = data[n1] + k
			    Memi[dp1] = Memi[dp2]
			    Memi[dp2] = d1
			    ep2 = errdata[n1] + k
			    Memi[ep1] = Memi[ep2]
			    Memi[ep2] = e1
			    ip1 = id[j] + k
			    ip2 = id[n1] + k
			    idj = Memi[ip1]
			    Memi[ip1] = Memi[ip2]
			    Memi[ip2] = idj
			    j = j - 1
			}
			n1 = n1 - 1
		    }
		}
	    } until (n1 == n2 || n1 < lrej)

	    # If too many pixels are rejected add some back.
	    # All pixels with equal residuals are added back.
	    if (n1 < minkeep) {
		nk = minkeep
		for (j=n1+1; j<=nk; j=j+1) {
		    dp1 = data[j] + k
		    ep1 = errdata[j] + k
		    r = Memr[resid+j]
		    ii = 0
		    do l = j+1, n2 {
			s = Memr[resid+l]
			if (s < r + TOL) {
			    if (s > r - TOL)
				ii = ii + 1
			    else {
				ii = 0
				Memr[resid+l] = r
				r = s
				dp2 = data[l] + k
				d1 = Memi[dp1]
				Memi[dp1] = Memi[dp2]
				Memi[dp2] = d1
				ep2 = errdata[l] + k
				e1 = Memi[ep1]
				Memi[ep1] = Memi[ep2]
				Memi[ep2] = e1
				ip1 = id[j] + k
				ip2 = id[l] + k
				idj = Memi[ip1]
				Memi[ip1] = Memi[ip2]
				Memi[ip2] = idj
			    }
			}
		    }
		    n1 = n1 + 1
		    nk = max (nk, j+ii)
		}
	    }

	    # Save the average if needed.
	    n[i] = n1
	    if (!DOCOMBINE) {
		if (n1 == 0)
		    average[i] = BLANK
		else {
		    sum = Memi[data[1]+k]
		    do j = 2, n1
			sum = sum + Memi[data[j]+k]
		    average[i] = sum / real(n1)
		}
	    }
	}

	call sfree (sp)
end


# G_MERRCLIP -- Reject pixels using error clipping about the median
#  The weighted average sigma about median is computed based on the error
# taken from th error maps
#
# CYZhang 19 May 1994

procedure g_merrclipi (data, id, errdata, nimages, n, npts, median, szuw)

pointer	data[nimages]		# Data pointers
pointer	errdata[nimages]	# Error pointers
pointer	id[nimages]		# Image IDs
int	n[npts]			# Number of good pixels
int	nimages			# Number of images
int	npts			# Number of output points per line
real	median[npts]		# Median
pointer	szuw

int	i, j, k, l, n1, n2, n3, nl, nh, id1, id2, minkeep, lrej
pointer	sp, resid
real	d1, d2, e1, e2, med, r, s, one, zero
data	one, zero /1.0, 0.0/
pointer	dp1, dp2, ep1, ep2, ip1, ip2

include	"../gcombine.com"

begin
	# If there are insufficient pixels go on to the combining
	if (NKEEP < 0)
	    minkeep = max (0, nimages + NKEEP)
	else
	    minkeep = min (nimages, NKEEP)
	lrej = max (MINCLIP, minkeep+1)
	if (nimages < lrej) {
	    DOCOMBINE = true
	    return
	}

	# Save the residuals and sigma scaling corrections if needed.
	call smark (sp)
	call salloc (resid, nimages+1, TY_REAL)

	# Compute median and sigma and iteratively clip.

	do i = 1, npts {
	    k = i - 1
	    n1 = n[i]
	    if (NKEEP < 0)
		minkeep = max (0, n1 + NKEEP)
	    else
		minkeep = min (n1, NKEEP)
	    lrej = max (MINCLIP, minkeep+1)

	    if (n1 == 2) {
		dp1 = data[1]+k
		ep1 = errdata[1]+k
		ip1 = id[1]+k
		d1 = Memi[dp1]
		id1 = Memi[ip1]
		e1 = Memi[ep1]
		d2 = Memi[data[2]+k]
		id2 = Memi[id[2]+k]
		e2 = Memi[errdata[2]+k]
		if (!DOCOMBINE)
		    median[i] = (d1 + d2) / 2.0
		if ((d1>0. && d1<=HSIGMA*e1 || d1<0. && d1>=-LSIGMA*e1) &&
		    (d2>0. && d2<=HSIGMA*e2 || d2<0. && d2>=-LSIGMA*e2)) 
		    next
		if (d1 < d2 && d1>-LSIGMA*e1) {
		    s = sqrt (e1**2 + e2**2)
		    if (s <= zero) 
			call error (0, "Noise map incorrect")
		    r = (d2 - d1) / s
		    if (r > HSIGMA) {
			if (!DOCOMBINE)
			    median[i] = d1
			n[i] = 1
		    } 
		    next
		} else if (d1>d2&& d2>-LSIGMA*e2) {
		    s = sqrt (e1**2 + e2**2)
		    if (s <= zero) 
			call error (0, "Noise map incorrect")
		    r = (d1 - d2) / s
		    if (r > HSIGMA) {
			n[i] = 1
			dp2 = data[2]+k
			ep2 = errdata[2]+k
			ip2 = id[2]+k
			Memi[dp1] = d2
			Memi[dp2] = d1
			Memi[ep1] = e2
			Memi[ep2] = e1
			Memi[ip1] = id2
			Memi[ip2] = id1
			if (!DOCOMBINE)
			    median[i] = d2	
		    }
		    next
		} else if (d1<-LSIGMA*e1 && d2<-LSIGMA*e2 && d1<d2) {
		    n[i] = 1
		    dp2 = data[2]+k
		    ep2 = errdata[2]+k
		    ip2 = id[2]+k
		    Memi[dp1] = d2
		    Memi[dp2] = d1
		    Memi[ep1] = e2
		    Memi[ep2] = e1
		    Memi[ip1] = id2
		    Memi[ip2] = id1
		    if (!DOCOMBINE) 
			median[i] = d2
		    next
		} else if (d1<-LSIGMA*e1 && d2<-LSIGMA*e2 && d1>d2) {
		    n[i] = 1
		    if (!DOCOMBINE) 
			median[i] = d1
		    next
		} else if (d1<-LSIGMA*e1 && d2>HSIGMA*e2 && abs(d1)>d2) {
		    n[i] = 1
		    dp2 = data[2]+k
		    ep2 = errdata[2]+k
		    ip2 = id[2]+k
		    Memi[dp1] = d2
		    Memi[dp2] = d1
		    Memi[ep1] = e2
		    Memi[ep2] = e1
		    Memi[ip1] = id2
		    Memi[ip2] = id1
		    if (!DOCOMBINE) 
			median[i] = d2
		    next
		} else if (d1<-LSIGMA*e1 && d2>HSIGMA*e2 && abs(d1)<d2) {
		    n[i] = 1
		    if (!DOCOMBINE) 
			median[i] = d1
		    next
		} else if (d1>HSIGMA*e1 && d2<-LSIGMA*e2 && abs(d2)<d1) {
		    n[i] = 1
		    dp2 = data[2]+k
		    ep2 = errdata[2]+k
		    ip2 = id[2]+k
		    Memi[dp1] = d2
		    Memi[dp2] = d1
		    Memi[ep1] = e2
		    Memi[ep2] = e1
		    Memi[ip1] = id2
		    Memi[ip2] = id1
		    if (!DOCOMBINE) 
			median[i] = d2
		    next
		} else if (d1>HSIGMA*e1 && d2<-LSIGMA*e2 && abs(d2)>d1) {
		    n[i] = 1
		    if (!DOCOMBINE) 
			median[i] = d1
		    next
		}
	    }

	    nl = 1
	    nh = n1

	    repeat {
		n2 = n1
		n3 = nl + n1 / 2

		if (n1 == 0)
		    med = BLANK
		else if (mod (n1, 2) == 0)
		    med = (Memi[data[n3-1]+k] + Memi[data[n3]+k]) / 2.
		else
		    med = Memi[data[n3]+k]

		if (n1 >= lrej) {
		    # Reject pixels and save the residuals.
		    for (; nl <= n2; nl = nl + 1) {
			d1 = Memi[data[nl]+k]
			e1 = Memi[errdata[nl]+k]
                        # Must test explicitly for error == 0 (IB, 1/18/99)
			if (e1 < 0.0) {
			    call eprintf ("Warning: noise should not be negative")
			    break
			} else if (e1 == 0.0)
                            r = 0.0
                        else 
			    r = (med - d1) / e1
			if (r <= LSIGMA)
			    break
			Memr[resid+nl] = r
			n1 = n1 - 1
		    }
		    for (; nh >= nl; nh = nh - 1) {
			d1 = Memi[data[nh]+k]
			e1 = Memi[errdata[nh]+k]
                        # Must test explicitly for error == 0 (IB, 1/18/99)
			if (e1 < 0.0) {
			    call eprintf ("Warning: noise should not be negative")
			    break
			} else if (e1 == 0.0)
                            r = 0.0
                        else
			    r = (d1 -  med) / e1
			if (r <= HSIGMA)
			    break
			Memr[resid+nh] = r
			n1 = n1 - 1
		    }
		}
	    } until (n1 == n2 || n1 < lrej)

	    # If too many pixels are rejected add some back.
	    # All pixels with equal residuals are added back.
	    while (n1 < minkeep) {
		if (nl == 1)
		    nh = nh + 1
		else if (nh == n[i])
		    nl = nl - 1
		else {
		    r = Memr[resid+nl-1]
		    s = Memr[resid+nh+1]
		    if (r < s) {
			nl = nl - 1
			r = r + TOL
			if (s <= r)
			    nh = nh + 1
			if (nl > 1) {
			    if (Memr[resid+nl-1] <= r)
				nl = nl - 1
			}
		    } else {
			nh = nh + 1
			s = s + TOL
			if (r <= s)
			    nl = nl - 1
			if (nh < n2) {
			    if (Memr[resid+nh+1] <= s)
				nh = nh + 1
			}
		    }
		}
		n1 = nh - nl + 1
	    }

	    # Only set median and reorder if needed
	    n[i] = n1
	    if (n1 > 0 && nl > 1 && G_COMBINE != C_MEDIAN) {
		j = max (nl, n1 + 1)
		do l = 1, min (nl-1, n1) {
		    Memi[data[l]+k] = Memi[data[j]+k]
		    Memi[errdata[l]+k] = Memi[errdata[j]+k]
		    Memi[id[l]+k] = Memi[id[j]+k]
		    j = j + 1
		}
	    }

	    if (G_COMBINE == C_MEDIAN)
		median[i] = med
	}

	# Flag that the median has been computed.
	if (G_COMBINE == C_MEDIAN)
	    DOCOMBINE = false
	else
	    DOCOMBINE = true

	call sfree (sp)
end

# G_AERRCLIP -- Reject pixels using error about the weighted
# average. The error is taken from the error map
#
# CYZhang 19 May

procedure g_aerrclipr (data, id, errdata, nimages, n, npts, average, szuw)

pointer	data[nimages]		# Data pointers
pointer	errdata[nimages]		# Error pointers
pointer	id[nimages]		# Image id pointers
int	n[npts]			# Number of good pixels
int	nimages			# Number of images
int	npts			# Number of output points per line
real	average[npts]		# Average
pointer	szuw

int	i, j, k, l, n1, n2, nk, idj, id1, id2, minkeep, lrej, ii
real	d1, d2, e1, e2, sum, a, low, high, s, r, one, zero
data	one, zero /1.0, 0.0/
pointer	sp, resid, dp1, dp2, ep1, ep2, ip1, ip2

include	"../gcombine.com"

begin
	# If there are insufficient pixels go on to the combining
	if (NKEEP < 0)
	    minkeep = max (0, nimages + NKEEP)
	else
	    minkeep = min (nimages, NKEEP)
	lrej = max (MINCLIP, minkeep+1)
	if (nimages < lrej) {
	    docombine = true
	    return
	} 
	
	# Since the unweighted average is computed here possibly skip combining
	# When weighted average or median is required, must call combine
	if (DOWTS || G_COMBINE == C_MEDIAN)
	    DOCOMBINE = true
	else
	    DOCOMBINE = false


	# Save the residuals and the sigma scaling corrections if needed.
	call smark (sp)
	call salloc (resid, nimages+1, TY_REAL)

	# Do error clipping.
	do i = 1, npts {
	    k = i - 1
	    n1 = n[i]
	    if (NKEEP < 0)
		minkeep = max (0, n1 + NKEEP)
	    else
		minkeep = min (n1, NKEEP)
	    lrej = max (MINCLIP, minkeep)
	    # If there are not enough pixels simply compute the average.
	    if (n1 < lrej) {
		if (!DOCOMBINE) {
		    if (n1 == 0)
			average[i] = BLANK
		    else {
			sum = Memr[data[1]+k]
			do j = 2, n1
			    sum = sum + Memr[data[j]+k]
			average[i] = sum / real(n1)
		    }
		}
		next
	    }

	    if (n1 == 2) {
		dp1 = data[1]+k
		ep1 = errdata[1]+k
		ip1 = id[1]+k
		d1 = Memr[dp1]
		id1 = Memi[ip1]
		e1 = Memr[ep1]
		d2 = Memr[data[2]+k]
		id2 = Memi[id[2]+k]
		e2 = Memr[errdata[2]+k]
		if (!DOCOMBINE)
		    average[i] = (d1 + d2) / 2.0
		if ((d1>0. && d1<=HSIGMA*e1 || d1<0. && d1>=-LSIGMA*e1) &&
		    (d2>0. && d2<=HSIGMA*e2 || d2<0. && d2>=-LSIGMA*e2)) 
		    next
		if (d1 < d2 && d1>-LSIGMA*e1) {
		    s = sqrt (e1**2 + e2**2)
		    if (s <= zero) 
			call error (0, "Noise map incorrect")
		    r = (d2 - d1) / s
		    if (r > HSIGMA) {
			if (!DOCOMBINE)
			    average[i] = d1
			n[i] = 1
		    } 
		    next
		} else if (d1>d2&& d2>-LSIGMA*e2) {
		    s = sqrt (e1**2 + e2**2)
		    if (s <= zero) 
			call error (0, "Noise map incorrect")
		    r = (d1 - d2) / s
		    if (r > HSIGMA) {
			n[i] = 1
			dp2 = data[2]+k
			ep2 = errdata[2]+k
			ip2 = id[2]+k
			Memr[dp1] = d2
			Memr[dp2] = d1
			Memr[ep1] = e2
			Memr[ep2] = e1
			Memi[ip1] = id2
			Memi[ip2] = id1
			if (!DOCOMBINE)
			    average[i] = d2	
		    }
		    next
		} else if (d1<-LSIGMA*e1 && d2<-LSIGMA*e2 && d1<d2) {
		    n[i] = 1
		    dp2 = data[2]+k
		    ep2 = errdata[2]+k
		    ip2 = id[2]+k
		    Memr[dp1] = d2
		    Memr[dp2] = d1
		    Memr[ep1] = e2
		    Memr[ep2] = e1
		    Memi[ip1] = id2
		    Memi[ip2] = id1
		    if (!DOCOMBINE) 
			average[i] = d2
		    next
		} else if (d1<-LSIGMA*e1 && d2<-LSIGMA*e2 && d1>d2) {
		    n[i] = 1
		    if (!DOCOMBINE) 
			average[i] = d1
		    next
		} else if (d1<-LSIGMA*e1 && d2>HSIGMA*e2 && abs(d1)>d2) {
		    n[i] = 1
		    dp2 = data[2]+k
		    ep2 = errdata[2]+k
		    ip2 = id[2]+k
		    Memr[dp1] = d2
		    Memr[dp2] = d1
		    Memr[ep1] = e2
		    Memr[ep2] = e1
		    Memi[ip1] = id2
		    Memi[ip2] = id1
		    if (!DOCOMBINE) 
			average[i] = d2
		    next
		} else if (d1<-LSIGMA*e1 && d2>HSIGMA*e2 && abs(d1)<d2) {
		    n[i] = 1
		    if (!DOCOMBINE) 
			average[i] = d1
		    next
		} else if (d1>HSIGMA*e1 && d2<-LSIGMA*e2 && abs(d2)<d1) {
		    n[i] = 1
		    dp2 = data[2]+k
		    ep2 = errdata[2]+k
		    ip2 = id[2]+k
		    Memr[dp1] = d2
		    Memr[dp2] = d1
		    Memr[ep1] = e2
		    Memr[ep2] = e1
		    Memi[ip1] = id2
		    Memi[ip2] = id1
		    if (!DOCOMBINE) 
			average[i] = d2
		    next
		} else if (d1>HSIGMA*e1 && d2<-LSIGMA*e2 && abs(d2)>d1) {
		    n[i] = 1
		    if (!DOCOMBINE) 
			average[i] = d1
		    next
		}
	    }

	    # Iteratively reject pixels
	    # Compact the data and keep track of the image IDs if needed.

	    repeat {
		# Average of the only two good pixels
		if (n1 == 2) {
		    sum = Memr[data[1]+k]
		    sum = sum + Memr[data[2]+k]
		    a = sum / 2
	    	} else {
	    	# Unweighted average with the high and low rejected
		    low = Memr[data[1]+k]
		    high = Memr[data[2]+k]
		    if (low > high) {
			d1 = low
			low = high
			high =d1
		    }
	        # Find low and high with masked bad pixels excluded
		    sum = zero
		    do j = 3, n1 {
		        d1 = Memr[data[j]+k]
		        if (d1 < low) {
			    sum = sum + low
			    low = d1
			} else if (d1 > high) {
			    sum = sum + high
			    high = d1
			} else
			    sum = sum + d1
	    	    }
		    a = sum / real(n1 - 2)
		    sum = sum + low + high
	    	}	
		n2 = n1
		# Reject pixels.  Save the residuals and data values.
		for (j=1; j<=n1; j=j+1) {
		    dp1 = data[j] + k
		    ep1 = errdata[j]+k
		    d1 = Memr[dp1]
		    e1 = Memr[ep1]
		    r = (d1 - a) / e1
		    if (r < -LSIGMA || r > HSIGMA) {
			Memr[resid+n1] = abs (r)
			if (j < n1) {
			    dp2 = data[n1] + k
			    Memr[dp1] = Memr[dp2]
			    Memr[dp2] = d1
			    ep2 = errdata[n1] + k
			    Memr[ep1] = Memr[ep2]
			    Memr[ep2] = e1
			    ip1 = id[j] + k
			    ip2 = id[n1] + k
			    idj = Memi[ip1]
			    Memi[ip1] = Memi[ip2]
			    Memi[ip2] = idj
			    j = j - 1
			}
			n1 = n1 - 1
		    }
		}
	    } until (n1 == n2 || n1 < lrej)

	    # If too many pixels are rejected add some back.
	    # All pixels with equal residuals are added back.
	    if (n1 < minkeep) {
		nk = minkeep
		for (j=n1+1; j<=nk; j=j+1) {
		    dp1 = data[j] + k
		    ep1 = errdata[j] + k
		    r = Memr[resid+j]
		    ii = 0
		    do l = j+1, n2 {
			s = Memr[resid+l]
			if (s < r + TOL) {
			    if (s > r - TOL)
				ii = ii + 1
			    else {
				ii = 0
				Memr[resid+l] = r
				r = s
				dp2 = data[l] + k
				d1 = Memr[dp1]
				Memr[dp1] = Memr[dp2]
				Memr[dp2] = d1
				ep2 = errdata[l] + k
				e1 = Memr[ep1]
				Memr[ep1] = Memr[ep2]
				Memr[ep2] = e1
				ip1 = id[j] + k
				ip2 = id[l] + k
				idj = Memi[ip1]
				Memi[ip1] = Memi[ip2]
				Memi[ip2] = idj
			    }
			}
		    }
		    n1 = n1 + 1
		    nk = max (nk, j+ii)
		}
	    }

	    # Save the average if needed.
	    n[i] = n1
	    if (!DOCOMBINE) {
		if (n1 == 0)
		    average[i] = BLANK
		else {
		    sum = Memr[data[1]+k]
		    do j = 2, n1
			sum = sum + Memr[data[j]+k]
		    average[i] = sum / real(n1)
		}
	    }
	}

	call sfree (sp)
end


# G_MERRCLIP -- Reject pixels using error clipping about the median
#  The weighted average sigma about median is computed based on the error
# taken from th error maps
#
# CYZhang 19 May 1994

procedure g_merrclipr (data, id, errdata, nimages, n, npts, median, szuw)

pointer	data[nimages]		# Data pointers
pointer	errdata[nimages]	# Error pointers
pointer	id[nimages]		# Image IDs
int	n[npts]			# Number of good pixels
int	nimages			# Number of images
int	npts			# Number of output points per line
real	median[npts]		# Median
pointer	szuw

int	i, j, k, l, n1, n2, n3, nl, nh, id1, id2, minkeep, lrej
pointer	sp, resid
real	d1, d2, e1, e2, med, r, s, one, zero
data	one, zero /1.0, 0.0/
pointer	dp1, dp2, ep1, ep2, ip1, ip2

include	"../gcombine.com"

begin
	# If there are insufficient pixels go on to the combining
	if (NKEEP < 0)
	    minkeep = max (0, nimages + NKEEP)
	else
	    minkeep = min (nimages, NKEEP)
	lrej = max (MINCLIP, minkeep+1)
	if (nimages < lrej) {
	    DOCOMBINE = true
	    return
	}

	# Save the residuals and sigma scaling corrections if needed.
	call smark (sp)
	call salloc (resid, nimages+1, TY_REAL)

	# Compute median and sigma and iteratively clip.

	do i = 1, npts {
	    k = i - 1
	    n1 = n[i]
	    if (NKEEP < 0)
		minkeep = max (0, n1 + NKEEP)
	    else
		minkeep = min (n1, NKEEP)
	    lrej = max (MINCLIP, minkeep+1)

	    if (n1 == 2) {
		dp1 = data[1]+k
		ep1 = errdata[1]+k
		ip1 = id[1]+k
		d1 = Memr[dp1]
		id1 = Memi[ip1]
		e1 = Memr[ep1]
		d2 = Memr[data[2]+k]
		id2 = Memi[id[2]+k]
		e2 = Memr[errdata[2]+k]
		if (!DOCOMBINE)
		    median[i] = (d1 + d2) / 2.0
		if ((d1>0. && d1<=HSIGMA*e1 || d1<0. && d1>=-LSIGMA*e1) &&
		    (d2>0. && d2<=HSIGMA*e2 || d2<0. && d2>=-LSIGMA*e2)) 
		    next
		if (d1 < d2 && d1>-LSIGMA*e1) {
		    s = sqrt (e1**2 + e2**2)
		    if (s <= zero) 
			call error (0, "Noise map incorrect")
		    r = (d2 - d1) / s
		    if (r > HSIGMA) {
			if (!DOCOMBINE)
			    median[i] = d1
			n[i] = 1
		    } 
		    next
		} else if (d1>d2&& d2>-LSIGMA*e2) {
		    s = sqrt (e1**2 + e2**2)
		    if (s <= zero) 
			call error (0, "Noise map incorrect")
		    r = (d1 - d2) / s
		    if (r > HSIGMA) {
			n[i] = 1
			dp2 = data[2]+k
			ep2 = errdata[2]+k
			ip2 = id[2]+k
			Memr[dp1] = d2
			Memr[dp2] = d1
			Memr[ep1] = e2
			Memr[ep2] = e1
			Memi[ip1] = id2
			Memi[ip2] = id1
			if (!DOCOMBINE)
			    median[i] = d2	
		    }
		    next
		} else if (d1<-LSIGMA*e1 && d2<-LSIGMA*e2 && d1<d2) {
		    n[i] = 1
		    dp2 = data[2]+k
		    ep2 = errdata[2]+k
		    ip2 = id[2]+k
		    Memr[dp1] = d2
		    Memr[dp2] = d1
		    Memr[ep1] = e2
		    Memr[ep2] = e1
		    Memi[ip1] = id2
		    Memi[ip2] = id1
		    if (!DOCOMBINE) 
			median[i] = d2
		    next
		} else if (d1<-LSIGMA*e1 && d2<-LSIGMA*e2 && d1>d2) {
		    n[i] = 1
		    if (!DOCOMBINE) 
			median[i] = d1
		    next
		} else if (d1<-LSIGMA*e1 && d2>HSIGMA*e2 && abs(d1)>d2) {
		    n[i] = 1
		    dp2 = data[2]+k
		    ep2 = errdata[2]+k
		    ip2 = id[2]+k
		    Memr[dp1] = d2
		    Memr[dp2] = d1
		    Memr[ep1] = e2
		    Memr[ep2] = e1
		    Memi[ip1] = id2
		    Memi[ip2] = id1
		    if (!DOCOMBINE) 
			median[i] = d2
		    next
		} else if (d1<-LSIGMA*e1 && d2>HSIGMA*e2 && abs(d1)<d2) {
		    n[i] = 1
		    if (!DOCOMBINE) 
			median[i] = d1
		    next
		} else if (d1>HSIGMA*e1 && d2<-LSIGMA*e2 && abs(d2)<d1) {
		    n[i] = 1
		    dp2 = data[2]+k
		    ep2 = errdata[2]+k
		    ip2 = id[2]+k
		    Memr[dp1] = d2
		    Memr[dp2] = d1
		    Memr[ep1] = e2
		    Memr[ep2] = e1
		    Memi[ip1] = id2
		    Memi[ip2] = id1
		    if (!DOCOMBINE) 
			median[i] = d2
		    next
		} else if (d1>HSIGMA*e1 && d2<-LSIGMA*e2 && abs(d2)>d1) {
		    n[i] = 1
		    if (!DOCOMBINE) 
			median[i] = d1
		    next
		}
	    }

	    nl = 1
	    nh = n1

	    repeat {
		n2 = n1
		n3 = nl + n1 / 2

		if (n1 == 0)
		    med = BLANK
		else if (mod (n1, 2) == 0)
		    med = (Memr[data[n3-1]+k] + Memr[data[n3]+k]) / 2.
		else
		    med = Memr[data[n3]+k]

		if (n1 >= lrej) {
		    # Reject pixels and save the residuals.
		    for (; nl <= n2; nl = nl + 1) {
			d1 = Memr[data[nl]+k]
			e1 = Memr[errdata[nl]+k]
                        # Must test explicitly for error == 0 (IB, 1/18/99)
			if (e1 < 0.0) {
			    call eprintf ("Warning: noise should not be negative")
			    break
			} else if (e1 == 0.0)
                            r = 0.0
                        else 
			    r = (med - d1) / e1
			if (r <= LSIGMA)
			    break
			Memr[resid+nl] = r
			n1 = n1 - 1
		    }
		    for (; nh >= nl; nh = nh - 1) {
			d1 = Memr[data[nh]+k]
			e1 = Memr[errdata[nh]+k]
                        # Must test explicitly for error == 0 (IB, 1/18/99)
			if (e1 < 0.0) {
			    call eprintf ("Warning: noise should not be negative")
			    break
			} else if (e1 == 0.0)
                            r = 0.0
                        else
			    r = (d1 -  med) / e1
			if (r <= HSIGMA)
			    break
			Memr[resid+nh] = r
			n1 = n1 - 1
		    }
		}
	    } until (n1 == n2 || n1 < lrej)

	    # If too many pixels are rejected add some back.
	    # All pixels with equal residuals are added back.
	    while (n1 < minkeep) {
		if (nl == 1)
		    nh = nh + 1
		else if (nh == n[i])
		    nl = nl - 1
		else {
		    r = Memr[resid+nl-1]
		    s = Memr[resid+nh+1]
		    if (r < s) {
			nl = nl - 1
			r = r + TOL
			if (s <= r)
			    nh = nh + 1
			if (nl > 1) {
			    if (Memr[resid+nl-1] <= r)
				nl = nl - 1
			}
		    } else {
			nh = nh + 1
			s = s + TOL
			if (r <= s)
			    nl = nl - 1
			if (nh < n2) {
			    if (Memr[resid+nh+1] <= s)
				nh = nh + 1
			}
		    }
		}
		n1 = nh - nl + 1
	    }

	    # Only set median and reorder if needed
	    n[i] = n1
	    if (n1 > 0 && nl > 1 && G_COMBINE != C_MEDIAN) {
		j = max (nl, n1 + 1)
		do l = 1, min (nl-1, n1) {
		    Memr[data[l]+k] = Memr[data[j]+k]
		    Memr[errdata[l]+k] = Memr[errdata[j]+k]
		    Memi[id[l]+k] = Memi[id[j]+k]
		    j = j + 1
		}
	    }

	    if (G_COMBINE == C_MEDIAN)
		median[i] = med
	}

	# Flag that the median has been computed.
	if (G_COMBINE == C_MEDIAN)
	    DOCOMBINE = false
	else
	    DOCOMBINE = true

	call sfree (sp)
end

# G_AERRCLIP -- Reject pixels using error about the weighted
# average. The error is taken from the error map
#
# CYZhang 19 May

procedure g_aerrclipd (data, id, errdata, nimages, n, npts, average, szuw)

pointer	data[nimages]		# Data pointers
pointer	errdata[nimages]		# Error pointers
pointer	id[nimages]		# Image id pointers
int	n[npts]			# Number of good pixels
int	nimages			# Number of images
int	npts			# Number of output points per line
double	average[npts]		# Average
pointer	szuw

int	i, j, k, l, n1, n2, nk, idj, id1, id2, minkeep, lrej, ii
double	d1, d2, e1, e2, sum, a, low, high, s, r, one, zero
data	one, zero /1.0D0, 0.0D0/
pointer	sp, resid, dp1, dp2, ep1, ep2, ip1, ip2

include	"../gcombine.com"

begin
	# If there are insufficient pixels go on to the combining
	if (NKEEP < 0)
	    minkeep = max (0, nimages + NKEEP)
	else
	    minkeep = min (nimages, NKEEP)
	lrej = max (MINCLIP, minkeep+1)
	if (nimages < lrej) {
	    docombine = true
	    return
	} 
	
	# Since the unweighted average is computed here possibly skip combining
	# When weighted average or median is required, must call combine
	if (DOWTS || G_COMBINE == C_MEDIAN)
	    DOCOMBINE = true
	else
	    DOCOMBINE = false


	# Save the residuals and the sigma scaling corrections if needed.
	call smark (sp)
	call salloc (resid, nimages+1, TY_REAL)

	# Do error clipping.
	do i = 1, npts {
	    k = i - 1
	    n1 = n[i]
	    if (NKEEP < 0)
		minkeep = max (0, n1 + NKEEP)
	    else
		minkeep = min (n1, NKEEP)
	    lrej = max (MINCLIP, minkeep)
	    # If there are not enough pixels simply compute the average.
	    if (n1 < lrej) {
		if (!DOCOMBINE) {
		    if (n1 == 0)
			average[i] = BLANK
		    else {
			sum = Memd[data[1]+k]
			do j = 2, n1
			    sum = sum + Memd[data[j]+k]
			average[i] = sum / real(n1)
		    }
		}
		next
	    }

	    if (n1 == 2) {
		dp1 = data[1]+k
		ep1 = errdata[1]+k
		ip1 = id[1]+k
		d1 = Memd[dp1]
		id1 = Memi[ip1]
		e1 = Memd[ep1]
		d2 = Memd[data[2]+k]
		id2 = Memi[id[2]+k]
		e2 = Memd[errdata[2]+k]
		if (!DOCOMBINE)
		    average[i] = (d1 + d2) / 2.0
		if ((d1>0. && d1<=HSIGMA*e1 || d1<0. && d1>=-LSIGMA*e1) &&
		    (d2>0. && d2<=HSIGMA*e2 || d2<0. && d2>=-LSIGMA*e2)) 
		    next
		if (d1 < d2 && d1>-LSIGMA*e1) {
		    s = sqrt (e1**2 + e2**2)
		    if (s <= zero) 
			call error (0, "Noise map incorrect")
		    r = (d2 - d1) / s
		    if (r > HSIGMA) {
			if (!DOCOMBINE)
			    average[i] = d1
			n[i] = 1
		    } 
		    next
		} else if (d1>d2&& d2>-LSIGMA*e2) {
		    s = sqrt (e1**2 + e2**2)
		    if (s <= zero) 
			call error (0, "Noise map incorrect")
		    r = (d1 - d2) / s
		    if (r > HSIGMA) {
			n[i] = 1
			dp2 = data[2]+k
			ep2 = errdata[2]+k
			ip2 = id[2]+k
			Memd[dp1] = d2
			Memd[dp2] = d1
			Memd[ep1] = e2
			Memd[ep2] = e1
			Memi[ip1] = id2
			Memi[ip2] = id1
			if (!DOCOMBINE)
			    average[i] = d2	
		    }
		    next
		} else if (d1<-LSIGMA*e1 && d2<-LSIGMA*e2 && d1<d2) {
		    n[i] = 1
		    dp2 = data[2]+k
		    ep2 = errdata[2]+k
		    ip2 = id[2]+k
		    Memd[dp1] = d2
		    Memd[dp2] = d1
		    Memd[ep1] = e2
		    Memd[ep2] = e1
		    Memi[ip1] = id2
		    Memi[ip2] = id1
		    if (!DOCOMBINE) 
			average[i] = d2
		    next
		} else if (d1<-LSIGMA*e1 && d2<-LSIGMA*e2 && d1>d2) {
		    n[i] = 1
		    if (!DOCOMBINE) 
			average[i] = d1
		    next
		} else if (d1<-LSIGMA*e1 && d2>HSIGMA*e2 && abs(d1)>d2) {
		    n[i] = 1
		    dp2 = data[2]+k
		    ep2 = errdata[2]+k
		    ip2 = id[2]+k
		    Memd[dp1] = d2
		    Memd[dp2] = d1
		    Memd[ep1] = e2
		    Memd[ep2] = e1
		    Memi[ip1] = id2
		    Memi[ip2] = id1
		    if (!DOCOMBINE) 
			average[i] = d2
		    next
		} else if (d1<-LSIGMA*e1 && d2>HSIGMA*e2 && abs(d1)<d2) {
		    n[i] = 1
		    if (!DOCOMBINE) 
			average[i] = d1
		    next
		} else if (d1>HSIGMA*e1 && d2<-LSIGMA*e2 && abs(d2)<d1) {
		    n[i] = 1
		    dp2 = data[2]+k
		    ep2 = errdata[2]+k
		    ip2 = id[2]+k
		    Memd[dp1] = d2
		    Memd[dp2] = d1
		    Memd[ep1] = e2
		    Memd[ep2] = e1
		    Memi[ip1] = id2
		    Memi[ip2] = id1
		    if (!DOCOMBINE) 
			average[i] = d2
		    next
		} else if (d1>HSIGMA*e1 && d2<-LSIGMA*e2 && abs(d2)>d1) {
		    n[i] = 1
		    if (!DOCOMBINE) 
			average[i] = d1
		    next
		}
	    }

	    # Iteratively reject pixels
	    # Compact the data and keep track of the image IDs if needed.

	    repeat {
		# Average of the only two good pixels
		if (n1 == 2) {
		    sum = Memd[data[1]+k]
		    sum = sum + Memd[data[2]+k]
		    a = sum / 2
	    	} else {
	    	# Unweighted average with the high and low rejected
		    low = Memd[data[1]+k]
		    high = Memd[data[2]+k]
		    if (low > high) {
			d1 = low
			low = high
			high =d1
		    }
	        # Find low and high with masked bad pixels excluded
		    sum = zero
		    do j = 3, n1 {
		        d1 = Memd[data[j]+k]
		        if (d1 < low) {
			    sum = sum + low
			    low = d1
			} else if (d1 > high) {
			    sum = sum + high
			    high = d1
			} else
			    sum = sum + d1
	    	    }
		    a = sum / real(n1 - 2)
		    sum = sum + low + high
	    	}	
		n2 = n1
		# Reject pixels.  Save the residuals and data values.
		for (j=1; j<=n1; j=j+1) {
		    dp1 = data[j] + k
		    ep1 = errdata[j]+k
		    d1 = Memd[dp1]
		    e1 = Memd[ep1]
		    r = (d1 - a) / e1
		    if (r < -LSIGMA || r > HSIGMA) {
			Memr[resid+n1] = abs (r)
			if (j < n1) {
			    dp2 = data[n1] + k
			    Memd[dp1] = Memd[dp2]
			    Memd[dp2] = d1
			    ep2 = errdata[n1] + k
			    Memd[ep1] = Memd[ep2]
			    Memd[ep2] = e1
			    ip1 = id[j] + k
			    ip2 = id[n1] + k
			    idj = Memi[ip1]
			    Memi[ip1] = Memi[ip2]
			    Memi[ip2] = idj
			    j = j - 1
			}
			n1 = n1 - 1
		    }
		}
	    } until (n1 == n2 || n1 < lrej)

	    # If too many pixels are rejected add some back.
	    # All pixels with equal residuals are added back.
	    if (n1 < minkeep) {
		nk = minkeep
		for (j=n1+1; j<=nk; j=j+1) {
		    dp1 = data[j] + k
		    ep1 = errdata[j] + k
		    r = Memr[resid+j]
		    ii = 0
		    do l = j+1, n2 {
			s = Memr[resid+l]
			if (s < r + TOL) {
			    if (s > r - TOL)
				ii = ii + 1
			    else {
				ii = 0
				Memr[resid+l] = r
				r = s
				dp2 = data[l] + k
				d1 = Memd[dp1]
				Memd[dp1] = Memd[dp2]
				Memd[dp2] = d1
				ep2 = errdata[l] + k
				e1 = Memd[ep1]
				Memd[ep1] = Memd[ep2]
				Memd[ep2] = e1
				ip1 = id[j] + k
				ip2 = id[l] + k
				idj = Memi[ip1]
				Memi[ip1] = Memi[ip2]
				Memi[ip2] = idj
			    }
			}
		    }
		    n1 = n1 + 1
		    nk = max (nk, j+ii)
		}
	    }

	    # Save the average if needed.
	    n[i] = n1
	    if (!DOCOMBINE) {
		if (n1 == 0)
		    average[i] = BLANK
		else {
		    sum = Memd[data[1]+k]
		    do j = 2, n1
			sum = sum + Memd[data[j]+k]
		    average[i] = sum / real(n1)
		}
	    }
	}

	call sfree (sp)
end


# G_MERRCLIP -- Reject pixels using error clipping about the median
#  The weighted average sigma about median is computed based on the error
# taken from th error maps
#
# CYZhang 19 May 1994

procedure g_merrclipd (data, id, errdata, nimages, n, npts, median, szuw)

pointer	data[nimages]		# Data pointers
pointer	errdata[nimages]	# Error pointers
pointer	id[nimages]		# Image IDs
int	n[npts]			# Number of good pixels
int	nimages			# Number of images
int	npts			# Number of output points per line
double	median[npts]		# Median
pointer	szuw

int	i, j, k, l, n1, n2, n3, nl, nh, id1, id2, minkeep, lrej
pointer	sp, resid
double	d1, d2, e1, e2, med, r, s, one, zero
data	one, zero /1.0D0, 0.0D0/
pointer	dp1, dp2, ep1, ep2, ip1, ip2

include	"../gcombine.com"

begin
	# If there are insufficient pixels go on to the combining
	if (NKEEP < 0)
	    minkeep = max (0, nimages + NKEEP)
	else
	    minkeep = min (nimages, NKEEP)
	lrej = max (MINCLIP, minkeep+1)
	if (nimages < lrej) {
	    DOCOMBINE = true
	    return
	}

	# Save the residuals and sigma scaling corrections if needed.
	call smark (sp)
	call salloc (resid, nimages+1, TY_REAL)

	# Compute median and sigma and iteratively clip.

	do i = 1, npts {
	    k = i - 1
	    n1 = n[i]
	    if (NKEEP < 0)
		minkeep = max (0, n1 + NKEEP)
	    else
		minkeep = min (n1, NKEEP)
	    lrej = max (MINCLIP, minkeep+1)

	    if (n1 == 2) {
		dp1 = data[1]+k
		ep1 = errdata[1]+k
		ip1 = id[1]+k
		d1 = Memd[dp1]
		id1 = Memi[ip1]
		e1 = Memd[ep1]
		d2 = Memd[data[2]+k]
		id2 = Memi[id[2]+k]
		e2 = Memd[errdata[2]+k]
		if (!DOCOMBINE)
		    median[i] = (d1 + d2) / 2.0
		if ((d1>0. && d1<=HSIGMA*e1 || d1<0. && d1>=-LSIGMA*e1) &&
		    (d2>0. && d2<=HSIGMA*e2 || d2<0. && d2>=-LSIGMA*e2)) 
		    next
		if (d1 < d2 && d1>-LSIGMA*e1) {
		    s = sqrt (e1**2 + e2**2)
		    if (s <= zero) 
			call error (0, "Noise map incorrect")
		    r = (d2 - d1) / s
		    if (r > HSIGMA) {
			if (!DOCOMBINE)
			    median[i] = d1
			n[i] = 1
		    } 
		    next
		} else if (d1>d2&& d2>-LSIGMA*e2) {
		    s = sqrt (e1**2 + e2**2)
		    if (s <= zero) 
			call error (0, "Noise map incorrect")
		    r = (d1 - d2) / s
		    if (r > HSIGMA) {
			n[i] = 1
			dp2 = data[2]+k
			ep2 = errdata[2]+k
			ip2 = id[2]+k
			Memd[dp1] = d2
			Memd[dp2] = d1
			Memd[ep1] = e2
			Memd[ep2] = e1
			Memi[ip1] = id2
			Memi[ip2] = id1
			if (!DOCOMBINE)
			    median[i] = d2	
		    }
		    next
		} else if (d1<-LSIGMA*e1 && d2<-LSIGMA*e2 && d1<d2) {
		    n[i] = 1
		    dp2 = data[2]+k
		    ep2 = errdata[2]+k
		    ip2 = id[2]+k
		    Memd[dp1] = d2
		    Memd[dp2] = d1
		    Memd[ep1] = e2
		    Memd[ep2] = e1
		    Memi[ip1] = id2
		    Memi[ip2] = id1
		    if (!DOCOMBINE) 
			median[i] = d2
		    next
		} else if (d1<-LSIGMA*e1 && d2<-LSIGMA*e2 && d1>d2) {
		    n[i] = 1
		    if (!DOCOMBINE) 
			median[i] = d1
		    next
		} else if (d1<-LSIGMA*e1 && d2>HSIGMA*e2 && abs(d1)>d2) {
		    n[i] = 1
		    dp2 = data[2]+k
		    ep2 = errdata[2]+k
		    ip2 = id[2]+k
		    Memd[dp1] = d2
		    Memd[dp2] = d1
		    Memd[ep1] = e2
		    Memd[ep2] = e1
		    Memi[ip1] = id2
		    Memi[ip2] = id1
		    if (!DOCOMBINE) 
			median[i] = d2
		    next
		} else if (d1<-LSIGMA*e1 && d2>HSIGMA*e2 && abs(d1)<d2) {
		    n[i] = 1
		    if (!DOCOMBINE) 
			median[i] = d1
		    next
		} else if (d1>HSIGMA*e1 && d2<-LSIGMA*e2 && abs(d2)<d1) {
		    n[i] = 1
		    dp2 = data[2]+k
		    ep2 = errdata[2]+k
		    ip2 = id[2]+k
		    Memd[dp1] = d2
		    Memd[dp2] = d1
		    Memd[ep1] = e2
		    Memd[ep2] = e1
		    Memi[ip1] = id2
		    Memi[ip2] = id1
		    if (!DOCOMBINE) 
			median[i] = d2
		    next
		} else if (d1>HSIGMA*e1 && d2<-LSIGMA*e2 && abs(d2)>d1) {
		    n[i] = 1
		    if (!DOCOMBINE) 
			median[i] = d1
		    next
		}
	    }

	    nl = 1
	    nh = n1

	    repeat {
		n2 = n1
		n3 = nl + n1 / 2

		if (n1 == 0)
		    med = BLANK
		else if (mod (n1, 2) == 0)
		    med = (Memd[data[n3-1]+k] + Memd[data[n3]+k]) / 2.
		else
		    med = Memd[data[n3]+k]

		if (n1 >= lrej) {
		    # Reject pixels and save the residuals.
		    for (; nl <= n2; nl = nl + 1) {
			d1 = Memd[data[nl]+k]
			e1 = Memd[errdata[nl]+k]
                        # Must test explicitly for error == 0 (IB, 1/18/99)
			if (e1 < 0.0) {
			    call eprintf ("Warning: noise should not be negative")
			    break
			} else if (e1 == 0.0)
                            r = 0.0
                        else 
			    r = (med - d1) / e1
			if (r <= LSIGMA)
			    break
			Memr[resid+nl] = r
			n1 = n1 - 1
		    }
		    for (; nh >= nl; nh = nh - 1) {
			d1 = Memd[data[nh]+k]
			e1 = Memd[errdata[nh]+k]
                        # Must test explicitly for error == 0 (IB, 1/18/99)
			if (e1 < 0.0) {
			    call eprintf ("Warning: noise should not be negative")
			    break
			} else if (e1 == 0.0)
                            r = 0.0
                        else
			    r = (d1 -  med) / e1
			if (r <= HSIGMA)
			    break
			Memr[resid+nh] = r
			n1 = n1 - 1
		    }
		}
	    } until (n1 == n2 || n1 < lrej)

	    # If too many pixels are rejected add some back.
	    # All pixels with equal residuals are added back.
	    while (n1 < minkeep) {
		if (nl == 1)
		    nh = nh + 1
		else if (nh == n[i])
		    nl = nl - 1
		else {
		    r = Memr[resid+nl-1]
		    s = Memr[resid+nh+1]
		    if (r < s) {
			nl = nl - 1
			r = r + TOL
			if (s <= r)
			    nh = nh + 1
			if (nl > 1) {
			    if (Memr[resid+nl-1] <= r)
				nl = nl - 1
			}
		    } else {
			nh = nh + 1
			s = s + TOL
			if (r <= s)
			    nl = nl - 1
			if (nh < n2) {
			    if (Memr[resid+nh+1] <= s)
				nh = nh + 1
			}
		    }
		}
		n1 = nh - nl + 1
	    }

	    # Only set median and reorder if needed
	    n[i] = n1
	    if (n1 > 0 && nl > 1 && G_COMBINE != C_MEDIAN) {
		j = max (nl, n1 + 1)
		do l = 1, min (nl-1, n1) {
		    Memd[data[l]+k] = Memd[data[j]+k]
		    Memd[errdata[l]+k] = Memd[errdata[j]+k]
		    Memi[id[l]+k] = Memi[id[j]+k]
		    j = j + 1
		}
	    }

	    if (G_COMBINE == C_MEDIAN)
		median[i] = med
	}

	# Flag that the median has been computed.
	if (G_COMBINE == C_MEDIAN)
	    DOCOMBINE = false
	else
	    DOCOMBINE = true

	call sfree (sp)
end

