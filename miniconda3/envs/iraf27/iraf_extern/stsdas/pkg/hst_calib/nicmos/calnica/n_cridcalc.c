# include <math.h>
# include <stdio.h>
# include <stdlib.h>
# include <hstio.h>     /* defines HST I/O functions */
# include "calnic.h"	/* defines NICMOS data structures */
# include "calnica.h"	/* defines CALNICA data structures */
# define THRESH 4.0		/* default sigma threshold for rejection */
# define DEBUG          0
# define X1		167
# define Y1		119
# define X2		1       /* not used*/
# define Y2		1       /*not used*/
# define max_CRs         3
# define equal_weight    0
# define optimum_weight  1
# define clean_up        1
# define calculate       0
# define DQIGNORE        SATURATED
/* N_CRIDCALC: Identify cosmic ray hits in NICMOS images. This routine
/* N_SCRID: Identify cosmic ray hits in single NICMOS images.
/* N_MCRID: Identify cosmic ray hits in a stack of MultiACCUM samples.
/* FITSAMPS: Fit accumulating counts vs. time to compute mean countrate,
/* LINFIT: Compute a linear fit of the form y = a + bx to a set of
/* REJSPIKES: Find and flag electronic noise spikes. These show up as
/* REJFIRSTREAD: Check for spikes in the first read of the interval only.
/* first read of interval is not flagged already */
/* REJCRS: Find and flag a Cosmic Ray hits. This is done by looking for
/* This subroutine determines the linear dark current and amp glow components
/* This subroutine is used to estimate the dark and glow component of the

###  Proprietary source code removed  ###
