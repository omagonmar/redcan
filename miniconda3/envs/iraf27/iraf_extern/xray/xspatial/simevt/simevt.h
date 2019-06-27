# $Header
# $Log
# Description : header file for simevt program
#

# QPINFO data structure.  Some useful information extracted from the reference
# QPOE as well as some definitions to pass around.

define SIM_QPLEN    18
define SIM_QPCENX   Memi[($1)]           # X center of field
define SIM_QPCENY   Memi[($1) + 2]       # Y center of field
define SIM_QPLL    Memi[($1) + 4]       # Lower limit for pixel values
define SIM_QPUL    Memi[($1) + 6]       # Upper limit for pixel values
define SIM_QPAPPX  Memr[($1) + 8]       # Number of arc seconds per pixel
define SIM_REFLVT  Memr[($1) + 10]      # LIVETIME from reference QP header
define SIM_QPLVT   Memr[($1) + 12]      # LIVETIME for simulated data
define SIM_TPTR    Memi[($1) + 14]      # Pointer to telescope string
define SIM_TEL     Memc[SIM_TPTR($1)]   # Name of telescope
define SIM_IPTR    Memi[($1) + 16]      # Pointer to instrument string
define SIM_INST    Memc[SIM_IPTR($1)]   # Name of instrument

define XLOC      1        # column numbers for source info table
define YLOC      2
define TYPE_LOC  3
define INT_LOC   4
define PRF_LOC   5
define PAR_LOC   6

# SRCINFO data structure.  Some useful information extracted from the input source
# table to pass around.

define LEN_SRC  20
define SRCNO    Memi[($1)]           # source number
define SRCX     Memi[($1) + 2]       # XPOS of source center
define SRCY     Memi[($1) + 4]       # YPOS of source center
define IPTR     Memi[($1) + 6]       # Pointer to string holding itype       
define ITYPE    Memc[IPTR($1)]       # dereference for IPTR
define INTENS   Memr[($1) + 8]       # source intensity
define PPTR     Memi[($1) + 10]      # Pointer to string holding prf_type
define PTYPE    Memc[PPTR($1)]       # dereference for PPTR
define PRFPAR   Memr[($1) + 12]      # prf parameter, either oaa or sigma
define SRCTYPE  Memi[($1) + 14]      # code of source type
define SRCPAR   Memr[($1) + 16]      # final value of prf parameter
define SRCCTS   Memi[($1) + 18]      # number of source counts to generate

define HRI_LL   2048      # smallest allowed pixel value for HRI event
define HRI_UL   6144      # largest allowed pixel value for HRI event
define HRI_CENX 4096      # center value
define HRI_CENY 4096      # center value

define MAX_RT  5000d0     # Used by the dzbrent routine.  Value supplied
                          # by FAP

define HRI_PRF   1        # code to use the HRI PRF when generating counts
define GAUSS_PRF 2        # code to use the GAUSS PRF 
define RAN_BKGD  5        # code to indicate bkgd counts
