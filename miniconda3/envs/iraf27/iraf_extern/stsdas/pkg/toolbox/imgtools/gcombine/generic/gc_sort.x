define	LOGPTR	32			# log2(maxpts) (4e9)


# GC_SORT -- Quicksort.  This is based on the VOPS asrt except that
# the input is an array of pointers to image lines and the sort is done
# across the image lines at each point along the lines.  The number of
# valid pixels at each point is allowed to vary.  The cases of 1, 2, and 3
# pixels per point are treated specially.
#
# See ic_sort in images.imcombine


# Fixed error in gc_2sort: two statements were missing from the code,
# apparently erased by accident when copying/pasting. The error appears
# to be in place at least since Mar 7, 1997.
#
# I. Busko, 28 Sep 98


procedure gc_sorts (a, b, nvecs, npts)

pointer	a[ARB]			# pointer to input vectors
short	b[ARB]			# work array
int	nvecs[npts]		# number of vectors
int	npts			# number of points in vectors

short	pivot, temp, temp3
int	i, j, k, l, p, npix, lv[LOGPTR], uv[LOGPTR]
define	swap {temp=$1;$1=$2;$2=temp}
define	copy_	10

begin
	do l = 0, npts-1 {
	    npix = nvecs[l+1]
	    if (npix <= 1)
		next

	    do i = 1, npix
		b[i] = Mems[a[i]+l]

	    # Special cases
	    if (npix <= 3) {
		pivot = b[1]
		temp = b[2]
		if (npix == 2) {
		    if (temp < pivot) {
			b[1] = temp
			b[2] = pivot
		    } else
			next
		} else {
		    temp3 = b[3]
		    if (temp < pivot) {				# bac|bca|cba
			if (temp < temp3) {			# bac|bca
			    b[1] = temp
			    if (pivot < temp3)			# bac
				b[2] = pivot
			    else {				# bca
				b[2] = temp3
				b[3] = pivot
			    }
			} else {				# cba
			    b[1] = temp3
			    b[3] = pivot
			}
		    } else if (temp3 < temp) {			# acb|cab
			b[3] = temp
			if (pivot < temp3)			# acb
			    b[2] = temp3
			else {					# cab
			    b[1] = temp3
			    b[2] = pivot
			}
		    } else
			next
		}
		goto copy_
	    }

	    # General case
	    do i = 1, npix
		b[i] = Mems[a[i]+l]

	    lv[1] = 1
	    uv[1] = npix
	    p = 1

	    while (p > 0) {
		if (lv[p] >= uv[p])		# only one elem in this subset
		    p = p - 1			# pop stack
		else {
		    # Dummy do loop to trigger the Fortran optimizer.
		    do p = p, ARB {
			i = lv[p] - 1
			j = uv[p]

			# Select as the pivot the element at the center of the
			# array, to avoid quadratic behavior on an already
			# sorted array.

			k = (lv[p] + uv[p]) / 2
			swap (b[j], b[k])
			pivot = b[j]		   # pivot line

			while (i < j) {
			    for (i=i+1;  b[i] < pivot;  i=i+1)
				;
			    for (j=j-1;  j > i;  j=j-1)
				if (b[j] <= pivot)
				    break
			    if (i < j)		   # out of order pair
				swap (b[i], b[j])  # interchange elements
			}

			j = uv[p]		   # move pivot to position i
			swap (b[i], b[j])	   # interchange elements

			if (i-lv[p] < uv[p] - i) { # stack so shorter done first
			    lv[p+1] = lv[p]
			    uv[p+1] = i - 1
			    lv[p] = i + 1
			} else {
			    lv[p+1] = i + 1
			    uv[p+1] = uv[p]
			    uv[p] = i - 1
			}

			break
		    }
		    p = p + 1			   # push onto stack
		}
	    }

copy_
	    do i = 1, npix
		Mems[a[i]+l] = b[i]
	}
end


# GC_2SORT -- Quicksort.  This is based on the VOPS asrt except that
# the input is an array of pointers to image lines and the sort is done
# across the image lines at each point along the lines.  The number of
# valid pixels at each point is allowed to vary.  The cases of 1, 2, and 3
# pixels per point are treated specially.  A second integer set of
# vectors is sorted.
#
# See images.imcombine

procedure gc_2sorts (a, b, c, d, nvecs, npts)

pointer	a[ARB]			# pointer to input vectors
short	b[ARB]			# work array
pointer	c[ARB]			# pointer to associated integer vectors
int	d[ARB]			# work array
int	nvecs[npts]		# number of vectors
int	npts			# number of points in vectors

short	pivot, temp, temp3
int	i, j, k, l, p, npix, lv[LOGPTR], uv[LOGPTR], itemp
define	swap {temp=$1;$1=$2;$2=temp}
define	iswap {itemp=$1;$1=$2;$2=itemp}
define	copy_	10

begin
	do l = 0, npts-1 {
	    npix = nvecs[l+1]
	    if (npix <= 1)
		next

	    do i = 1, npix {
		b[i] = Mems[a[i]+l]
		d[i] = Memi[c[i]+l]
	    }

	    # Special cases
	    if (npix <= 3) {
		pivot = b[1]
		temp = b[2]
		if (npix == 2) {
		    if (temp < pivot) {
			b[1] = temp
			b[2] = pivot
			iswap (d[1], d[2])
		    } else
			next
		} else {
		    temp3 = b[3]
		    if (temp < pivot) {				# bac|bca|cba
			if (temp < temp3) {			# bac|bca
			    b[1] = temp
			    if (pivot < temp3) {		# bac
				b[2] = pivot
				iswap (d[1], d[2])
			    } else {				# bca
				b[2] = temp3
				b[3] = pivot
				itemp = d[2]
				d[2] = d[3]
	                        # The following two statements were
                                # missing in the gcombine code. They
                                # exist in the original imcombine code,
                                # thus apparently someone screwed it up
                                # when copying / pasting (IB, 9/28/98)
				d[3] = d[1]
				d[1] = itemp
			    }
			} else {				# cba
			    b[1] = temp3
			    b[3] = pivot
			    iswap (d[1], d[3])
			}
		    } else if (temp3 < temp) {			# acb|cab
			b[3] = temp
			if (pivot < temp3) {			# acb
			    b[2] = temp3
			    iswap (d[2], d[3])
			} else {				# cab
			    b[1] = temp3
			    b[2] = pivot
			    itemp = d[2]
			    d[2] = d[1]
			    d[1] = d[3]
			    d[3] = itemp
			}
		    } else
			next
		}
		goto copy_
	    }

	    # General case
	    lv[1] = 1
	    uv[1] = npix
	    p = 1

	    while (p > 0) {
		if (lv[p] >= uv[p])		# only one elem in this subset
		    p = p - 1			# pop stack
		else {
		    # Dummy do loop to trigger the Fortran optimizer.
		    do p = p, ARB {
			i = lv[p] - 1
			j = uv[p]

			# Select as the pivot the element at the center of the
			# array, to avoid quadratic behavior on an already
			# sorted array.

			k = (lv[p] + uv[p]) / 2
			swap (b[j], b[k]); swap (d[j], d[k])
			pivot = b[j]		   # pivot line

			while (i < j) {
			    for (i=i+1;  b[i] < pivot;  i=i+1)
				;
			    for (j=j-1;  j > i;  j=j-1)
				if (b[j] <= pivot)
				    break
			    if (i < j) {	   # out of order pair
				swap (b[i], b[j])  # interchange elements
				swap (d[i], d[j])
			    }
			}

			j = uv[p]		   # move pivot to position i
			swap (b[i], b[j])	   # interchange elements
			swap (d[i], d[j])

			if (i-lv[p] < uv[p] - i) { # stack so shorter done first
			    lv[p+1] = lv[p]
			    uv[p+1] = i - 1
			    lv[p] = i + 1
			} else {
			    lv[p+1] = i + 1
			    uv[p+1] = uv[p]
			    uv[p] = i - 1
			}

			break
		    }
		    p = p + 1			   # push onto stack
		}
	    }

copy_	   
	    do i = 1, npix {
		Mems[a[i]+l] = b[i]
		Memi[c[i]+l] = d[i]
	    }
	}
end






# GC_3SORT -- Quicksort.  This is based on the VOPS asrt except that
# the input is an array of pointers to image lines and the sort is done
# across the image lines at each point along the lines.  The number of
# valid pixels at each point is allowed to vary.  The cases of 1, 2, and 3
# pixels per point are treated specially.  A second integer set of
# vectors and a third real set of vectors are sorted.
#
# 
# This routine adds an extra real vector to the ones sorted by
# gc_2sort. When sorting of errors is neccessary in gc_gedtata, it
# was performed in a separate call to gc_sort, which sorts a single
# vector. This caused the error values to get scrambled in relation to
# their associated data values. The error vectors can't be actually
# sorted, they must simply be carried along when their associated 
# data values are sorted.
#
# I. Busko, 28 Sep 98

procedure gc_3sorts (a, b, ae, be, c, d, nvecs, npts)

pointer	a[ARB]			# pointer to input vectors
short	b[ARB]			# work array
pointer	ae[ARB]			# pointer to associated input error vectors
short	be[ARB]			# work array
pointer	c[ARB]			# pointer to associated integer vectors
int	d[ARB]			# work array
int	nvecs[npts]		# number of vectors
int	npts			# number of points in vectors

short	pivot, temp, temp3, temp2
int	i, j, k, l, p, npix, lv[LOGPTR], uv[LOGPTR], itemp
define	swap {temp=$1;$1=$2;$2=temp}
define	iswap {itemp=$1;$1=$2;$2=itemp}
define	copy_	10

begin
	do l = 0, npts-1 {
	    npix = nvecs[l+1]
	    if (npix <= 1)
		next

	    do i = 1, npix {
		b[i]  = Mems[a[i]+l]
		be[i] = Mems[ae[i]+l]
		d[i]  = Memi[c[i]+l]
	    }

	    # Special cases
	    if (npix <= 3) {
		pivot = b[1]
		temp = b[2]
		if (npix == 2) {
		    if (temp < pivot) {
			b[1] = temp
			b[2] = pivot
			swap  (be[1], be[2])
			iswap (d[1],  d[2])
		    } else
			next
		} else {
		    temp3 = b[3]
		    if (temp < pivot) {				# bac|bca|cba
			if (temp < temp3) {			# bac|bca
			    b[1] = temp
			    if (pivot < temp3) {		# bac
				b[2] = pivot
				swap  (be[1], be[2])
				iswap (d[1],  d[2])
			    } else {				# bca
				b[2]  = temp3
				b[3]  = pivot
				temp2 = be[2]
				be[2] = be[3]
				be[3] = be[1]
				be[1] = temp2
				itemp = d[2]
				d[2]  = d[3]
				d[3] = d[1]
				d[1] = itemp
			    }
			} else {				# cba
			    b[1] = temp3
			    b[3] = pivot
			    swap  (be[1], be[3])
			    iswap (d[1],  d[3])
			}
		    } else if (temp3 < temp) {			# acb|cab
			b[3] = temp
			if (pivot < temp3) {			# acb
			    b[2] = temp3
			    swap  (be[2], be[3])
			    iswap (d[2],  d[3])
			} else {				# cab
			    b[1]  = temp3
			    b[2]  = pivot
			    temp2 = be[2]
			    be[2] = be[1]
			    be[1] = be[3]
			    be[3] = temp2
			    itemp = d[2]
			    d[2]  = d[1]
			    d[1]  = d[3]
			    d[3]  = itemp
			}
		    } else
			next
		}
		goto copy_
	    }

	    # General case
	    lv[1] = 1
	    uv[1] = npix
	    p = 1

	    while (p > 0) {
		if (lv[p] >= uv[p])		# only one elem in this subset
		    p = p - 1			# pop stack
		else {
		    # Dummy do loop to trigger the Fortran optimizer.
		    do p = p, ARB {
			i = lv[p] - 1
			j = uv[p]

			# Select as the pivot the element at the center of the
			# array, to avoid quadratic behavior on an already
			# sorted array.

			k = (lv[p] + uv[p]) / 2
			swap (b[j], b[k]); swap (d[j], d[k]); swap (be[j], be[k])
			pivot = b[j]		   # pivot line

			while (i < j) {
			    for (i=i+1;  b[i] < pivot;  i=i+1)
				;
			    for (j=j-1;  j > i;  j=j-1)
				if (b[j] <= pivot)
				    break
			    if (i < j) { 	    # out of order pair
				swap (b[i],  b[j])  # interchange elements
				swap (be[i], be[j])
				swap (d[i],  d[j])
			    }
			}

			j = uv[p]		   # move pivot to position i
			swap (b[i],  b[j])	   # interchange elements
			swap (d[i],  d[j])
			swap (be[i], be[j])

			if (i-lv[p] < uv[p] - i) { # stack so shorter done first
			    lv[p+1] = lv[p]
			    uv[p+1] = i - 1
			    lv[p] = i + 1
			} else {
			    lv[p+1] = i + 1
			    uv[p+1] = uv[p]
			    uv[p] = i - 1
			}

			break
		    }
		    p = p + 1			   # push onto stack
		}
	    }

copy_	   
	    do i = 1, npix {
		Mems[a[i]+l]  = b[i]
		Mems[ae[i]+l] = be[i]
		Memi[c[i]+l]   = d[i]
	    }
	}
end

# GC_SORT -- Quicksort.  This is based on the VOPS asrt except that
# the input is an array of pointers to image lines and the sort is done
# across the image lines at each point along the lines.  The number of
# valid pixels at each point is allowed to vary.  The cases of 1, 2, and 3
# pixels per point are treated specially.
#
# See ic_sort in images.imcombine


# Fixed error in gc_2sort: two statements were missing from the code,
# apparently erased by accident when copying/pasting. The error appears
# to be in place at least since Mar 7, 1997.
#
# I. Busko, 28 Sep 98


procedure gc_sorti (a, b, nvecs, npts)

pointer	a[ARB]			# pointer to input vectors
int	b[ARB]			# work array
int	nvecs[npts]		# number of vectors
int	npts			# number of points in vectors

int	pivot, temp, temp3
int	i, j, k, l, p, npix, lv[LOGPTR], uv[LOGPTR]
define	swap {temp=$1;$1=$2;$2=temp}
define	copy_	10

begin
	do l = 0, npts-1 {
	    npix = nvecs[l+1]
	    if (npix <= 1)
		next

	    do i = 1, npix
		b[i] = Memi[a[i]+l]

	    # Special cases
	    if (npix <= 3) {
		pivot = b[1]
		temp = b[2]
		if (npix == 2) {
		    if (temp < pivot) {
			b[1] = temp
			b[2] = pivot
		    } else
			next
		} else {
		    temp3 = b[3]
		    if (temp < pivot) {				# bac|bca|cba
			if (temp < temp3) {			# bac|bca
			    b[1] = temp
			    if (pivot < temp3)			# bac
				b[2] = pivot
			    else {				# bca
				b[2] = temp3
				b[3] = pivot
			    }
			} else {				# cba
			    b[1] = temp3
			    b[3] = pivot
			}
		    } else if (temp3 < temp) {			# acb|cab
			b[3] = temp
			if (pivot < temp3)			# acb
			    b[2] = temp3
			else {					# cab
			    b[1] = temp3
			    b[2] = pivot
			}
		    } else
			next
		}
		goto copy_
	    }

	    # General case
	    do i = 1, npix
		b[i] = Memi[a[i]+l]

	    lv[1] = 1
	    uv[1] = npix
	    p = 1

	    while (p > 0) {
		if (lv[p] >= uv[p])		# only one elem in this subset
		    p = p - 1			# pop stack
		else {
		    # Dummy do loop to trigger the Fortran optimizer.
		    do p = p, ARB {
			i = lv[p] - 1
			j = uv[p]

			# Select as the pivot the element at the center of the
			# array, to avoid quadratic behavior on an already
			# sorted array.

			k = (lv[p] + uv[p]) / 2
			swap (b[j], b[k])
			pivot = b[j]		   # pivot line

			while (i < j) {
			    for (i=i+1;  b[i] < pivot;  i=i+1)
				;
			    for (j=j-1;  j > i;  j=j-1)
				if (b[j] <= pivot)
				    break
			    if (i < j)		   # out of order pair
				swap (b[i], b[j])  # interchange elements
			}

			j = uv[p]		   # move pivot to position i
			swap (b[i], b[j])	   # interchange elements

			if (i-lv[p] < uv[p] - i) { # stack so shorter done first
			    lv[p+1] = lv[p]
			    uv[p+1] = i - 1
			    lv[p] = i + 1
			} else {
			    lv[p+1] = i + 1
			    uv[p+1] = uv[p]
			    uv[p] = i - 1
			}

			break
		    }
		    p = p + 1			   # push onto stack
		}
	    }

copy_
	    do i = 1, npix
		Memi[a[i]+l] = b[i]
	}
end


# GC_2SORT -- Quicksort.  This is based on the VOPS asrt except that
# the input is an array of pointers to image lines and the sort is done
# across the image lines at each point along the lines.  The number of
# valid pixels at each point is allowed to vary.  The cases of 1, 2, and 3
# pixels per point are treated specially.  A second integer set of
# vectors is sorted.
#
# See images.imcombine

procedure gc_2sorti (a, b, c, d, nvecs, npts)

pointer	a[ARB]			# pointer to input vectors
int	b[ARB]			# work array
pointer	c[ARB]			# pointer to associated integer vectors
int	d[ARB]			# work array
int	nvecs[npts]		# number of vectors
int	npts			# number of points in vectors

int	pivot, temp, temp3
int	i, j, k, l, p, npix, lv[LOGPTR], uv[LOGPTR], itemp
define	swap {temp=$1;$1=$2;$2=temp}
define	iswap {itemp=$1;$1=$2;$2=itemp}
define	copy_	10

begin
	do l = 0, npts-1 {
	    npix = nvecs[l+1]
	    if (npix <= 1)
		next

	    do i = 1, npix {
		b[i] = Memi[a[i]+l]
		d[i] = Memi[c[i]+l]
	    }

	    # Special cases
	    if (npix <= 3) {
		pivot = b[1]
		temp = b[2]
		if (npix == 2) {
		    if (temp < pivot) {
			b[1] = temp
			b[2] = pivot
			iswap (d[1], d[2])
		    } else
			next
		} else {
		    temp3 = b[3]
		    if (temp < pivot) {				# bac|bca|cba
			if (temp < temp3) {			# bac|bca
			    b[1] = temp
			    if (pivot < temp3) {		# bac
				b[2] = pivot
				iswap (d[1], d[2])
			    } else {				# bca
				b[2] = temp3
				b[3] = pivot
				itemp = d[2]
				d[2] = d[3]
	                        # The following two statements were
                                # missing in the gcombine code. They
                                # exist in the original imcombine code,
                                # thus apparently someone screwed it up
                                # when copying / pasting (IB, 9/28/98)
				d[3] = d[1]
				d[1] = itemp
			    }
			} else {				# cba
			    b[1] = temp3
			    b[3] = pivot
			    iswap (d[1], d[3])
			}
		    } else if (temp3 < temp) {			# acb|cab
			b[3] = temp
			if (pivot < temp3) {			# acb
			    b[2] = temp3
			    iswap (d[2], d[3])
			} else {				# cab
			    b[1] = temp3
			    b[2] = pivot
			    itemp = d[2]
			    d[2] = d[1]
			    d[1] = d[3]
			    d[3] = itemp
			}
		    } else
			next
		}
		goto copy_
	    }

	    # General case
	    lv[1] = 1
	    uv[1] = npix
	    p = 1

	    while (p > 0) {
		if (lv[p] >= uv[p])		# only one elem in this subset
		    p = p - 1			# pop stack
		else {
		    # Dummy do loop to trigger the Fortran optimizer.
		    do p = p, ARB {
			i = lv[p] - 1
			j = uv[p]

			# Select as the pivot the element at the center of the
			# array, to avoid quadratic behavior on an already
			# sorted array.

			k = (lv[p] + uv[p]) / 2
			swap (b[j], b[k]); swap (d[j], d[k])
			pivot = b[j]		   # pivot line

			while (i < j) {
			    for (i=i+1;  b[i] < pivot;  i=i+1)
				;
			    for (j=j-1;  j > i;  j=j-1)
				if (b[j] <= pivot)
				    break
			    if (i < j) {	   # out of order pair
				swap (b[i], b[j])  # interchange elements
				swap (d[i], d[j])
			    }
			}

			j = uv[p]		   # move pivot to position i
			swap (b[i], b[j])	   # interchange elements
			swap (d[i], d[j])

			if (i-lv[p] < uv[p] - i) { # stack so shorter done first
			    lv[p+1] = lv[p]
			    uv[p+1] = i - 1
			    lv[p] = i + 1
			} else {
			    lv[p+1] = i + 1
			    uv[p+1] = uv[p]
			    uv[p] = i - 1
			}

			break
		    }
		    p = p + 1			   # push onto stack
		}
	    }

copy_	   
	    do i = 1, npix {
		Memi[a[i]+l] = b[i]
		Memi[c[i]+l] = d[i]
	    }
	}
end






# GC_3SORT -- Quicksort.  This is based on the VOPS asrt except that
# the input is an array of pointers to image lines and the sort is done
# across the image lines at each point along the lines.  The number of
# valid pixels at each point is allowed to vary.  The cases of 1, 2, and 3
# pixels per point are treated specially.  A second integer set of
# vectors and a third real set of vectors are sorted.
#
# 
# This routine adds an extra real vector to the ones sorted by
# gc_2sort. When sorting of errors is neccessary in gc_gedtata, it
# was performed in a separate call to gc_sort, which sorts a single
# vector. This caused the error values to get scrambled in relation to
# their associated data values. The error vectors can't be actually
# sorted, they must simply be carried along when their associated 
# data values are sorted.
#
# I. Busko, 28 Sep 98

procedure gc_3sorti (a, b, ae, be, c, d, nvecs, npts)

pointer	a[ARB]			# pointer to input vectors
int	b[ARB]			# work array
pointer	ae[ARB]			# pointer to associated input error vectors
int	be[ARB]			# work array
pointer	c[ARB]			# pointer to associated integer vectors
int	d[ARB]			# work array
int	nvecs[npts]		# number of vectors
int	npts			# number of points in vectors

int	pivot, temp, temp3, temp2
int	i, j, k, l, p, npix, lv[LOGPTR], uv[LOGPTR], itemp
define	swap {temp=$1;$1=$2;$2=temp}
define	iswap {itemp=$1;$1=$2;$2=itemp}
define	copy_	10

begin
	do l = 0, npts-1 {
	    npix = nvecs[l+1]
	    if (npix <= 1)
		next

	    do i = 1, npix {
		b[i]  = Memi[a[i]+l]
		be[i] = Memi[ae[i]+l]
		d[i]  = Memi[c[i]+l]
	    }

	    # Special cases
	    if (npix <= 3) {
		pivot = b[1]
		temp = b[2]
		if (npix == 2) {
		    if (temp < pivot) {
			b[1] = temp
			b[2] = pivot
			swap  (be[1], be[2])
			iswap (d[1],  d[2])
		    } else
			next
		} else {
		    temp3 = b[3]
		    if (temp < pivot) {				# bac|bca|cba
			if (temp < temp3) {			# bac|bca
			    b[1] = temp
			    if (pivot < temp3) {		# bac
				b[2] = pivot
				swap  (be[1], be[2])
				iswap (d[1],  d[2])
			    } else {				# bca
				b[2]  = temp3
				b[3]  = pivot
				temp2 = be[2]
				be[2] = be[3]
				be[3] = be[1]
				be[1] = temp2
				itemp = d[2]
				d[2]  = d[3]
				d[3] = d[1]
				d[1] = itemp
			    }
			} else {				# cba
			    b[1] = temp3
			    b[3] = pivot
			    swap  (be[1], be[3])
			    iswap (d[1],  d[3])
			}
		    } else if (temp3 < temp) {			# acb|cab
			b[3] = temp
			if (pivot < temp3) {			# acb
			    b[2] = temp3
			    swap  (be[2], be[3])
			    iswap (d[2],  d[3])
			} else {				# cab
			    b[1]  = temp3
			    b[2]  = pivot
			    temp2 = be[2]
			    be[2] = be[1]
			    be[1] = be[3]
			    be[3] = temp2
			    itemp = d[2]
			    d[2]  = d[1]
			    d[1]  = d[3]
			    d[3]  = itemp
			}
		    } else
			next
		}
		goto copy_
	    }

	    # General case
	    lv[1] = 1
	    uv[1] = npix
	    p = 1

	    while (p > 0) {
		if (lv[p] >= uv[p])		# only one elem in this subset
		    p = p - 1			# pop stack
		else {
		    # Dummy do loop to trigger the Fortran optimizer.
		    do p = p, ARB {
			i = lv[p] - 1
			j = uv[p]

			# Select as the pivot the element at the center of the
			# array, to avoid quadratic behavior on an already
			# sorted array.

			k = (lv[p] + uv[p]) / 2
			swap (b[j], b[k]); swap (d[j], d[k]); swap (be[j], be[k])
			pivot = b[j]		   # pivot line

			while (i < j) {
			    for (i=i+1;  b[i] < pivot;  i=i+1)
				;
			    for (j=j-1;  j > i;  j=j-1)
				if (b[j] <= pivot)
				    break
			    if (i < j) { 	    # out of order pair
				swap (b[i],  b[j])  # interchange elements
				swap (be[i], be[j])
				swap (d[i],  d[j])
			    }
			}

			j = uv[p]		   # move pivot to position i
			swap (b[i],  b[j])	   # interchange elements
			swap (d[i],  d[j])
			swap (be[i], be[j])

			if (i-lv[p] < uv[p] - i) { # stack so shorter done first
			    lv[p+1] = lv[p]
			    uv[p+1] = i - 1
			    lv[p] = i + 1
			} else {
			    lv[p+1] = i + 1
			    uv[p+1] = uv[p]
			    uv[p] = i - 1
			}

			break
		    }
		    p = p + 1			   # push onto stack
		}
	    }

copy_	   
	    do i = 1, npix {
		Memi[a[i]+l]  = b[i]
		Memi[ae[i]+l] = be[i]
		Memi[c[i]+l]   = d[i]
	    }
	}
end

# GC_SORT -- Quicksort.  This is based on the VOPS asrt except that
# the input is an array of pointers to image lines and the sort is done
# across the image lines at each point along the lines.  The number of
# valid pixels at each point is allowed to vary.  The cases of 1, 2, and 3
# pixels per point are treated specially.
#
# See ic_sort in images.imcombine


# Fixed error in gc_2sort: two statements were missing from the code,
# apparently erased by accident when copying/pasting. The error appears
# to be in place at least since Mar 7, 1997.
#
# I. Busko, 28 Sep 98


procedure gc_sortr (a, b, nvecs, npts)

pointer	a[ARB]			# pointer to input vectors
real	b[ARB]			# work array
int	nvecs[npts]		# number of vectors
int	npts			# number of points in vectors

real	pivot, temp, temp3
int	i, j, k, l, p, npix, lv[LOGPTR], uv[LOGPTR]
define	swap {temp=$1;$1=$2;$2=temp}
define	copy_	10

begin
	do l = 0, npts-1 {
	    npix = nvecs[l+1]
	    if (npix <= 1)
		next

	    do i = 1, npix
		b[i] = Memr[a[i]+l]

	    # Special cases
	    if (npix <= 3) {
		pivot = b[1]
		temp = b[2]
		if (npix == 2) {
		    if (temp < pivot) {
			b[1] = temp
			b[2] = pivot
		    } else
			next
		} else {
		    temp3 = b[3]
		    if (temp < pivot) {				# bac|bca|cba
			if (temp < temp3) {			# bac|bca
			    b[1] = temp
			    if (pivot < temp3)			# bac
				b[2] = pivot
			    else {				# bca
				b[2] = temp3
				b[3] = pivot
			    }
			} else {				# cba
			    b[1] = temp3
			    b[3] = pivot
			}
		    } else if (temp3 < temp) {			# acb|cab
			b[3] = temp
			if (pivot < temp3)			# acb
			    b[2] = temp3
			else {					# cab
			    b[1] = temp3
			    b[2] = pivot
			}
		    } else
			next
		}
		goto copy_
	    }

	    # General case
	    do i = 1, npix
		b[i] = Memr[a[i]+l]

	    lv[1] = 1
	    uv[1] = npix
	    p = 1

	    while (p > 0) {
		if (lv[p] >= uv[p])		# only one elem in this subset
		    p = p - 1			# pop stack
		else {
		    # Dummy do loop to trigger the Fortran optimizer.
		    do p = p, ARB {
			i = lv[p] - 1
			j = uv[p]

			# Select as the pivot the element at the center of the
			# array, to avoid quadratic behavior on an already
			# sorted array.

			k = (lv[p] + uv[p]) / 2
			swap (b[j], b[k])
			pivot = b[j]		   # pivot line

			while (i < j) {
			    for (i=i+1;  b[i] < pivot;  i=i+1)
				;
			    for (j=j-1;  j > i;  j=j-1)
				if (b[j] <= pivot)
				    break
			    if (i < j)		   # out of order pair
				swap (b[i], b[j])  # interchange elements
			}

			j = uv[p]		   # move pivot to position i
			swap (b[i], b[j])	   # interchange elements

			if (i-lv[p] < uv[p] - i) { # stack so shorter done first
			    lv[p+1] = lv[p]
			    uv[p+1] = i - 1
			    lv[p] = i + 1
			} else {
			    lv[p+1] = i + 1
			    uv[p+1] = uv[p]
			    uv[p] = i - 1
			}

			break
		    }
		    p = p + 1			   # push onto stack
		}
	    }

copy_
	    do i = 1, npix
		Memr[a[i]+l] = b[i]
	}
end


# GC_2SORT -- Quicksort.  This is based on the VOPS asrt except that
# the input is an array of pointers to image lines and the sort is done
# across the image lines at each point along the lines.  The number of
# valid pixels at each point is allowed to vary.  The cases of 1, 2, and 3
# pixels per point are treated specially.  A second integer set of
# vectors is sorted.
#
# See images.imcombine

procedure gc_2sortr (a, b, c, d, nvecs, npts)

pointer	a[ARB]			# pointer to input vectors
real	b[ARB]			# work array
pointer	c[ARB]			# pointer to associated integer vectors
int	d[ARB]			# work array
int	nvecs[npts]		# number of vectors
int	npts			# number of points in vectors

real	pivot, temp, temp3
int	i, j, k, l, p, npix, lv[LOGPTR], uv[LOGPTR], itemp
define	swap {temp=$1;$1=$2;$2=temp}
define	iswap {itemp=$1;$1=$2;$2=itemp}
define	copy_	10

begin
	do l = 0, npts-1 {
	    npix = nvecs[l+1]
	    if (npix <= 1)
		next

	    do i = 1, npix {
		b[i] = Memr[a[i]+l]
		d[i] = Memi[c[i]+l]
	    }

	    # Special cases
	    if (npix <= 3) {
		pivot = b[1]
		temp = b[2]
		if (npix == 2) {
		    if (temp < pivot) {
			b[1] = temp
			b[2] = pivot
			iswap (d[1], d[2])
		    } else
			next
		} else {
		    temp3 = b[3]
		    if (temp < pivot) {				# bac|bca|cba
			if (temp < temp3) {			# bac|bca
			    b[1] = temp
			    if (pivot < temp3) {		# bac
				b[2] = pivot
				iswap (d[1], d[2])
			    } else {				# bca
				b[2] = temp3
				b[3] = pivot
				itemp = d[2]
				d[2] = d[3]
	                        # The following two statements were
                                # missing in the gcombine code. They
                                # exist in the original imcombine code,
                                # thus apparently someone screwed it up
                                # when copying / pasting (IB, 9/28/98)
				d[3] = d[1]
				d[1] = itemp
			    }
			} else {				# cba
			    b[1] = temp3
			    b[3] = pivot
			    iswap (d[1], d[3])
			}
		    } else if (temp3 < temp) {			# acb|cab
			b[3] = temp
			if (pivot < temp3) {			# acb
			    b[2] = temp3
			    iswap (d[2], d[3])
			} else {				# cab
			    b[1] = temp3
			    b[2] = pivot
			    itemp = d[2]
			    d[2] = d[1]
			    d[1] = d[3]
			    d[3] = itemp
			}
		    } else
			next
		}
		goto copy_
	    }

	    # General case
	    lv[1] = 1
	    uv[1] = npix
	    p = 1

	    while (p > 0) {
		if (lv[p] >= uv[p])		# only one elem in this subset
		    p = p - 1			# pop stack
		else {
		    # Dummy do loop to trigger the Fortran optimizer.
		    do p = p, ARB {
			i = lv[p] - 1
			j = uv[p]

			# Select as the pivot the element at the center of the
			# array, to avoid quadratic behavior on an already
			# sorted array.

			k = (lv[p] + uv[p]) / 2
			swap (b[j], b[k]); swap (d[j], d[k])
			pivot = b[j]		   # pivot line

			while (i < j) {
			    for (i=i+1;  b[i] < pivot;  i=i+1)
				;
			    for (j=j-1;  j > i;  j=j-1)
				if (b[j] <= pivot)
				    break
			    if (i < j) {	   # out of order pair
				swap (b[i], b[j])  # interchange elements
				swap (d[i], d[j])
			    }
			}

			j = uv[p]		   # move pivot to position i
			swap (b[i], b[j])	   # interchange elements
			swap (d[i], d[j])

			if (i-lv[p] < uv[p] - i) { # stack so shorter done first
			    lv[p+1] = lv[p]
			    uv[p+1] = i - 1
			    lv[p] = i + 1
			} else {
			    lv[p+1] = i + 1
			    uv[p+1] = uv[p]
			    uv[p] = i - 1
			}

			break
		    }
		    p = p + 1			   # push onto stack
		}
	    }

copy_	   
	    do i = 1, npix {
		Memr[a[i]+l] = b[i]
		Memi[c[i]+l] = d[i]
	    }
	}
end






# GC_3SORT -- Quicksort.  This is based on the VOPS asrt except that
# the input is an array of pointers to image lines and the sort is done
# across the image lines at each point along the lines.  The number of
# valid pixels at each point is allowed to vary.  The cases of 1, 2, and 3
# pixels per point are treated specially.  A second integer set of
# vectors and a third real set of vectors are sorted.
#
# 
# This routine adds an extra real vector to the ones sorted by
# gc_2sort. When sorting of errors is neccessary in gc_gedtata, it
# was performed in a separate call to gc_sort, which sorts a single
# vector. This caused the error values to get scrambled in relation to
# their associated data values. The error vectors can't be actually
# sorted, they must simply be carried along when their associated 
# data values are sorted.
#
# I. Busko, 28 Sep 98

procedure gc_3sortr (a, b, ae, be, c, d, nvecs, npts)

pointer	a[ARB]			# pointer to input vectors
real	b[ARB]			# work array
pointer	ae[ARB]			# pointer to associated input error vectors
real	be[ARB]			# work array
pointer	c[ARB]			# pointer to associated integer vectors
int	d[ARB]			# work array
int	nvecs[npts]		# number of vectors
int	npts			# number of points in vectors

real	pivot, temp, temp3, temp2
int	i, j, k, l, p, npix, lv[LOGPTR], uv[LOGPTR], itemp
define	swap {temp=$1;$1=$2;$2=temp}
define	iswap {itemp=$1;$1=$2;$2=itemp}
define	copy_	10

begin
	do l = 0, npts-1 {
	    npix = nvecs[l+1]
	    if (npix <= 1)
		next

	    do i = 1, npix {
		b[i]  = Memr[a[i]+l]
		be[i] = Memr[ae[i]+l]
		d[i]  = Memi[c[i]+l]
	    }

	    # Special cases
	    if (npix <= 3) {
		pivot = b[1]
		temp = b[2]
		if (npix == 2) {
		    if (temp < pivot) {
			b[1] = temp
			b[2] = pivot
			swap  (be[1], be[2])
			iswap (d[1],  d[2])
		    } else
			next
		} else {
		    temp3 = b[3]
		    if (temp < pivot) {				# bac|bca|cba
			if (temp < temp3) {			# bac|bca
			    b[1] = temp
			    if (pivot < temp3) {		# bac
				b[2] = pivot
				swap  (be[1], be[2])
				iswap (d[1],  d[2])
			    } else {				# bca
				b[2]  = temp3
				b[3]  = pivot
				temp2 = be[2]
				be[2] = be[3]
				be[3] = be[1]
				be[1] = temp2
				itemp = d[2]
				d[2]  = d[3]
				d[3] = d[1]
				d[1] = itemp
			    }
			} else {				# cba
			    b[1] = temp3
			    b[3] = pivot
			    swap  (be[1], be[3])
			    iswap (d[1],  d[3])
			}
		    } else if (temp3 < temp) {			# acb|cab
			b[3] = temp
			if (pivot < temp3) {			# acb
			    b[2] = temp3
			    swap  (be[2], be[3])
			    iswap (d[2],  d[3])
			} else {				# cab
			    b[1]  = temp3
			    b[2]  = pivot
			    temp2 = be[2]
			    be[2] = be[1]
			    be[1] = be[3]
			    be[3] = temp2
			    itemp = d[2]
			    d[2]  = d[1]
			    d[1]  = d[3]
			    d[3]  = itemp
			}
		    } else
			next
		}
		goto copy_
	    }

	    # General case
	    lv[1] = 1
	    uv[1] = npix
	    p = 1

	    while (p > 0) {
		if (lv[p] >= uv[p])		# only one elem in this subset
		    p = p - 1			# pop stack
		else {
		    # Dummy do loop to trigger the Fortran optimizer.
		    do p = p, ARB {
			i = lv[p] - 1
			j = uv[p]

			# Select as the pivot the element at the center of the
			# array, to avoid quadratic behavior on an already
			# sorted array.

			k = (lv[p] + uv[p]) / 2
			swap (b[j], b[k]); swap (d[j], d[k]); swap (be[j], be[k])
			pivot = b[j]		   # pivot line

			while (i < j) {
			    for (i=i+1;  b[i] < pivot;  i=i+1)
				;
			    for (j=j-1;  j > i;  j=j-1)
				if (b[j] <= pivot)
				    break
			    if (i < j) { 	    # out of order pair
				swap (b[i],  b[j])  # interchange elements
				swap (be[i], be[j])
				swap (d[i],  d[j])
			    }
			}

			j = uv[p]		   # move pivot to position i
			swap (b[i],  b[j])	   # interchange elements
			swap (d[i],  d[j])
			swap (be[i], be[j])

			if (i-lv[p] < uv[p] - i) { # stack so shorter done first
			    lv[p+1] = lv[p]
			    uv[p+1] = i - 1
			    lv[p] = i + 1
			} else {
			    lv[p+1] = i + 1
			    uv[p+1] = uv[p]
			    uv[p] = i - 1
			}

			break
		    }
		    p = p + 1			   # push onto stack
		}
	    }

copy_	   
	    do i = 1, npix {
		Memr[a[i]+l]  = b[i]
		Memr[ae[i]+l] = be[i]
		Memi[c[i]+l]   = d[i]
	    }
	}
end

# GC_SORT -- Quicksort.  This is based on the VOPS asrt except that
# the input is an array of pointers to image lines and the sort is done
# across the image lines at each point along the lines.  The number of
# valid pixels at each point is allowed to vary.  The cases of 1, 2, and 3
# pixels per point are treated specially.
#
# See ic_sort in images.imcombine


# Fixed error in gc_2sort: two statements were missing from the code,
# apparently erased by accident when copying/pasting. The error appears
# to be in place at least since Mar 7, 1997.
#
# I. Busko, 28 Sep 98


procedure gc_sortd (a, b, nvecs, npts)

pointer	a[ARB]			# pointer to input vectors
double	b[ARB]			# work array
int	nvecs[npts]		# number of vectors
int	npts			# number of points in vectors

double	pivot, temp, temp3
int	i, j, k, l, p, npix, lv[LOGPTR], uv[LOGPTR]
define	swap {temp=$1;$1=$2;$2=temp}
define	copy_	10

begin
	do l = 0, npts-1 {
	    npix = nvecs[l+1]
	    if (npix <= 1)
		next

	    do i = 1, npix
		b[i] = Memd[a[i]+l]

	    # Special cases
	    if (npix <= 3) {
		pivot = b[1]
		temp = b[2]
		if (npix == 2) {
		    if (temp < pivot) {
			b[1] = temp
			b[2] = pivot
		    } else
			next
		} else {
		    temp3 = b[3]
		    if (temp < pivot) {				# bac|bca|cba
			if (temp < temp3) {			# bac|bca
			    b[1] = temp
			    if (pivot < temp3)			# bac
				b[2] = pivot
			    else {				# bca
				b[2] = temp3
				b[3] = pivot
			    }
			} else {				# cba
			    b[1] = temp3
			    b[3] = pivot
			}
		    } else if (temp3 < temp) {			# acb|cab
			b[3] = temp
			if (pivot < temp3)			# acb
			    b[2] = temp3
			else {					# cab
			    b[1] = temp3
			    b[2] = pivot
			}
		    } else
			next
		}
		goto copy_
	    }

	    # General case
	    do i = 1, npix
		b[i] = Memd[a[i]+l]

	    lv[1] = 1
	    uv[1] = npix
	    p = 1

	    while (p > 0) {
		if (lv[p] >= uv[p])		# only one elem in this subset
		    p = p - 1			# pop stack
		else {
		    # Dummy do loop to trigger the Fortran optimizer.
		    do p = p, ARB {
			i = lv[p] - 1
			j = uv[p]

			# Select as the pivot the element at the center of the
			# array, to avoid quadratic behavior on an already
			# sorted array.

			k = (lv[p] + uv[p]) / 2
			swap (b[j], b[k])
			pivot = b[j]		   # pivot line

			while (i < j) {
			    for (i=i+1;  b[i] < pivot;  i=i+1)
				;
			    for (j=j-1;  j > i;  j=j-1)
				if (b[j] <= pivot)
				    break
			    if (i < j)		   # out of order pair
				swap (b[i], b[j])  # interchange elements
			}

			j = uv[p]		   # move pivot to position i
			swap (b[i], b[j])	   # interchange elements

			if (i-lv[p] < uv[p] - i) { # stack so shorter done first
			    lv[p+1] = lv[p]
			    uv[p+1] = i - 1
			    lv[p] = i + 1
			} else {
			    lv[p+1] = i + 1
			    uv[p+1] = uv[p]
			    uv[p] = i - 1
			}

			break
		    }
		    p = p + 1			   # push onto stack
		}
	    }

copy_
	    do i = 1, npix
		Memd[a[i]+l] = b[i]
	}
end


# GC_2SORT -- Quicksort.  This is based on the VOPS asrt except that
# the input is an array of pointers to image lines and the sort is done
# across the image lines at each point along the lines.  The number of
# valid pixels at each point is allowed to vary.  The cases of 1, 2, and 3
# pixels per point are treated specially.  A second integer set of
# vectors is sorted.
#
# See images.imcombine

procedure gc_2sortd (a, b, c, d, nvecs, npts)

pointer	a[ARB]			# pointer to input vectors
double	b[ARB]			# work array
pointer	c[ARB]			# pointer to associated integer vectors
int	d[ARB]			# work array
int	nvecs[npts]		# number of vectors
int	npts			# number of points in vectors

double	pivot, temp, temp3
int	i, j, k, l, p, npix, lv[LOGPTR], uv[LOGPTR], itemp
define	swap {temp=$1;$1=$2;$2=temp}
define	iswap {itemp=$1;$1=$2;$2=itemp}
define	copy_	10

begin
	do l = 0, npts-1 {
	    npix = nvecs[l+1]
	    if (npix <= 1)
		next

	    do i = 1, npix {
		b[i] = Memd[a[i]+l]
		d[i] = Memi[c[i]+l]
	    }

	    # Special cases
	    if (npix <= 3) {
		pivot = b[1]
		temp = b[2]
		if (npix == 2) {
		    if (temp < pivot) {
			b[1] = temp
			b[2] = pivot
			iswap (d[1], d[2])
		    } else
			next
		} else {
		    temp3 = b[3]
		    if (temp < pivot) {				# bac|bca|cba
			if (temp < temp3) {			# bac|bca
			    b[1] = temp
			    if (pivot < temp3) {		# bac
				b[2] = pivot
				iswap (d[1], d[2])
			    } else {				# bca
				b[2] = temp3
				b[3] = pivot
				itemp = d[2]
				d[2] = d[3]
	                        # The following two statements were
                                # missing in the gcombine code. They
                                # exist in the original imcombine code,
                                # thus apparently someone screwed it up
                                # when copying / pasting (IB, 9/28/98)
				d[3] = d[1]
				d[1] = itemp
			    }
			} else {				# cba
			    b[1] = temp3
			    b[3] = pivot
			    iswap (d[1], d[3])
			}
		    } else if (temp3 < temp) {			# acb|cab
			b[3] = temp
			if (pivot < temp3) {			# acb
			    b[2] = temp3
			    iswap (d[2], d[3])
			} else {				# cab
			    b[1] = temp3
			    b[2] = pivot
			    itemp = d[2]
			    d[2] = d[1]
			    d[1] = d[3]
			    d[3] = itemp
			}
		    } else
			next
		}
		goto copy_
	    }

	    # General case
	    lv[1] = 1
	    uv[1] = npix
	    p = 1

	    while (p > 0) {
		if (lv[p] >= uv[p])		# only one elem in this subset
		    p = p - 1			# pop stack
		else {
		    # Dummy do loop to trigger the Fortran optimizer.
		    do p = p, ARB {
			i = lv[p] - 1
			j = uv[p]

			# Select as the pivot the element at the center of the
			# array, to avoid quadratic behavior on an already
			# sorted array.

			k = (lv[p] + uv[p]) / 2
			swap (b[j], b[k]); swap (d[j], d[k])
			pivot = b[j]		   # pivot line

			while (i < j) {
			    for (i=i+1;  b[i] < pivot;  i=i+1)
				;
			    for (j=j-1;  j > i;  j=j-1)
				if (b[j] <= pivot)
				    break
			    if (i < j) {	   # out of order pair
				swap (b[i], b[j])  # interchange elements
				swap (d[i], d[j])
			    }
			}

			j = uv[p]		   # move pivot to position i
			swap (b[i], b[j])	   # interchange elements
			swap (d[i], d[j])

			if (i-lv[p] < uv[p] - i) { # stack so shorter done first
			    lv[p+1] = lv[p]
			    uv[p+1] = i - 1
			    lv[p] = i + 1
			} else {
			    lv[p+1] = i + 1
			    uv[p+1] = uv[p]
			    uv[p] = i - 1
			}

			break
		    }
		    p = p + 1			   # push onto stack
		}
	    }

copy_	   
	    do i = 1, npix {
		Memd[a[i]+l] = b[i]
		Memi[c[i]+l] = d[i]
	    }
	}
end






# GC_3SORT -- Quicksort.  This is based on the VOPS asrt except that
# the input is an array of pointers to image lines and the sort is done
# across the image lines at each point along the lines.  The number of
# valid pixels at each point is allowed to vary.  The cases of 1, 2, and 3
# pixels per point are treated specially.  A second integer set of
# vectors and a third real set of vectors are sorted.
#
# 
# This routine adds an extra real vector to the ones sorted by
# gc_2sort. When sorting of errors is neccessary in gc_gedtata, it
# was performed in a separate call to gc_sort, which sorts a single
# vector. This caused the error values to get scrambled in relation to
# their associated data values. The error vectors can't be actually
# sorted, they must simply be carried along when their associated 
# data values are sorted.
#
# I. Busko, 28 Sep 98

procedure gc_3sortd (a, b, ae, be, c, d, nvecs, npts)

pointer	a[ARB]			# pointer to input vectors
double	b[ARB]			# work array
pointer	ae[ARB]			# pointer to associated input error vectors
double	be[ARB]			# work array
pointer	c[ARB]			# pointer to associated integer vectors
int	d[ARB]			# work array
int	nvecs[npts]		# number of vectors
int	npts			# number of points in vectors

double	pivot, temp, temp3, temp2
int	i, j, k, l, p, npix, lv[LOGPTR], uv[LOGPTR], itemp
define	swap {temp=$1;$1=$2;$2=temp}
define	iswap {itemp=$1;$1=$2;$2=itemp}
define	copy_	10

begin
	do l = 0, npts-1 {
	    npix = nvecs[l+1]
	    if (npix <= 1)
		next

	    do i = 1, npix {
		b[i]  = Memd[a[i]+l]
		be[i] = Memd[ae[i]+l]
		d[i]  = Memi[c[i]+l]
	    }

	    # Special cases
	    if (npix <= 3) {
		pivot = b[1]
		temp = b[2]
		if (npix == 2) {
		    if (temp < pivot) {
			b[1] = temp
			b[2] = pivot
			swap  (be[1], be[2])
			iswap (d[1],  d[2])
		    } else
			next
		} else {
		    temp3 = b[3]
		    if (temp < pivot) {				# bac|bca|cba
			if (temp < temp3) {			# bac|bca
			    b[1] = temp
			    if (pivot < temp3) {		# bac
				b[2] = pivot
				swap  (be[1], be[2])
				iswap (d[1],  d[2])
			    } else {				# bca
				b[2]  = temp3
				b[3]  = pivot
				temp2 = be[2]
				be[2] = be[3]
				be[3] = be[1]
				be[1] = temp2
				itemp = d[2]
				d[2]  = d[3]
				d[3] = d[1]
				d[1] = itemp
			    }
			} else {				# cba
			    b[1] = temp3
			    b[3] = pivot
			    swap  (be[1], be[3])
			    iswap (d[1],  d[3])
			}
		    } else if (temp3 < temp) {			# acb|cab
			b[3] = temp
			if (pivot < temp3) {			# acb
			    b[2] = temp3
			    swap  (be[2], be[3])
			    iswap (d[2],  d[3])
			} else {				# cab
			    b[1]  = temp3
			    b[2]  = pivot
			    temp2 = be[2]
			    be[2] = be[1]
			    be[1] = be[3]
			    be[3] = temp2
			    itemp = d[2]
			    d[2]  = d[1]
			    d[1]  = d[3]
			    d[3]  = itemp
			}
		    } else
			next
		}
		goto copy_
	    }

	    # General case
	    lv[1] = 1
	    uv[1] = npix
	    p = 1

	    while (p > 0) {
		if (lv[p] >= uv[p])		# only one elem in this subset
		    p = p - 1			# pop stack
		else {
		    # Dummy do loop to trigger the Fortran optimizer.
		    do p = p, ARB {
			i = lv[p] - 1
			j = uv[p]

			# Select as the pivot the element at the center of the
			# array, to avoid quadratic behavior on an already
			# sorted array.

			k = (lv[p] + uv[p]) / 2
			swap (b[j], b[k]); swap (d[j], d[k]); swap (be[j], be[k])
			pivot = b[j]		   # pivot line

			while (i < j) {
			    for (i=i+1;  b[i] < pivot;  i=i+1)
				;
			    for (j=j-1;  j > i;  j=j-1)
				if (b[j] <= pivot)
				    break
			    if (i < j) { 	    # out of order pair
				swap (b[i],  b[j])  # interchange elements
				swap (be[i], be[j])
				swap (d[i],  d[j])
			    }
			}

			j = uv[p]		   # move pivot to position i
			swap (b[i],  b[j])	   # interchange elements
			swap (d[i],  d[j])
			swap (be[i], be[j])

			if (i-lv[p] < uv[p] - i) { # stack so shorter done first
			    lv[p+1] = lv[p]
			    uv[p+1] = i - 1
			    lv[p] = i + 1
			} else {
			    lv[p+1] = i + 1
			    uv[p+1] = uv[p]
			    uv[p] = i - 1
			}

			break
		    }
		    p = p + 1			   # push onto stack
		}
	    }

copy_	   
	    do i = 1, npix {
		Memd[a[i]+l]  = b[i]
		Memd[ae[i]+l] = be[i]
		Memi[c[i]+l]   = d[i]
	    }
	}
end

