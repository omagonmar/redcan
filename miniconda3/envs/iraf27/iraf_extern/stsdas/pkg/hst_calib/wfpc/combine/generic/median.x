include "wpdef.h"

.help median
.nf ----------------------------------------------------------------------------
              COMBINING IMAGES: MEDIAN ALGORITHM

The input images are combined by scaling and taking the median.  The exposure 
time of the output image is the scaled and weighted average of the input 
exposure times.  If some of the input images are real datatypes and the 
output image is short datatype there will be truncation.

PROCEDURES:

    MEDIAN	 -- Median of lines (no scaling).
    DQMEDIAN	 -- Scaled median of lines excluding bad pixels.
    SCMEDIAN	 -- Scaled median of lines.
    BIGSORT	 -- Sort by increasing value. Heapsort used for large arrays.
    SMALLSORT	 -- Sort by increasing value. Straight Insertion for small arrays.
.endhelp -----------------------------------------------------------------------



#################################################################################
# MEDIAN --	Determine the median of image lines with no scaling.  This 	#
#		routine is based upon the `images.imcombine' package.  		#
#										#
#		Development version:	1/91	RAShaw				#

procedure medians (data, median, nimages, npts)

# Calling arguments:
pointer		data[nimages]		# Input data line pointers
real		median[npts]		# Output data line
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line

# Local variables:
int		half			# Half the number of used images @pixel
int		i, j			# Loop indexs
real		work[IMS_MAX]		# Work array

begin

# Initialize working array. 
	do j = 1, npts {
	    do i = 1, nimages {
		work[i] = Mems[data[i]+j-1]
	    }

# Sort pixel values into increasing order.
	    switch (nimages) {
	    case 0, 1:
		return
	    case 2:
		;
	    case 3, 4, 5, 6, 7:
		call smallsorts (work, nimages)
	    default:
		call bigsorts (work, nimages)
	    }

# Select median value.  For an even number of elements compute the mean of the 
# two values @midpoint.  
	    half = nimages / 2
	    if (half*2 < nimages) 
		median[j] = work[half+1]
	    else
		median[j] = (work[half] + work[half+1]) / 2.
	}
end


#################################################################################
# DQMEDIAN --	Combine the images by scaling and taking the median, excluding 	#
#		bad pixels.  This routine is based upon the `images.imcombine' 	#
#		package.  							#
#										#
#		Development version:	1/91	RAShaw				#

procedure dqmedians (data, dqfdata, median, nimages, npts)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# Input data line pointers
int		dqfdata[nimages]	# Data Quality File pointers
real		median[npts]		# Output data line
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line

# Local variables:
int		bflag[IMS_MAX]		# 
int		half			# Half the number of used images @pixel
int		i, j			# Loop indexes
int		ncount			# Number of non-rejected images @pixel
real		work[IMS_MAX]		# Scaled, non-flagged data

begin
	do j = 1, npts {

# Select user-chosen Data Quality bits.
	    do i = 1, nimages
		bflag[i] = Memi[dqfdata[i]+j-1]
	    call aandki (bflag, BADBITS, bflag, npts)

# Initialize working array. 
	    ncount = 0
	    do i = 1, nimages {
		if (bflag[i] == 0) {
		    ncount       = ncount + 1
		    work[ncount] = Mems[data[i]+j-1] / SCALES[i] - ZEROS[i]
		} else
		    Mems[data[i]+j-1] = INDEFS
	    }

# Sort pixel values into increasing order.
	    switch (ncount) {
	    case 0:
		median[j] = BLANK
		next
	    case 1, 2:
		;
	    case 3, 4, 5, 6, 7:
		call smallsorts (work, ncount)
	    default:
		call bigsorts (work, ncount)
	    }

# Select median value.  For an even number of elements compute the mean of the 
# two values @midpoint.  
	    half = ncount / 2
	    if (half*2 < ncount) 
		median[j] = work[half+1]
	    else
		median[j] = (work[half] + work[half+1]) / 2.
	}
end


#################################################################################
# SCMEDIAN --	Combine the images by scaling and taking the median, excluding 	#
#		bad pixels.  This routine is based upon the `images.imcombine' 	#
#		package.  							#
#										#
#		Development version:	1/91	RAShaw				#

procedure scmedians (data, median, nimages, npts)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# Input data line pointers
real		median[npts]		# Output data line
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line

# Local variables:
int		half			# Half the number of used images @pixel
int		i, j			# Loop indexes
real		work[IMS_MAX]		# Scaled, non-flagged data

begin

# Initialize working array.
	do j = 1, npts {
	    do i = 1, nimages {
		work[i] = Mems[data[i]+j-1] / SCALES[i] - ZEROS[i]
	    }

# Sort pixel values into increasing order.
	    switch (nimages) {
	    case 0, 1:
		return
	    case 2:
		;
	    case 3, 4, 5, 6, 7:
		call smallsorts (work, nimages)
	    default:
		call bigsorts (work, nimages)
	    }

# Select median value.  For an even number of elements compute the mean of the 
# two values @midpoint.  
	    half = nimages / 2
	    if (half*2 < nimages) 
		median[j] = work[half+1]
	    else
		median[j] = (work[half] + work[half+1]) / 2.
	}
end


#################################################################################
# BIGSORT --	Sort array "work" of length "n" into ascending numerical order 	#
#		using the Heapsort algorithm found in "Numerical Recipies".  	#
#		The array "work" is replaced on output by its sorted rearrange-	#
#		ment.  								#
#										#
#		Development version:	1/91	RAShaw				#

procedure bigsorts (work, nc)

# Calling arguments:
real		work[nc]	# Array of values
int		nc		# Number of values to be sorted

# Local variables:
int		i, ir, j, m	# Dummy indexes
real		temp		# Temporary value

begin
	m  = nc / 2 + 1
	ir = nc

# The index "m" will be decremented from its initial value down to 1 during the 
# heap creation phase.  Once it reaches 1, the index "ir" will be decremented 
# from its initial value down to 1 during the heap selection phase. 
	repeat {
	    if (m > 1) {
		m    = m - 1
		temp = work[m]
	    } else {				# 
		temp     = work[ir]		# Clear a space @end of array & 
		work[ir] = work[1]		# retire top of heap into it.
		ir       = ir - 1		# 
		if (ir == 1) {			# Done with the last promotion?
		    work[1] = temp		# The lowest value
		    return
		}
	    }
	    i = m
	    j = m + m
	    while (j <= ir) {		# Sift "temp" down to its proper level
		if (j < ir) {
		    if (work[j] < work[j+1])
			j = j + 1
		}
		if (temp < work[j]) {		# Demote "temp"
		    work[i] = work[j]
		    i = j
		    j = j + j
		} else				# Correct level for "temp" 
		    j = ir + 1			# Set "j" to terminate sift-down
	    }
	    work[i] = temp			# Put "temp" into its slot
	}
end


#################################################################################
# SMALLSORT --	Sort vector by increasing value.  This algorithm is based on 	#
#		the Straight Insertion routine ("PIKSRT") found in "Numerical 	#
#		Recipies", and is best for small vectors.  The array WORK is 	#
# 		replaced on output by its sorted rearrangement.  		#
#										#
#		Development version:	1/91	RAShaw				#

procedure smallsorts (work, nc)

# Calling arguments:
real		work[nc]		# Working array of data values
int		nc			# Number of input images used per pixel.

# Local variables:
int		i, j			# Loop indexes
real		temp			# Temporary value

begin

# Pick out each element in turn.
	do j = 2, nc {
	    temp = work[j]

# Look for the place to insert it.
	    do i = j-1, 1, -1 {
		if (work[i] <= temp) goto 10
		work[i+1] = work[i]
	    }
	    i = 0
10	    work[i+1] = temp
	}
end


#################################################################################
# MEDIAN --	Determine the median of image lines with no scaling.  This 	#
#		routine is based upon the `images.imcombine' package.  		#
#										#
#		Development version:	1/91	RAShaw				#

procedure mediani (data, median, nimages, npts)

# Calling arguments:
pointer		data[nimages]		# Input data line pointers
real		median[npts]		# Output data line
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line

# Local variables:
int		half			# Half the number of used images @pixel
int		i, j			# Loop indexs
real		work[IMS_MAX]		# Work array

begin

# Initialize working array. 
	do j = 1, npts {
	    do i = 1, nimages {
		work[i] = Memi[data[i]+j-1]
	    }

# Sort pixel values into increasing order.
	    switch (nimages) {
	    case 0, 1:
		return
	    case 2:
		;
	    case 3, 4, 5, 6, 7:
		call smallsorti (work, nimages)
	    default:
		call bigsorti (work, nimages)
	    }

# Select median value.  For an even number of elements compute the mean of the 
# two values @midpoint.  
	    half = nimages / 2
	    if (half*2 < nimages) 
		median[j] = work[half+1]
	    else
		median[j] = (work[half] + work[half+1]) / 2.
	}
end


#################################################################################
# DQMEDIAN --	Combine the images by scaling and taking the median, excluding 	#
#		bad pixels.  This routine is based upon the `images.imcombine' 	#
#		package.  							#
#										#
#		Development version:	1/91	RAShaw				#

procedure dqmediani (data, dqfdata, median, nimages, npts)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# Input data line pointers
int		dqfdata[nimages]	# Data Quality File pointers
real		median[npts]		# Output data line
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line

# Local variables:
int		bflag[IMS_MAX]		# 
int		half			# Half the number of used images @pixel
int		i, j			# Loop indexes
int		ncount			# Number of non-rejected images @pixel
real		work[IMS_MAX]		# Scaled, non-flagged data

begin
	do j = 1, npts {

# Select user-chosen Data Quality bits.
	    do i = 1, nimages
		bflag[i] = Memi[dqfdata[i]+j-1]
	    call aandki (bflag, BADBITS, bflag, npts)

# Initialize working array. 
	    ncount = 0
	    do i = 1, nimages {
		if (bflag[i] == 0) {
		    ncount       = ncount + 1
		    work[ncount] = Memi[data[i]+j-1] / SCALES[i] - ZEROS[i]
		} else
		    Memi[data[i]+j-1] = INDEFI
	    }

# Sort pixel values into increasing order.
	    switch (ncount) {
	    case 0:
		median[j] = BLANK
		next
	    case 1, 2:
		;
	    case 3, 4, 5, 6, 7:
		call smallsorti (work, ncount)
	    default:
		call bigsorti (work, ncount)
	    }

# Select median value.  For an even number of elements compute the mean of the 
# two values @midpoint.  
	    half = ncount / 2
	    if (half*2 < ncount) 
		median[j] = work[half+1]
	    else
		median[j] = (work[half] + work[half+1]) / 2.
	}
end


#################################################################################
# SCMEDIAN --	Combine the images by scaling and taking the median, excluding 	#
#		bad pixels.  This routine is based upon the `images.imcombine' 	#
#		package.  							#
#										#
#		Development version:	1/91	RAShaw				#

procedure scmediani (data, median, nimages, npts)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# Input data line pointers
real		median[npts]		# Output data line
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line

# Local variables:
int		half			# Half the number of used images @pixel
int		i, j			# Loop indexes
real		work[IMS_MAX]		# Scaled, non-flagged data

begin

# Initialize working array.
	do j = 1, npts {
	    do i = 1, nimages {
		work[i] = Memi[data[i]+j-1] / SCALES[i] - ZEROS[i]
	    }

# Sort pixel values into increasing order.
	    switch (nimages) {
	    case 0, 1:
		return
	    case 2:
		;
	    case 3, 4, 5, 6, 7:
		call smallsorti (work, nimages)
	    default:
		call bigsorti (work, nimages)
	    }

# Select median value.  For an even number of elements compute the mean of the 
# two values @midpoint.  
	    half = nimages / 2
	    if (half*2 < nimages) 
		median[j] = work[half+1]
	    else
		median[j] = (work[half] + work[half+1]) / 2.
	}
end


#################################################################################
# BIGSORT --	Sort array "work" of length "n" into ascending numerical order 	#
#		using the Heapsort algorithm found in "Numerical Recipies".  	#
#		The array "work" is replaced on output by its sorted rearrange-	#
#		ment.  								#
#										#
#		Development version:	1/91	RAShaw				#

procedure bigsorti (work, nc)

# Calling arguments:
real		work[nc]	# Array of values
int		nc		# Number of values to be sorted

# Local variables:
int		i, ir, j, m	# Dummy indexes
real		temp		# Temporary value

begin
	m  = nc / 2 + 1
	ir = nc

# The index "m" will be decremented from its initial value down to 1 during the 
# heap creation phase.  Once it reaches 1, the index "ir" will be decremented 
# from its initial value down to 1 during the heap selection phase. 
	repeat {
	    if (m > 1) {
		m    = m - 1
		temp = work[m]
	    } else {				# 
		temp     = work[ir]		# Clear a space @end of array & 
		work[ir] = work[1]		# retire top of heap into it.
		ir       = ir - 1		# 
		if (ir == 1) {			# Done with the last promotion?
		    work[1] = temp		# The lowest value
		    return
		}
	    }
	    i = m
	    j = m + m
	    while (j <= ir) {		# Sift "temp" down to its proper level
		if (j < ir) {
		    if (work[j] < work[j+1])
			j = j + 1
		}
		if (temp < work[j]) {		# Demote "temp"
		    work[i] = work[j]
		    i = j
		    j = j + j
		} else				# Correct level for "temp" 
		    j = ir + 1			# Set "j" to terminate sift-down
	    }
	    work[i] = temp			# Put "temp" into its slot
	}
end


#################################################################################
# SMALLSORT --	Sort vector by increasing value.  This algorithm is based on 	#
#		the Straight Insertion routine ("PIKSRT") found in "Numerical 	#
#		Recipies", and is best for small vectors.  The array WORK is 	#
# 		replaced on output by its sorted rearrangement.  		#
#										#
#		Development version:	1/91	RAShaw				#

procedure smallsorti (work, nc)

# Calling arguments:
real		work[nc]		# Working array of data values
int		nc			# Number of input images used per pixel.

# Local variables:
int		i, j			# Loop indexes
real		temp			# Temporary value

begin

# Pick out each element in turn.
	do j = 2, nc {
	    temp = work[j]

# Look for the place to insert it.
	    do i = j-1, 1, -1 {
		if (work[i] <= temp) goto 10
		work[i+1] = work[i]
	    }
	    i = 0
10	    work[i+1] = temp
	}
end


#################################################################################
# MEDIAN --	Determine the median of image lines with no scaling.  This 	#
#		routine is based upon the `images.imcombine' package.  		#
#										#
#		Development version:	1/91	RAShaw				#

procedure medianl (data, median, nimages, npts)

# Calling arguments:
pointer		data[nimages]		# Input data line pointers
real		median[npts]		# Output data line
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line

# Local variables:
int		half			# Half the number of used images @pixel
int		i, j			# Loop indexs
real		work[IMS_MAX]		# Work array

begin

# Initialize working array. 
	do j = 1, npts {
	    do i = 1, nimages {
		work[i] = Meml[data[i]+j-1]
	    }

# Sort pixel values into increasing order.
	    switch (nimages) {
	    case 0, 1:
		return
	    case 2:
		;
	    case 3, 4, 5, 6, 7:
		call smallsortl (work, nimages)
	    default:
		call bigsortl (work, nimages)
	    }

# Select median value.  For an even number of elements compute the mean of the 
# two values @midpoint.  
	    half = nimages / 2
	    if (half*2 < nimages) 
		median[j] = work[half+1]
	    else
		median[j] = (work[half] + work[half+1]) / 2.
	}
end


#################################################################################
# DQMEDIAN --	Combine the images by scaling and taking the median, excluding 	#
#		bad pixels.  This routine is based upon the `images.imcombine' 	#
#		package.  							#
#										#
#		Development version:	1/91	RAShaw				#

procedure dqmedianl (data, dqfdata, median, nimages, npts)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# Input data line pointers
int		dqfdata[nimages]	# Data Quality File pointers
real		median[npts]		# Output data line
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line

# Local variables:
int		bflag[IMS_MAX]		# 
int		half			# Half the number of used images @pixel
int		i, j			# Loop indexes
int		ncount			# Number of non-rejected images @pixel
real		work[IMS_MAX]		# Scaled, non-flagged data

begin
	do j = 1, npts {

# Select user-chosen Data Quality bits.
	    do i = 1, nimages
		bflag[i] = Memi[dqfdata[i]+j-1]
	    call aandki (bflag, BADBITS, bflag, npts)

# Initialize working array. 
	    ncount = 0
	    do i = 1, nimages {
		if (bflag[i] == 0) {
		    ncount       = ncount + 1
		    work[ncount] = Meml[data[i]+j-1] / SCALES[i] - ZEROS[i]
		} else
		    Meml[data[i]+j-1] = INDEFL
	    }

# Sort pixel values into increasing order.
	    switch (ncount) {
	    case 0:
		median[j] = BLANK
		next
	    case 1, 2:
		;
	    case 3, 4, 5, 6, 7:
		call smallsortl (work, ncount)
	    default:
		call bigsortl (work, ncount)
	    }

# Select median value.  For an even number of elements compute the mean of the 
# two values @midpoint.  
	    half = ncount / 2
	    if (half*2 < ncount) 
		median[j] = work[half+1]
	    else
		median[j] = (work[half] + work[half+1]) / 2.
	}
end


#################################################################################
# SCMEDIAN --	Combine the images by scaling and taking the median, excluding 	#
#		bad pixels.  This routine is based upon the `images.imcombine' 	#
#		package.  							#
#										#
#		Development version:	1/91	RAShaw				#

procedure scmedianl (data, median, nimages, npts)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# Input data line pointers
real		median[npts]		# Output data line
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line

# Local variables:
int		half			# Half the number of used images @pixel
int		i, j			# Loop indexes
real		work[IMS_MAX]		# Scaled, non-flagged data

begin

# Initialize working array.
	do j = 1, npts {
	    do i = 1, nimages {
		work[i] = Meml[data[i]+j-1] / SCALES[i] - ZEROS[i]
	    }

# Sort pixel values into increasing order.
	    switch (nimages) {
	    case 0, 1:
		return
	    case 2:
		;
	    case 3, 4, 5, 6, 7:
		call smallsortl (work, nimages)
	    default:
		call bigsortl (work, nimages)
	    }

# Select median value.  For an even number of elements compute the mean of the 
# two values @midpoint.  
	    half = nimages / 2
	    if (half*2 < nimages) 
		median[j] = work[half+1]
	    else
		median[j] = (work[half] + work[half+1]) / 2.
	}
end


#################################################################################
# BIGSORT --	Sort array "work" of length "n" into ascending numerical order 	#
#		using the Heapsort algorithm found in "Numerical Recipies".  	#
#		The array "work" is replaced on output by its sorted rearrange-	#
#		ment.  								#
#										#
#		Development version:	1/91	RAShaw				#

procedure bigsortl (work, nc)

# Calling arguments:
real		work[nc]	# Array of values
int		nc		# Number of values to be sorted

# Local variables:
int		i, ir, j, m	# Dummy indexes
real		temp		# Temporary value

begin
	m  = nc / 2 + 1
	ir = nc

# The index "m" will be decremented from its initial value down to 1 during the 
# heap creation phase.  Once it reaches 1, the index "ir" will be decremented 
# from its initial value down to 1 during the heap selection phase. 
	repeat {
	    if (m > 1) {
		m    = m - 1
		temp = work[m]
	    } else {				# 
		temp     = work[ir]		# Clear a space @end of array & 
		work[ir] = work[1]		# retire top of heap into it.
		ir       = ir - 1		# 
		if (ir == 1) {			# Done with the last promotion?
		    work[1] = temp		# The lowest value
		    return
		}
	    }
	    i = m
	    j = m + m
	    while (j <= ir) {		# Sift "temp" down to its proper level
		if (j < ir) {
		    if (work[j] < work[j+1])
			j = j + 1
		}
		if (temp < work[j]) {		# Demote "temp"
		    work[i] = work[j]
		    i = j
		    j = j + j
		} else				# Correct level for "temp" 
		    j = ir + 1			# Set "j" to terminate sift-down
	    }
	    work[i] = temp			# Put "temp" into its slot
	}
end


#################################################################################
# SMALLSORT --	Sort vector by increasing value.  This algorithm is based on 	#
#		the Straight Insertion routine ("PIKSRT") found in "Numerical 	#
#		Recipies", and is best for small vectors.  The array WORK is 	#
# 		replaced on output by its sorted rearrangement.  		#
#										#
#		Development version:	1/91	RAShaw				#

procedure smallsortl (work, nc)

# Calling arguments:
real		work[nc]		# Working array of data values
int		nc			# Number of input images used per pixel.

# Local variables:
int		i, j			# Loop indexes
real		temp			# Temporary value

begin

# Pick out each element in turn.
	do j = 2, nc {
	    temp = work[j]

# Look for the place to insert it.
	    do i = j-1, 1, -1 {
		if (work[i] <= temp) goto 10
		work[i+1] = work[i]
	    }
	    i = 0
10	    work[i+1] = temp
	}
end


#################################################################################
# MEDIAN --	Determine the median of image lines with no scaling.  This 	#
#		routine is based upon the `images.imcombine' package.  		#
#										#
#		Development version:	1/91	RAShaw				#

procedure medianr (data, median, nimages, npts)

# Calling arguments:
pointer		data[nimages]		# Input data line pointers
real		median[npts]		# Output data line
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line

# Local variables:
int		half			# Half the number of used images @pixel
int		i, j			# Loop indexs
real		work[IMS_MAX]		# Work array

begin

# Initialize working array. 
	do j = 1, npts {
	    do i = 1, nimages {
		work[i] = Memr[data[i]+j-1]
	    }

# Sort pixel values into increasing order.
	    switch (nimages) {
	    case 0, 1:
		return
	    case 2:
		;
	    case 3, 4, 5, 6, 7:
		call smallsortr (work, nimages)
	    default:
		call bigsortr (work, nimages)
	    }

# Select median value.  For an even number of elements compute the mean of the 
# two values @midpoint.  
	    half = nimages / 2
	    if (half*2 < nimages) 
		median[j] = work[half+1]
	    else
		median[j] = (work[half] + work[half+1]) / 2.
	}
end


#################################################################################
# DQMEDIAN --	Combine the images by scaling and taking the median, excluding 	#
#		bad pixels.  This routine is based upon the `images.imcombine' 	#
#		package.  							#
#										#
#		Development version:	1/91	RAShaw				#

procedure dqmedianr (data, dqfdata, median, nimages, npts)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# Input data line pointers
int		dqfdata[nimages]	# Data Quality File pointers
real		median[npts]		# Output data line
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line

# Local variables:
int		bflag[IMS_MAX]		# 
int		half			# Half the number of used images @pixel
int		i, j			# Loop indexes
int		ncount			# Number of non-rejected images @pixel
real		work[IMS_MAX]		# Scaled, non-flagged data

begin
	do j = 1, npts {

# Select user-chosen Data Quality bits.
	    do i = 1, nimages
		bflag[i] = Memi[dqfdata[i]+j-1]
	    call aandki (bflag, BADBITS, bflag, npts)

# Initialize working array. 
	    ncount = 0
	    do i = 1, nimages {
		if (bflag[i] == 0) {
		    ncount       = ncount + 1
		    work[ncount] = Memr[data[i]+j-1] / SCALES[i] - ZEROS[i]
		} else
		    Memr[data[i]+j-1] = INDEFR
	    }

# Sort pixel values into increasing order.
	    switch (ncount) {
	    case 0:
		median[j] = BLANK
		next
	    case 1, 2:
		;
	    case 3, 4, 5, 6, 7:
		call smallsortr (work, ncount)
	    default:
		call bigsortr (work, ncount)
	    }

# Select median value.  For an even number of elements compute the mean of the 
# two values @midpoint.  
	    half = ncount / 2
	    if (half*2 < ncount) 
		median[j] = work[half+1]
	    else
		median[j] = (work[half] + work[half+1]) / 2.
	}
end


#################################################################################
# SCMEDIAN --	Combine the images by scaling and taking the median, excluding 	#
#		bad pixels.  This routine is based upon the `images.imcombine' 	#
#		package.  							#
#										#
#		Development version:	1/91	RAShaw				#

procedure scmedianr (data, median, nimages, npts)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# Input data line pointers
real		median[npts]		# Output data line
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line

# Local variables:
int		half			# Half the number of used images @pixel
int		i, j			# Loop indexes
real		work[IMS_MAX]		# Scaled, non-flagged data

begin

# Initialize working array.
	do j = 1, npts {
	    do i = 1, nimages {
		work[i] = Memr[data[i]+j-1] / SCALES[i] - ZEROS[i]
	    }

# Sort pixel values into increasing order.
	    switch (nimages) {
	    case 0, 1:
		return
	    case 2:
		;
	    case 3, 4, 5, 6, 7:
		call smallsortr (work, nimages)
	    default:
		call bigsortr (work, nimages)
	    }

# Select median value.  For an even number of elements compute the mean of the 
# two values @midpoint.  
	    half = nimages / 2
	    if (half*2 < nimages) 
		median[j] = work[half+1]
	    else
		median[j] = (work[half] + work[half+1]) / 2.
	}
end


#################################################################################
# BIGSORT --	Sort array "work" of length "n" into ascending numerical order 	#
#		using the Heapsort algorithm found in "Numerical Recipies".  	#
#		The array "work" is replaced on output by its sorted rearrange-	#
#		ment.  								#
#										#
#		Development version:	1/91	RAShaw				#

procedure bigsortr (work, nc)

# Calling arguments:
real		work[nc]	# Array of values
int		nc		# Number of values to be sorted

# Local variables:
int		i, ir, j, m	# Dummy indexes
real		temp		# Temporary value

begin
	m  = nc / 2 + 1
	ir = nc

# The index "m" will be decremented from its initial value down to 1 during the 
# heap creation phase.  Once it reaches 1, the index "ir" will be decremented 
# from its initial value down to 1 during the heap selection phase. 
	repeat {
	    if (m > 1) {
		m    = m - 1
		temp = work[m]
	    } else {				# 
		temp     = work[ir]		# Clear a space @end of array & 
		work[ir] = work[1]		# retire top of heap into it.
		ir       = ir - 1		# 
		if (ir == 1) {			# Done with the last promotion?
		    work[1] = temp		# The lowest value
		    return
		}
	    }
	    i = m
	    j = m + m
	    while (j <= ir) {		# Sift "temp" down to its proper level
		if (j < ir) {
		    if (work[j] < work[j+1])
			j = j + 1
		}
		if (temp < work[j]) {		# Demote "temp"
		    work[i] = work[j]
		    i = j
		    j = j + j
		} else				# Correct level for "temp" 
		    j = ir + 1			# Set "j" to terminate sift-down
	    }
	    work[i] = temp			# Put "temp" into its slot
	}
end


#################################################################################
# SMALLSORT --	Sort vector by increasing value.  This algorithm is based on 	#
#		the Straight Insertion routine ("PIKSRT") found in "Numerical 	#
#		Recipies", and is best for small vectors.  The array WORK is 	#
# 		replaced on output by its sorted rearrangement.  		#
#										#
#		Development version:	1/91	RAShaw				#

procedure smallsortr (work, nc)

# Calling arguments:
real		work[nc]		# Working array of data values
int		nc			# Number of input images used per pixel.

# Local variables:
int		i, j			# Loop indexes
real		temp			# Temporary value

begin

# Pick out each element in turn.
	do j = 2, nc {
	    temp = work[j]

# Look for the place to insert it.
	    do i = j-1, 1, -1 {
		if (work[i] <= temp) goto 10
		work[i+1] = work[i]
	    }
	    i = 0
10	    work[i+1] = temp
	}
end


#################################################################################
# MEDIAN --	Determine the median of image lines with no scaling.  This 	#
#		routine is based upon the `images.imcombine' package.  		#
#										#
#		Development version:	1/91	RAShaw				#

procedure mediand (data, median, nimages, npts)

# Calling arguments:
pointer		data[nimages]		# Input data line pointers
double		median[npts]		# Output data line
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line

# Local variables:
int		half			# Half the number of used images @pixel
int		i, j			# Loop indexs
double		work[IMS_MAX]		# Work array

begin

# Initialize working array. 
	do j = 1, npts {
	    do i = 1, nimages {
		work[i] = Memd[data[i]+j-1]
	    }

# Sort pixel values into increasing order.
	    switch (nimages) {
	    case 0, 1:
		return
	    case 2:
		;
	    case 3, 4, 5, 6, 7:
		call smallsortd (work, nimages)
	    default:
		call bigsortd (work, nimages)
	    }

# Select median value.  For an even number of elements compute the mean of the 
# two values @midpoint.  
	    half = nimages / 2
	    if (half*2 < nimages) 
		median[j] = work[half+1]
	    else
		median[j] = (work[half] + work[half+1]) / 2.
	}
end


#################################################################################
# DQMEDIAN --	Combine the images by scaling and taking the median, excluding 	#
#		bad pixels.  This routine is based upon the `images.imcombine' 	#
#		package.  							#
#										#
#		Development version:	1/91	RAShaw				#

procedure dqmediand (data, dqfdata, median, nimages, npts)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# Input data line pointers
int		dqfdata[nimages]	# Data Quality File pointers
double		median[npts]		# Output data line
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line

# Local variables:
int		bflag[IMS_MAX]		# 
int		half			# Half the number of used images @pixel
int		i, j			# Loop indexes
int		ncount			# Number of non-rejected images @pixel
double		work[IMS_MAX]		# Scaled, non-flagged data

begin
	do j = 1, npts {

# Select user-chosen Data Quality bits.
	    do i = 1, nimages
		bflag[i] = Memi[dqfdata[i]+j-1]
	    call aandki (bflag, BADBITS, bflag, npts)

# Initialize working array. 
	    ncount = 0
	    do i = 1, nimages {
		if (bflag[i] == 0) {
		    ncount       = ncount + 1
		    work[ncount] = Memd[data[i]+j-1] / SCALES[i] - ZEROS[i]
		} else
		    Memd[data[i]+j-1] = INDEFD
	    }

# Sort pixel values into increasing order.
	    switch (ncount) {
	    case 0:
		median[j] = BLANK
		next
	    case 1, 2:
		;
	    case 3, 4, 5, 6, 7:
		call smallsortd (work, ncount)
	    default:
		call bigsortd (work, ncount)
	    }

# Select median value.  For an even number of elements compute the mean of the 
# two values @midpoint.  
	    half = ncount / 2
	    if (half*2 < ncount) 
		median[j] = work[half+1]
	    else
		median[j] = (work[half] + work[half+1]) / 2.
	}
end


#################################################################################
# SCMEDIAN --	Combine the images by scaling and taking the median, excluding 	#
#		bad pixels.  This routine is based upon the `images.imcombine' 	#
#		package.  							#
#										#
#		Development version:	1/91	RAShaw				#

procedure scmediand (data, median, nimages, npts)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# Input data line pointers
double		median[npts]		# Output data line
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line

# Local variables:
int		half			# Half the number of used images @pixel
int		i, j			# Loop indexes
double		work[IMS_MAX]		# Scaled, non-flagged data

begin

# Initialize working array.
	do j = 1, npts {
	    do i = 1, nimages {
		work[i] = Memd[data[i]+j-1] / SCALES[i] - ZEROS[i]
	    }

# Sort pixel values into increasing order.
	    switch (nimages) {
	    case 0, 1:
		return
	    case 2:
		;
	    case 3, 4, 5, 6, 7:
		call smallsortd (work, nimages)
	    default:
		call bigsortd (work, nimages)
	    }

# Select median value.  For an even number of elements compute the mean of the 
# two values @midpoint.  
	    half = nimages / 2
	    if (half*2 < nimages) 
		median[j] = work[half+1]
	    else
		median[j] = (work[half] + work[half+1]) / 2.
	}
end


#################################################################################
# BIGSORT --	Sort array "work" of length "n" into ascending numerical order 	#
#		using the Heapsort algorithm found in "Numerical Recipies".  	#
#		The array "work" is replaced on output by its sorted rearrange-	#
#		ment.  								#
#										#
#		Development version:	1/91	RAShaw				#

procedure bigsortd (work, nc)

# Calling arguments:
double		work[nc]	# Array of values
int		nc		# Number of values to be sorted

# Local variables:
int		i, ir, j, m	# Dummy indexes
double		temp		# Temporary value

begin
	m  = nc / 2 + 1
	ir = nc

# The index "m" will be decremented from its initial value down to 1 during the 
# heap creation phase.  Once it reaches 1, the index "ir" will be decremented 
# from its initial value down to 1 during the heap selection phase. 
	repeat {
	    if (m > 1) {
		m    = m - 1
		temp = work[m]
	    } else {				# 
		temp     = work[ir]		# Clear a space @end of array & 
		work[ir] = work[1]		# retire top of heap into it.
		ir       = ir - 1		# 
		if (ir == 1) {			# Done with the last promotion?
		    work[1] = temp		# The lowest value
		    return
		}
	    }
	    i = m
	    j = m + m
	    while (j <= ir) {		# Sift "temp" down to its proper level
		if (j < ir) {
		    if (work[j] < work[j+1])
			j = j + 1
		}
		if (temp < work[j]) {		# Demote "temp"
		    work[i] = work[j]
		    i = j
		    j = j + j
		} else				# Correct level for "temp" 
		    j = ir + 1			# Set "j" to terminate sift-down
	    }
	    work[i] = temp			# Put "temp" into its slot
	}
end


#################################################################################
# SMALLSORT --	Sort vector by increasing value.  This algorithm is based on 	#
#		the Straight Insertion routine ("PIKSRT") found in "Numerical 	#
#		Recipies", and is best for small vectors.  The array WORK is 	#
# 		replaced on output by its sorted rearrangement.  		#
#										#
#		Development version:	1/91	RAShaw				#

procedure smallsortd (work, nc)

# Calling arguments:
double		work[nc]		# Working array of data values
int		nc			# Number of input images used per pixel.

# Local variables:
int		i, j			# Loop indexes
double		temp			# Temporary value

begin

# Pick out each element in turn.
	do j = 2, nc {
	    temp = work[j]

# Look for the place to insert it.
	    do i = j-1, 1, -1 {
		if (work[i] <= temp) goto 10
		work[i+1] = work[i]
	    }
	    i = 0
10	    work[i+1] = temp
	}
end


#################################################################################
# MEDIAN --	Determine the median of image lines with no scaling.  This 	#
#		routine is based upon the `images.imcombine' package.  		#
#										#
#		Development version:	1/91	RAShaw				#

procedure medianx (data, median, nimages, npts)

# Calling arguments:
pointer		data[nimages]		# Input data line pointers
complex		median[npts]		# Output data line
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line

# Local variables:
int		half			# Half the number of used images @pixel
int		i, j			# Loop indexs
complex		work[IMS_MAX]		# Work array

begin

# Initialize working array. 
	do j = 1, npts {
	    do i = 1, nimages {
		work[i] = Memx[data[i]+j-1]
	    }

# Sort pixel values into increasing order.
	    switch (nimages) {
	    case 0, 1:
		return
	    case 2:
		;
	    case 3, 4, 5, 6, 7:
		call smallsortx (work, nimages)
	    default:
		call bigsortx (work, nimages)
	    }

# Select median value.  For an even number of elements compute the mean of the 
# two values @midpoint.  
	    half = nimages / 2
	    if (half*2 < nimages) 
		median[j] = work[half+1]
	    else
		median[j] = (work[half] + work[half+1]) / 2.
	}
end


#################################################################################
# DQMEDIAN --	Combine the images by scaling and taking the median, excluding 	#
#		bad pixels.  This routine is based upon the `images.imcombine' 	#
#		package.  							#
#										#
#		Development version:	1/91	RAShaw				#

procedure dqmedianx (data, dqfdata, median, nimages, npts)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# Input data line pointers
int		dqfdata[nimages]	# Data Quality File pointers
complex		median[npts]		# Output data line
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line

# Local variables:
int		bflag[IMS_MAX]		# 
int		half			# Half the number of used images @pixel
int		i, j			# Loop indexes
int		ncount			# Number of non-rejected images @pixel
complex		work[IMS_MAX]		# Scaled, non-flagged data

begin
	do j = 1, npts {

# Select user-chosen Data Quality bits.
	    do i = 1, nimages
		bflag[i] = Memi[dqfdata[i]+j-1]
	    call aandki (bflag, BADBITS, bflag, npts)

# Initialize working array. 
	    ncount = 0
	    do i = 1, nimages {
		if (bflag[i] == 0) {
		    ncount       = ncount + 1
		    work[ncount] = Memx[data[i]+j-1] / SCALES[i] - ZEROS[i]
		} else
		    Memx[data[i]+j-1] = INDEFX
	    }

# Sort pixel values into increasing order.
	    switch (ncount) {
	    case 0:
		median[j] = BLANK
		next
	    case 1, 2:
		;
	    case 3, 4, 5, 6, 7:
		call smallsortx (work, ncount)
	    default:
		call bigsortx (work, ncount)
	    }

# Select median value.  For an even number of elements compute the mean of the 
# two values @midpoint.  
	    half = ncount / 2
	    if (half*2 < ncount) 
		median[j] = work[half+1]
	    else
		median[j] = (work[half] + work[half+1]) / 2.
	}
end


#################################################################################
# SCMEDIAN --	Combine the images by scaling and taking the median, excluding 	#
#		bad pixels.  This routine is based upon the `images.imcombine' 	#
#		package.  							#
#										#
#		Development version:	1/91	RAShaw				#

procedure scmedianx (data, median, nimages, npts)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# Input data line pointers
complex		median[npts]		# Output data line
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line

# Local variables:
int		half			# Half the number of used images @pixel
int		i, j			# Loop indexes
complex		work[IMS_MAX]		# Scaled, non-flagged data

begin

# Initialize working array.
	do j = 1, npts {
	    do i = 1, nimages {
		work[i] = Memx[data[i]+j-1] / SCALES[i] - ZEROS[i]
	    }

# Sort pixel values into increasing order.
	    switch (nimages) {
	    case 0, 1:
		return
	    case 2:
		;
	    case 3, 4, 5, 6, 7:
		call smallsortx (work, nimages)
	    default:
		call bigsortx (work, nimages)
	    }

# Select median value.  For an even number of elements compute the mean of the 
# two values @midpoint.  
	    half = nimages / 2
	    if (half*2 < nimages) 
		median[j] = work[half+1]
	    else
		median[j] = (work[half] + work[half+1]) / 2.
	}
end


#################################################################################
# BIGSORT --	Sort array "work" of length "n" into ascending numerical order 	#
#		using the Heapsort algorithm found in "Numerical Recipies".  	#
#		The array "work" is replaced on output by its sorted rearrange-	#
#		ment.  								#
#										#
#		Development version:	1/91	RAShaw				#

procedure bigsortx (work, nc)

# Calling arguments:
complex		work[nc]	# Array of values
int		nc		# Number of values to be sorted

# Local variables:
int		i, ir, j, m	# Dummy indexes
complex		temp		# Temporary value

begin
	m  = nc / 2 + 1
	ir = nc

# The index "m" will be decremented from its initial value down to 1 during the 
# heap creation phase.  Once it reaches 1, the index "ir" will be decremented 
# from its initial value down to 1 during the heap selection phase. 
	repeat {
	    if (m > 1) {
		m    = m - 1
		temp = work[m]
	    } else {				# 
		temp     = work[ir]		# Clear a space @end of array & 
		work[ir] = work[1]		# retire top of heap into it.
		ir       = ir - 1		# 
		if (ir == 1) {			# Done with the last promotion?
		    work[1] = temp		# The lowest value
		    return
		}
	    }
	    i = m
	    j = m + m
	    while (j <= ir) {		# Sift "temp" down to its proper level
		if (j < ir) {
		    if (abs (work[j]) < abs (work[j+1]))
			j = j + 1
		}
		if (abs (temp) < abs (work[j])) {
		    work[i] = work[j]
		    i = j
		    j = j + j
		} else				# Correct level for "temp" 
		    j = ir + 1			# Set "j" to terminate sift-down
	    }
	    work[i] = temp			# Put "temp" into its slot
	}
end


#################################################################################
# SMALLSORT --	Sort vector by increasing value.  This algorithm is based on 	#
#		the Straight Insertion routine ("PIKSRT") found in "Numerical 	#
#		Recipies", and is best for small vectors.  The array WORK is 	#
# 		replaced on output by its sorted rearrangement.  		#
#										#
#		Development version:	1/91	RAShaw				#

procedure smallsortx (work, nc)

# Calling arguments:
complex		work[nc]		# Working array of data values
int		nc			# Number of input images used per pixel.

# Local variables:
int		i, j			# Loop indexes
complex		temp			# Temporary value

begin

# Pick out each element in turn.
	do j = 2, nc {
	    temp = work[j]

# Look for the place to insert it.
	    do i = j-1, 1, -1 {
		if (abs(work[i]) <= abs(temp)) goto 10
		work[i+1] = work[i]
	    }
	    i = 0
10	    work[i+1] = temp
	}
end

