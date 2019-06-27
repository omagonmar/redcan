/* 	Copyright restrictions apply - see stsdas$copyright.stsdas 
# include <stdio.h>
# include <stdlib.h>
# include "estreak.h"
# define  ITER	 2
# define  NSIGMA 2.
/*  G_MEDIAN:  Scale the individual flats and compute their median.
/*  Parameters:
/*  Local variables                                                       */
/*  Function declarations                                                 */
/* Step 1: Compute average of input arrays. Result is stored in median array.*/
/*  Step 2: Compute mean ratio for each image, with sigma-clipping. */
/*  Step 3: Determine the median value for each pixel. This is the most
/* THIS NOT-SO-RIGOROUS MEDIAN COMPUTATION IS LEFT IN PLACE FOR
/*	            if (((int)fmod((double)n,2.0)) || (n > 15))
/*	            else {

###  Proprietary source code removed  ###
