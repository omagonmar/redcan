include	"../gcombine.h"


# G_MEDIAN -- Median of lines
#
# CYZhang 6 May, 1994 

procedure g_medians (data, id, nimages, n, npts, median)

# Calling arguments
pointer	data[ARB]		# Input data line pointers
pointer	id[ARB]			# IDs pointers
int	nimages			# Number of images
int	n[npts]			# Number of retained pixels
int	npts			# Number of output points per line
real	median[npts]		# Median

# Local variables
pointer	sp, work
int	i, j, n1

include	"../gcombine.com"

begin
	
	call smark (sp)
	call salloc (work, nimages, TY_SHORT)
	call gc_sorts (data, Mems[work], n, npts)
	do i = 1, npts {
	    n1 = n[i]
	    if (n1 > 0) {
		do j = 1, n1
	    	    Mems[work+j-1] = Mems[data[j]+i-1]
		call g_meds (Mems[work], n1, median[i])
	    } else 
		median[i] = BLANK
	}
	call sfree (sp)
end

# G_MED -- Median of an array
#
# CYZhang April 19, 1994

procedure g_meds (a, n, med)

short	a[n]
int	n, n2
real	med, low, high

include	"../gcombine.com"

begin
	if (n == 0) {
	    med = BLANK
	    return
	}
	else if (n == 1) {
	    med = a[1]
	    return
	} else if (n == 2) {
	    low = a[1]
	    high = a[2]
	    med = (low + high) / 2.
	    return
	} 

	# Median
	if (n >= 3) {
	    n2 = 1 + n / 2
	    if (mod (n, 2) == 0) {
	        low = a[n2-1]
	        high = a[n2]
	        med = (low + high) / 2.
	    } else
	        med = a[n2]
	}
end

# G_MEDIAN -- Median of lines
#
# CYZhang 6 May, 1994 

procedure g_mediani (data, id, nimages, n, npts, median)

# Calling arguments
pointer	data[ARB]		# Input data line pointers
pointer	id[ARB]			# IDs pointers
int	nimages			# Number of images
int	n[npts]			# Number of retained pixels
int	npts			# Number of output points per line
real	median[npts]		# Median

# Local variables
pointer	sp, work
int	i, j, n1

include	"../gcombine.com"

begin
	
	call smark (sp)
	call salloc (work, nimages, TY_INT)
	call gc_sorti (data, Memi[work], n, npts)
	do i = 1, npts {
	    n1 = n[i]
	    if (n1 > 0) {
		do j = 1, n1
	    	    Memi[work+j-1] = Memi[data[j]+i-1]
		call g_medi (Memi[work], n1, median[i])
	    } else 
		median[i] = BLANK
	}
	call sfree (sp)
end

# G_MED -- Median of an array
#
# CYZhang April 19, 1994

procedure g_medi (a, n, med)

int	a[n]
int	n, n2
real	med, low, high

include	"../gcombine.com"

begin
	if (n == 0) {
	    med = BLANK
	    return
	}
	else if (n == 1) {
	    med = a[1]
	    return
	} else if (n == 2) {
	    low = a[1]
	    high = a[2]
	    med = (low + high) / 2.
	    return
	} 

	# Median
	if (n >= 3) {
	    n2 = 1 + n / 2
	    if (mod (n, 2) == 0) {
	        low = a[n2-1]
	        high = a[n2]
	        med = (low + high) / 2.
	    } else
	        med = a[n2]
	}
end

# G_MEDIAN -- Median of lines
#
# CYZhang 6 May, 1994 

procedure g_medianr (data, id, nimages, n, npts, median)

# Calling arguments
pointer	data[ARB]		# Input data line pointers
pointer	id[ARB]			# IDs pointers
int	nimages			# Number of images
int	n[npts]			# Number of retained pixels
int	npts			# Number of output points per line
real	median[npts]		# Median

# Local variables
pointer	sp, work
int	i, j, n1

include	"../gcombine.com"

begin
	
	call smark (sp)
	call salloc (work, nimages, TY_REAL)
	call gc_sortr (data, Memr[work], n, npts)
	do i = 1, npts {
	    n1 = n[i]
	    if (n1 > 0) {
		do j = 1, n1
	    	    Memr[work+j-1] = Memr[data[j]+i-1]
		call g_medr (Memr[work], n1, median[i])
	    } else 
		median[i] = BLANK
	}
	call sfree (sp)
end

# G_MED -- Median of an array
#
# CYZhang April 19, 1994

procedure g_medr (a, n, med)

real	a[n]
int	n, n2
real	med, low, high

include	"../gcombine.com"

begin
	if (n == 0) {
	    med = BLANK
	    return
	}
	else if (n == 1) {
	    med = a[1]
	    return
	} else if (n == 2) {
	    low = a[1]
	    high = a[2]
	    med = (low + high) / 2.
	    return
	} 

	# Median
	if (n >= 3) {
	    n2 = 1 + n / 2
	    if (mod (n, 2) == 0) {
	        low = a[n2-1]
	        high = a[n2]
	        med = (low + high) / 2.
	    } else
	        med = a[n2]
	}
end

# G_MEDIAN -- Median of lines
#
# CYZhang 6 May, 1994 

procedure g_mediand (data, id, nimages, n, npts, median)

# Calling arguments
pointer	data[ARB]		# Input data line pointers
pointer	id[ARB]			# IDs pointers
int	nimages			# Number of images
int	n[npts]			# Number of retained pixels
int	npts			# Number of output points per line
double	median[npts]		# Median

# Local variables
pointer	sp, work
int	i, j, n1

include	"../gcombine.com"

begin
	
	call smark (sp)
	call salloc (work, nimages, TY_DOUBLE)
	call gc_sortd (data, Memd[work], n, npts)
	do i = 1, npts {
	    n1 = n[i]
	    if (n1 > 0) {
		do j = 1, n1
	    	    Memd[work+j-1] = Memd[data[j]+i-1]
		call g_medd (Memd[work], n1, median[i])
	    } else 
		median[i] = BLANK
	}
	call sfree (sp)
end

# G_MED -- Median of an array
#
# CYZhang April 19, 1994

procedure g_medd (a, n, med)

double	a[n]
int	n, n2
double	med, low, high

include	"../gcombine.com"

begin
	if (n == 0) {
	    med = BLANK
	    return
	}
	else if (n == 1) {
	    med = a[1]
	    return
	} else if (n == 2) {
	    low = a[1]
	    high = a[2]
	    med = (low + high) / 2.
	    return
	} 

	# Median
	if (n >= 3) {
	    n2 = 1 + n / 2
	    if (mod (n, 2) == 0) {
	        low = a[n2-1]
	        high = a[n2]
	        med = (low + high) / 2.
	    } else
	        med = a[n2]
	}
end

