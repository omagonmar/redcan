include	<imhdr.h>
include	"../gcombine.h"

# GCOMBINE -- Combine images
#
#
# CYZhang 10 April 94 Based on images.imcombine
#`
# moved memory allocation for the id array from the file gc_getdata.x
# to this routine since there was a memory leak arising from the repeated
# allocation for this array in the call, but only one call to free it
# in this routine
#
# P. Greenfield 12 April 95
#
# Added support for an output list of rejected pixel maps.
#
# I.Busko 04 Apr 97
#
# Fixed a wrong 'if' statement that caused the task to fail when
# working with short or int pixel type.
#
# I.Busko 16 Apr 99


procedure gcombines (in, msk, err, rej, nimages, data, mskdata, errdata,
                      npts, out, szuw, nm)

pointer	in[nimages]		# Input images
pointer	msk[nimages]		# Input DQF maps
pointer	err[nimages]		# Input ERROR maps
pointer	rej[nimages]		# Output rejection maps
pointer	data[nimages]		# Input image data buffers
pointer	mskdata[nimages]	# Input DQF map data buffers
pointer	errdata[nimages]	# Input ERROR map data buffers
pointer	out[3]			# Output image, DQF and sigma map
int	nimages			# Number of input images
int	npts			# Number of points per output line
pointer	szuw			# Pointer to Scales structure
pointer	nm			# Pointer to noise model structure

pointer	id			# IDs
pointer	n			# Number of good pixels

int	i
pointer	sp, v1, v2, v3, outdata, rejdata, ibuf, tbuf, impnli()
pointer	impnlr()

errchk	g_scale, g_getdatas

include	"../gcombine.com"

begin
	call smark (sp)
	call salloc (id, nimages, TY_POINTER)
	call salloc (rejdata, nimages, TY_POINTER)
	call salloc (n, npts, TY_INT)
	call salloc (v1, IM_MAXDIM, TY_LONG)
	call salloc (v2, IM_MAXDIM, TY_LONG)
	call salloc (v3, IM_MAXDIM, TY_LONG)
	call amovkl (long(1), Meml[v1], IM_MAXDIM)
	call amovkl (long(1), Meml[v2], IM_MAXDIM)
	call amovkl (long(1), Meml[v3], IM_MAXDIM)

	# Get scaling, zeroing and uniform weighting factors
	# "DOSCALE" is also defined here. "DOWTS" may change here.

	call g_scale (in, msk, err, out, nimages, szuw, nm)

	do i = 1, nimages		# pg: alloc here, not g_getdata$t!
	    call malloc(Memi[id+i-1], npts, TY_INT)

	
	while (impnlr (out[1], outdata, Meml[v1]) != EOF) {

	    # "DOTHRESH" is set in the top procedure
	    call g_getdatas (in, msk, err, data, mskdata,
		errdata, Memi[n], Memi[id], nimages, npts, szuw, 
		Meml[v2], Meml[v3])

	    switch (G_REJECT) {
	    case CCDCLIP, CCDCRREJ:
		if (MCLIP)
		    call g_mccdclips (data, Memi[id], nimages, 
			Memi[n], npts, Memr[outdata], szuw, nm)
		else
		    call g_accdclips (data, Memi[id], nimages, 
			Memi[n], npts, Memr[outdata], szuw, nm)
	    case MINMAX:
		call g_mms (data, Memi[id], nimages, Memi[n], npts)
	    case RSIGCLIP, RSIGCRREJ:
		if (MCLIP)
		    call g_mrsigclips (data, Memi[id], nimages, 
			Memi[n], npts, Memr[outdata], szuw)
		else
		    call g_arsigclips (data, Memi[id], nimages, 
			Memi[n], npts, Memr[outdata], szuw)
	    case AVSIGCLIP, AVSIGCRREJ:
		if (MCLIP)
		    call g_mavsigclips (data, Memi[id], nimages, 
			Memi[n], npts, Memr[outdata], szuw)
		else
		    call g_aavsigclips (data, Memi[id], nimages, 
			Memi[n], npts, Memr[outdata], szuw)
	    case ERRCLIP, ERRCRREJ:
		if (MCLIP)
		    call g_merrclips (data, Memi[id], errdata, nimages, 
			Memi[n], npts, Memr[outdata], szuw)
		else
		    call g_aerrclips (data, Memi[id], errdata, nimages, 
			Memi[n], npts, Memr[outdata], szuw)
	    }

#	    if (grow > 0)
#		call g_grow$t (d, id, n, nimages, npts, Memr[outdata])

	    if (DOCOMBINE) {
	    	switch (G_COMBINE) {
	    	case C_AVERAGE:

		    # This statement caused the task to fail
		    # when datatype == sil (IB 4/16/99)
		    # if (G_WEIGHT == W_UNIFORM) 

		    if (G_WEIGHT == W_UNIFORM || G_WEIGHT == W_NONE) 
		    	call g_uaverages (data, Memi[id], 
			    Memi[n], npts, Memr[outdata], szuw)
		    if (G_WEIGHT == W_PIXWISE) 
		    	call g_paverages (data, Memi[id], 
			    errdata, Memi[n], npts, Memr[outdata], szuw)
	    	case C_MEDIAN:
	    	    call g_medians (data, Memi[id], nimages, Memi[n],
			npts, Memr[outdata])
		}
	    }

	    if (out[2] != NULL) {
		call amovl (Meml[v2], Meml[v1], IM_MAXDIM)
		i = impnli (out[2], ibuf, Meml[v1])
		call amovki (nimages, Memi[ibuf], npts)
		call asubi (Memi[ibuf], Memi[n], Memi[ibuf], npts)
	    }
		    
	    if (out[3] != NULL) {
		call amovl (Meml[v2], Meml[v1], IM_MAXDIM)
		i = impnlr (out[3], tbuf, Meml[v1])
		if (G_COMBINE == C_AVERAGE) {
		    if (G_WEIGHT == W_PIXWISE)
		    	call g_psigmas(data, Memi[id], errdata, Memi[n], 
			    npts, Memr[outdata], Memr[tbuf], szuw)
		    else 
		     	call g_usigmas(data, Memi[id], Memi[n], npts,
			    Memr[outdata], Memr[tbuf], szuw, nm)
		} else if (G_COMBINE == C_MEDIAN && !DOWTS) {
		    call g_usigmas(data, Memi[id], Memi[n], npts, 
			    Memr[outdata], Memr[tbuf], szuw, nm)
		}
	    }

	    if (DOREJ)
	        call outrej (rej, Memi[rejdata], Memi[n], Memi[id], 
                             npts, nimages, Meml[v2])

	    call amovl (Meml[v1], Meml[v2], IM_MAXDIM)
	}

	do i = 1, nimages
	    call mfree (Memi[id+i-1], TY_INT)

	call sfree (sp)

end

procedure gcombinei (in, msk, err, rej, nimages, data, mskdata, errdata,
                      npts, out, szuw, nm)

pointer	in[nimages]		# Input images
pointer	msk[nimages]		# Input DQF maps
pointer	err[nimages]		# Input ERROR maps
pointer	rej[nimages]		# Output rejection maps
pointer	data[nimages]		# Input image data buffers
pointer	mskdata[nimages]	# Input DQF map data buffers
pointer	errdata[nimages]	# Input ERROR map data buffers
pointer	out[3]			# Output image, DQF and sigma map
int	nimages			# Number of input images
int	npts			# Number of points per output line
pointer	szuw			# Pointer to Scales structure
pointer	nm			# Pointer to noise model structure

pointer	id			# IDs
pointer	n			# Number of good pixels

int	i
pointer	sp, v1, v2, v3, outdata, rejdata, ibuf, tbuf, impnli()
pointer	impnlr()

errchk	g_scale, g_getdatai

include	"../gcombine.com"

begin
	call smark (sp)
	call salloc (id, nimages, TY_POINTER)
	call salloc (rejdata, nimages, TY_POINTER)
	call salloc (n, npts, TY_INT)
	call salloc (v1, IM_MAXDIM, TY_LONG)
	call salloc (v2, IM_MAXDIM, TY_LONG)
	call salloc (v3, IM_MAXDIM, TY_LONG)
	call amovkl (long(1), Meml[v1], IM_MAXDIM)
	call amovkl (long(1), Meml[v2], IM_MAXDIM)
	call amovkl (long(1), Meml[v3], IM_MAXDIM)

	# Get scaling, zeroing and uniform weighting factors
	# "DOSCALE" is also defined here. "DOWTS" may change here.

	call g_scale (in, msk, err, out, nimages, szuw, nm)

	do i = 1, nimages		# pg: alloc here, not g_getdata$t!
	    call malloc(Memi[id+i-1], npts, TY_INT)

	
	while (impnlr (out[1], outdata, Meml[v1]) != EOF) {

	    # "DOTHRESH" is set in the top procedure
	    call g_getdatai (in, msk, err, data, mskdata,
		errdata, Memi[n], Memi[id], nimages, npts, szuw, 
		Meml[v2], Meml[v3])

	    switch (G_REJECT) {
	    case CCDCLIP, CCDCRREJ:
		if (MCLIP)
		    call g_mccdclipi (data, Memi[id], nimages, 
			Memi[n], npts, Memr[outdata], szuw, nm)
		else
		    call g_accdclipi (data, Memi[id], nimages, 
			Memi[n], npts, Memr[outdata], szuw, nm)
	    case MINMAX:
		call g_mmi (data, Memi[id], nimages, Memi[n], npts)
	    case RSIGCLIP, RSIGCRREJ:
		if (MCLIP)
		    call g_mrsigclipi (data, Memi[id], nimages, 
			Memi[n], npts, Memr[outdata], szuw)
		else
		    call g_arsigclipi (data, Memi[id], nimages, 
			Memi[n], npts, Memr[outdata], szuw)
	    case AVSIGCLIP, AVSIGCRREJ:
		if (MCLIP)
		    call g_mavsigclipi (data, Memi[id], nimages, 
			Memi[n], npts, Memr[outdata], szuw)
		else
		    call g_aavsigclipi (data, Memi[id], nimages, 
			Memi[n], npts, Memr[outdata], szuw)
	    case ERRCLIP, ERRCRREJ:
		if (MCLIP)
		    call g_merrclipi (data, Memi[id], errdata, nimages, 
			Memi[n], npts, Memr[outdata], szuw)
		else
		    call g_aerrclipi (data, Memi[id], errdata, nimages, 
			Memi[n], npts, Memr[outdata], szuw)
	    }

#	    if (grow > 0)
#		call g_grow$t (d, id, n, nimages, npts, Memr[outdata])

	    if (DOCOMBINE) {
	    	switch (G_COMBINE) {
	    	case C_AVERAGE:

		    # This statement caused the task to fail
		    # when datatype == sil (IB 4/16/99)
		    # if (G_WEIGHT == W_UNIFORM) 

		    if (G_WEIGHT == W_UNIFORM || G_WEIGHT == W_NONE) 
		    	call g_uaveragei (data, Memi[id], 
			    Memi[n], npts, Memr[outdata], szuw)
		    if (G_WEIGHT == W_PIXWISE) 
		    	call g_paveragei (data, Memi[id], 
			    errdata, Memi[n], npts, Memr[outdata], szuw)
	    	case C_MEDIAN:
	    	    call g_mediani (data, Memi[id], nimages, Memi[n],
			npts, Memr[outdata])
		}
	    }

	    if (out[2] != NULL) {
		call amovl (Meml[v2], Meml[v1], IM_MAXDIM)
		i = impnli (out[2], ibuf, Meml[v1])
		call amovki (nimages, Memi[ibuf], npts)
		call asubi (Memi[ibuf], Memi[n], Memi[ibuf], npts)
	    }
		    
	    if (out[3] != NULL) {
		call amovl (Meml[v2], Meml[v1], IM_MAXDIM)
		i = impnlr (out[3], tbuf, Meml[v1])
		if (G_COMBINE == C_AVERAGE) {
		    if (G_WEIGHT == W_PIXWISE)
		    	call g_psigmai(data, Memi[id], errdata, Memi[n], 
			    npts, Memr[outdata], Memr[tbuf], szuw)
		    else 
		     	call g_usigmai(data, Memi[id], Memi[n], npts,
			    Memr[outdata], Memr[tbuf], szuw, nm)
		} else if (G_COMBINE == C_MEDIAN && !DOWTS) {
		    call g_usigmai(data, Memi[id], Memi[n], npts, 
			    Memr[outdata], Memr[tbuf], szuw, nm)
		}
	    }

	    if (DOREJ)
	        call outrej (rej, Memi[rejdata], Memi[n], Memi[id], 
                             npts, nimages, Meml[v2])

	    call amovl (Meml[v1], Meml[v2], IM_MAXDIM)
	}

	do i = 1, nimages
	    call mfree (Memi[id+i-1], TY_INT)

	call sfree (sp)

end

procedure gcombiner (in, msk, err, rej, nimages, data, mskdata, errdata,
                      npts, out, szuw, nm)

pointer	in[nimages]		# Input images
pointer	msk[nimages]		# Input DQF maps
pointer	err[nimages]		# Input ERROR maps
pointer	rej[nimages]		# Output rejection maps
pointer	data[nimages]		# Input image data buffers
pointer	mskdata[nimages]	# Input DQF map data buffers
pointer	errdata[nimages]	# Input ERROR map data buffers
pointer	out[3]			# Output image, DQF and sigma map
int	nimages			# Number of input images
int	npts			# Number of points per output line
pointer	szuw			# Pointer to Scales structure
pointer	nm			# Pointer to noise model structure

pointer	id			# IDs
pointer	n			# Number of good pixels

int	i
pointer	sp, v1, v2, v3, outdata, rejdata, ibuf, tbuf, impnli()
pointer	impnlr()

errchk	g_scale, g_getdatar

include	"../gcombine.com"

begin
	call smark (sp)
	call salloc (id, nimages, TY_POINTER)
	call salloc (rejdata, nimages, TY_POINTER)
	call salloc (n, npts, TY_INT)
	call salloc (v1, IM_MAXDIM, TY_LONG)
	call salloc (v2, IM_MAXDIM, TY_LONG)
	call salloc (v3, IM_MAXDIM, TY_LONG)
	call amovkl (long(1), Meml[v1], IM_MAXDIM)
	call amovkl (long(1), Meml[v2], IM_MAXDIM)
	call amovkl (long(1), Meml[v3], IM_MAXDIM)

	# Get scaling, zeroing and uniform weighting factors
	# "DOSCALE" is also defined here. "DOWTS" may change here.

	call g_scale (in, msk, err, out, nimages, szuw, nm)

	do i = 1, nimages		# pg: alloc here, not g_getdata$t!
	    call malloc(Memi[id+i-1], npts, TY_INT)

	while (impnlr (out[1], outdata, Meml[v1]) != EOF) {

	    # "DOTHRESH" is set in the top procedure

	    call g_getdatar (in, msk, err, data, mskdata,
	    	errdata, Memi[n], Memi[id], nimages, npts, szuw, 
		Meml[v2], Meml[v3])

	    switch (G_REJECT) {
	    case CCDCLIP, CCDCRREJ:
		if (MCLIP)
		    call g_mccdclipr (data, Memi[id], nimages, 
			Memi[n], npts, Memr[outdata], szuw, nm)
		else
		    call g_accdclipr (data, Memi[id], nimages, 
			Memi[n], npts, Memr[outdata], szuw, nm)
	    case MINMAX:
		call g_mmr (data, Memi[id], nimages, Memi[n], npts)
	    case RSIGCLIP, RSIGCRREJ:
		if (MCLIP)
		    call g_mrsigclipr (data, Memi[id], nimages, 
			Memi[n], npts, Memr[outdata], szuw)
		else
		    call g_arsigclipr (data, Memi[id], nimages, 
			Memi[n], npts, Memr[outdata], szuw)
	    case AVSIGCLIP, AVSIGCRREJ:
		if (MCLIP)
		    call g_mavsigclipr (data, Memi[id], nimages, 
			Memi[n], npts, Memr[outdata], szuw)
		else
		    call g_aavsigclipr (data, Memi[id], nimages, 
			Memi[n], npts, Memr[outdata], szuw)
	    case ERRCLIP, ERRCRREJ:
		if (MCLIP)
		    call g_merrclipr (data, Memi[id], errdata, nimages, 
			Memi[n], npts, Memr[outdata], szuw)
		else
		    call g_aerrclipr (data, Memi[id], errdata, nimages, 
			Memi[n], npts, Memr[outdata], szuw)
	    }

#	    if (grow > 0)
#		call ic_grow$t (d, id, n, nimages, npts, Mem$t[outdata])

	    if (DOCOMBINE) {
	    	switch (G_COMBINE) {
	    	case C_AVERAGE:
		    if (G_WEIGHT == W_UNIFORM || G_WEIGHT == W_NONE) 
		        call g_uaverager (data, Memi[id], 
			    Memi[n], npts, Memr[outdata], szuw)
		    if (G_WEIGHT == W_PIXWISE) 
		    	call g_paverager (data, Memi[id], 
			    errdata, Memi[n], npts, Memr[outdata], szuw)
	    	case C_MEDIAN:
	    	    call g_medianr (data, Memi[id], nimages, Memi[n],
			npts, Memr[outdata])
		}
	    }

	    if (out[2] != NULL) {
		call amovl (Meml[v2], Meml[v1], IM_MAXDIM)
		i = impnli (out[2], ibuf, Meml[v1])
		call amovki (nimages, Memi[ibuf], npts)
		call asubi (Memi[ibuf], Memi[n], Memi[ibuf], npts)
	    }
		    
	    if (out[3] != NULL) {
		call amovl (Meml[v2], Meml[v1], IM_MAXDIM)
		i = impnlr (out[3], tbuf, Meml[v1])
		if (G_COMBINE == C_AVERAGE) {
		    if (G_WEIGHT == W_PIXWISE)
		    	call g_psigmar(data, Memi[id], errdata, Memi[n],
			    npts, Memr[outdata], Memr[tbuf], szuw)
		    else 
		     	call g_usigmar(data, Memi[id], Memi[n], npts, 
			    Memr[outdata], Memr[tbuf], szuw, nm)
		} else if (G_COMBINE == C_MEDIAN && !DOWTS) {
		    call g_usigmar(data, Memi[id], Memi[n], npts, 
			    Memr[outdata], Memr[tbuf], szuw, nm)
		}


	    }

	    if (DOREJ)
	        call outrej (rej, Memi[rejdata], Memi[n], Memi[id], 
                             npts, nimages, Meml[v2])

	    call amovl (Meml[v1], Meml[v2], IM_MAXDIM)
	}

	do i = 1, nimages
	    call mfree (Memi[id+i-1], TY_INT)

	call sfree (sp)

end

procedure gcombined (in, msk, err, rej, nimages, data, mskdata, errdata,
                      npts, out, szuw, nm)

pointer	in[nimages]		# Input images
pointer	msk[nimages]		# Input DQF maps
pointer	err[nimages]		# Input ERROR maps
pointer	rej[nimages]		# Output rejection maps
pointer	data[nimages]		# Input image data buffers
pointer	mskdata[nimages]	# Input DQF map data buffers
pointer	errdata[nimages]	# Input ERROR map data buffers
pointer	out[3]			# Output image, DQF and sigma map
int	nimages			# Number of input images
int	npts			# Number of points per output line
pointer	szuw			# Pointer to Scales structure
pointer	nm			# Pointer to noise model structure

pointer	id			# IDs
pointer	n			# Number of good pixels

int	i
pointer	sp, v1, v2, v3, outdata, rejdata, ibuf, tbuf, impnli()
pointer	impnld()

errchk	g_scale, g_getdatad

include	"../gcombine.com"

begin
	call smark (sp)
	call salloc (id, nimages, TY_POINTER)
	call salloc (rejdata, nimages, TY_POINTER)
	call salloc (n, npts, TY_INT)
	call salloc (v1, IM_MAXDIM, TY_LONG)
	call salloc (v2, IM_MAXDIM, TY_LONG)
	call salloc (v3, IM_MAXDIM, TY_LONG)
	call amovkl (long(1), Meml[v1], IM_MAXDIM)
	call amovkl (long(1), Meml[v2], IM_MAXDIM)
	call amovkl (long(1), Meml[v3], IM_MAXDIM)

	# Get scaling, zeroing and uniform weighting factors
	# "DOSCALE" is also defined here. "DOWTS" may change here.

	call g_scale (in, msk, err, out, nimages, szuw, nm)

	do i = 1, nimages		# pg: alloc here, not g_getdata$t!
	    call malloc(Memi[id+i-1], npts, TY_INT)

	while (impnld (out[1], outdata, Meml[v1]) != EOF) {

	    # "DOTHRESH" is set in the top procedure

	    call g_getdatad (in, msk, err, data, mskdata,
	    	errdata, Memi[n], Memi[id], nimages, npts, szuw, 
		Meml[v2], Meml[v3])

	    switch (G_REJECT) {
	    case CCDCLIP, CCDCRREJ:
		if (MCLIP)
		    call g_mccdclipd (data, Memi[id], nimages, 
			Memi[n], npts, Memd[outdata], szuw, nm)
		else
		    call g_accdclipd (data, Memi[id], nimages, 
			Memi[n], npts, Memd[outdata], szuw, nm)
	    case MINMAX:
		call g_mmd (data, Memi[id], nimages, Memi[n], npts)
	    case RSIGCLIP, RSIGCRREJ:
		if (MCLIP)
		    call g_mrsigclipd (data, Memi[id], nimages, 
			Memi[n], npts, Memd[outdata], szuw)
		else
		    call g_arsigclipd (data, Memi[id], nimages, 
			Memi[n], npts, Memd[outdata], szuw)
	    case AVSIGCLIP, AVSIGCRREJ:
		if (MCLIP)
		    call g_mavsigclipd (data, Memi[id], nimages, 
			Memi[n], npts, Memd[outdata], szuw)
		else
		    call g_aavsigclipd (data, Memi[id], nimages, 
			Memi[n], npts, Memd[outdata], szuw)
	    case ERRCLIP, ERRCRREJ:
		if (MCLIP)
		    call g_merrclipd (data, Memi[id], errdata, nimages, 
			Memi[n], npts, Memd[outdata], szuw)
		else
		    call g_aerrclipd (data, Memi[id], errdata, nimages, 
			Memi[n], npts, Memd[outdata], szuw)
	    }

#	    if (grow > 0)
#		call ic_grow$t (d, id, n, nimages, npts, Mem$t[outdata])

	    if (DOCOMBINE) {
	    	switch (G_COMBINE) {
	    	case C_AVERAGE:
		    if (G_WEIGHT == W_UNIFORM || G_WEIGHT == W_NONE) 
		        call g_uaveraged (data, Memi[id], 
			    Memi[n], npts, Memd[outdata], szuw)
		    if (G_WEIGHT == W_PIXWISE) 
		    	call g_paveraged (data, Memi[id], 
			    errdata, Memi[n], npts, Memd[outdata], szuw)
	    	case C_MEDIAN:
	    	    call g_mediand (data, Memi[id], nimages, Memi[n],
			npts, Memd[outdata])
		}
	    }

	    if (out[2] != NULL) {
		call amovl (Meml[v2], Meml[v1], IM_MAXDIM)
		i = impnli (out[2], ibuf, Meml[v1])
		call amovki (nimages, Memi[ibuf], npts)
		call asubi (Memi[ibuf], Memi[n], Memi[ibuf], npts)
	    }
		    
	    if (out[3] != NULL) {
		call amovl (Meml[v2], Meml[v1], IM_MAXDIM)
		i = impnld (out[3], tbuf, Meml[v1])
		if (G_COMBINE == C_AVERAGE) {
		    if (G_WEIGHT == W_PIXWISE)
		    	call g_psigmad(data, Memi[id], errdata, Memi[n],
			    npts, Memd[outdata], Memd[tbuf], szuw)
		    else 
		     	call g_usigmad(data, Memi[id], Memi[n], npts, 
			    Memd[outdata], Memd[tbuf], szuw, nm)
		} else if (G_COMBINE == C_MEDIAN && !DOWTS) {
		    call g_usigmad(data, Memi[id], Memi[n], npts, 
			    Memd[outdata], Memd[tbuf], szuw, nm)
		}


	    }

	    if (DOREJ)
	        call outrej (rej, Memi[rejdata], Memi[n], Memi[id], 
                             npts, nimages, Meml[v2])

	    call amovl (Meml[v1], Meml[v2], IM_MAXDIM)
	}

	do i = 1, nimages
	    call mfree (Memi[id+i-1], TY_INT)

	call sfree (sp)

end




# Create one line of the output rejection mask.
#
# I.Busko 04 Apr 97  Implemented

procedure outrej (rej, rejdata, n, id, npts, nimages, v1)

pointer	rej[nimages]		# Output rejection maps
pointer	rejdata[nimages]	# Pointers to output line buffers
int	n[npts]			# Number of good pixels
pointer	id[nimages]		# IDs
long	v1[IM_MAXDIM]		# IMIO index vector
int	npts, nimages
#-
pointer	sp, v2
int	i, j
int	impnli()

begin
# for debugging:
#	call printf ("Begin")
# 	do j = 1, npts {
# 	    call printf ("\npix: %d   n: %d   id: ")
# 	    call pargi (j)
# 	    call pargi (n[j])
#	    call flush (STDOUT)
# 	    do i = 1, nimages {
# 	        call printf ("%d  ")
# 	        call pargi (Memi[id[i]+j-1])
#	        call flush (STDOUT)
# 	    }
# 	}
#	call printf ("\nEnd\n")
#

	call smark (sp)
	call salloc (v2, IM_MAXDIM, TY_LONG)

	# Create output lines and fill them up with "all-thru" mask.
	do i = 1, nimages {
	    call amovl (v1, Meml[v2], IM_MAXDIM)
	    j = impnli (rej[i], rejdata[i], Meml[v2])
	    call amovki (32767, Memi[rejdata[i]], npts)
	}

	# Set mask to zero in rejected pixels, which are the ones
	# sitting at the (nimages - n) topmost addresses in the
	# result vector. The corresponding image indices where those
	# pixels come from are stored in the matching id vector.
	do j = 1, npts {
	    if (n[j] < nimages) {
	        do i = nimages, n[j]+1, -1 {
	            if ((id[i]) != NULL)
	                Memi[rejdata[Memi[id[i]+j-1]]+j-1] = 0
	        }
	    }
	}

	call sfree (sp)
end




