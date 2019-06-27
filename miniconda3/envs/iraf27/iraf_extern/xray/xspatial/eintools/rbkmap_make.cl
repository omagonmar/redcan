# $Header: /home/pros/xray/xspatial/eintools/RCS/rbkmap_make.cl,v 11.0 1997/11/06 16:31:16 prosb Exp $
# $Log: rbkmap_make.cl,v $
# Revision 11.0  1997/11/06 16:31:16  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:47:55  prosb
# General Release 2.4
#
#Revision 1.3  1994/07/07  11:46:23  dvs
#Fixed broken check-in.  (It mistakenly added "semicolons" as comments.)
#
#
#--------------------------------------------------------------------------
# Module:       rbkmap_make.cl
# Project:      PROS -- EINSTEIN CDROM
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1994.  You may do anything you like with this
#               file except remove this copyright.
# Modified:     {0} David Van Stone -- 4/94 -- initial version 
#               {n} <who> -- <when> -- <does what>
#--------------------------------------------------------------------------

#--------------------------------------------------------------------------
# Task:         rbkmap_make
#
# Purpose:      To create a rotated background map for an Einstein QPOE file
#
# Automatic parameters:
#               qpoefile        input QPOE file
#		rbkmap		output rotated bkgd map
#		pi_band		PI band requested
#		srcfile		table of sources in QPOE [or NONE]
#		src_cnts	number of counts in source [if srcfile=NONE]
#               expfile         exposure file [if srcfile != NONE]
#		defmaps		Using default maps? [if band=h/s/b]
#		bemap,dsmap	input BE & DS maps [if defmaps=no]
#
# Description:  This script is the main script in eintools which calls just
#		about every other task within the eintools package.  Its
#		main goal is to produce a rotated background map for
#		an input QPOE file for the specified PI band.
#
#		Thus user must either specify a file of sources OR a
#		total number of counts in the QPOE due to the sources.
#		(The user should be careful to use the same PI band,
#		filters, and bright edge filter when calculating the
#		source counts.)  
#
#		If the user specifies a source file, this task will make
#		an exposure mask for the QPOE (which is needed to run
#		the task src_cnts).  If an exposure mask already exists
#		with the same name as the one in the hidden parameter,
#		this task will use that file and not overwrite it.
#		Otherwise it will call exp_make to create an exposure
#		mask.  The task will then call src_cnts to calculate
#		the number of counts due to sources.
#
#		(In this case, the parameter "src_cnts" is set to be
#		the number of source counts.  Thus the user could
#		re-run this task with srcfile=NONE and have this
#		parameter already set.)
#
#		If the user entered one of "soft", "hard", or "broad"
#		(or the equivalent ranges: "2:4", "5:10", "2:10"), then
#		the user will be asked if she/he wishes to use the 
#		default bright Earth and deep survey maps.  If not,
#		the user will be prompted for their BE & DS maps.
#
#		This task then calls bkfac_make, calc_factors, and
#		finally be_ds_rotate to produce the final maps.
#

# Note:         Because the constant aspect table and the background
#		factors table are intermediate files, we allow them
#		to be clobbered EVEN IF "clobber" is set to "no".
#
#               The parameter file is separate and in the same format
#               as the SPP tasks -- this makes them easier to update.
#--------------------------------------------------------------------------


procedure rbkmap_make (qpoefile,rbkmap,pi_band,srcfile,src_cnts,expfile,
			defmaps,bemap,dsmap)

### PARAMETERS ###

# automatic parameters
file	qpoefile	# i: input QPOE file
file	rbkmap		# i: output rotated bkgd map file name
string	pi_band		# i: PI band requested
file	srcfile		# i: table of sources in QPOE [or NONE]
real	src_cnts	# i: number of counts in source [if srcfile=NONE]
file	expfile		# i: exposure file [if srcfile != NONE]
bool	defmaps		# i: Using default maps? [if band=h/s/b]
file	bemap,dsmap	# i: input BE & DS maps [if defmaps=no]

# parameters for bkfac_make
file	bkfac_tab	# i: name of intermediate BKFAC table
string	br_edge_filt	# i: filter to use to remove bright edge from QPOE
string	gti_ext		# i: name of GTI extension ['' for default]
string	obi_name	# i: name of OBI column in GTI extension
bool	use_obi		# i: Should we average aspects in OBIs?
real	max_off_diff	# i: maximum differences for aspect groups
real	dist_to_edge	# i: pixels to edge of field

# parameters for calc_factors
string	br_edge_reg	# i: region to use on blocked images to
			#	remove bright edge
real	min_grp_time	# i: min. group time for using group counts
	
# parameters for exp_make
file	catfile		# i: intermediate constant aspect table
bool    full_exp        # i: should we create full exposure?
real    aspx_res        # i: aspect X resolution (in pix) 
real    aspy_res        # i: aspect Y resolution (in pix)
real    aspr_res        # i: aspect roll resolution (in radians)
int     cell_size       # i: exposure cell size
int     exp_max         # i: (for PL files) integer max
string  geom_bounds     # i: name of IPC geometry file

# parameters for src_cnts
real	src_rad		# i: source radius for calculating source counts
real	bkgd_ann_in	# i: inner radius of bkgd annulus
real	bkgd_ann_out	# i: outer radius of bkgd annulus
real	soft_cmsc	# i: circle mirror scat. corr. for soft band
real	soft_cprc	# i: circle point resp. corr. for soft band
real	hard_cmsc	# i: circle mirror scat. corr. for hard band
real	hard_cprc	# i: circle point resp. corr. for hard band

# parameters for be_ds_rotate
real	xscale		# i: final X-scaling
real	yscale		# i: final Y-scaling

# parameters for rotating/scaling
real	xsample		# i: coordinate surface subsampling factor - x
real	ysample		# i: coordinate surface subsampling factor - y
string	interpolant	# i: type of interpolation to use
string	boundary	# i: which boundary condition?
real	constant	# i: value of constant for boundary extension
int	nxblock		# i: size of blocks to do rot/scaling in - x
int	nyblock		# i: size of blocks to do rot/scaling in - y

# other hidden parameters
bool    clobber         # i: display level
int     display         # i: overwrite output file?

begin

### LOCAL VARS ###

	file	c_qpoefile	# local copy of: qpoefile 
	file	c_rbkmap	#		 rbkmap
	string	c_pi_band	#		 pi_band
	file	c_srcfile	#		 srcfile
	real	c_src_cnts	#		 src_cnts
	file	c_expfile	#		 expfile
	bool	c_defmaps	#		 defmaps
	file	c_bemap		#		 bemap
	file	c_dsmap		#		 dsmap

	file 	e_qpoefile	# expanded QPOE file name
	file	e_expfile	# expanded exposure file name
	file	e_catfile	# expanded CAT file
	file 	e_bkfac_tab	# expanded BKFAC table
	file	e_rbkmap	# expanded rot. bkgd map name
	string  pi_range	# PI range requested

        #----------------------------------------------
        # prompt for qpoe, rbkmap, PI-band, srcfile.
        #----------------------------------------------
        c_qpoefile = qpoefile
        c_rbkmap   = rbkmap
	c_pi_band = pi_band
	c_srcfile  = srcfile

        #----------------------------------------------
	# prompt for src_cnts OR expfile, depending
	# on whether or not the user has a srcfile.
        #----------------------------------------------
	if (c_srcfile=="NONE")
	{
	    c_src_cnts = src_cnts
	}
	else
	{
	    c_expfile  = expfile
	}

        #----------------------------------------------
	# Calculate PI range.
        #----------------------------------------------
	_band2range(c_pi_band)
	 pi_range=_band2range.range

        #----------------------------------------------
	# Only prompt for defmaps if Range is s/h/b.
        #----------------------------------------------
	if ((pi_range=="2:4") || (pi_range=="5:10") || (pi_range=="2:10"))
	{
	   c_defmaps  = defmaps	
	}
	else
	{
	   c_defmaps=no
	}

        #----------------------------------------------
	# Fill in c_bemap, c_dsmap either by prompting
	# user or by reading default values.
        #----------------------------------------------
	if (!c_defmaps)
	{
	   c_bemap    = bemap
	   c_dsmap    = dsmap
	} 
	else if(pi_range=="2:4")
	{
	   c_bemap=def_be_soft
	   c_dsmap=def_ds_soft
	}  
	else if (pi_range=="5:10")
	{
	   c_bemap=def_be_hard
	   c_dsmap=def_ds_hard
	}
	else
	{
	   c_bemap=def_be_broad
	   c_dsmap=def_ds_broad
	}

	if (c_defmaps && display>0)
	{
	   print("")
	   print("Using bright Earth map "//c_bemap//" and deep survey map")
	   print (c_dsmap//".")
	}

        #-------------------------------------------------
	# Create expanded file names by adding extensions
        #-------------------------------------------------
        _rtname ( c_qpoefile, c_qpoefile, ".qp" )
         e_qpoefile = s1
	if (c_srcfile!="NONE")
	{
            _rtname ( c_qpoefile, c_expfile, "_exp.pl" )
             e_expfile = s1
	}
        _rtname ( c_qpoefile, catfile, "_cat.tab" )
         e_catfile = s1
        _rtname ( c_qpoefile, bkfac_tab, "_bkfac.tab" )
         e_bkfac_tab = s1
        _rtname ( c_qpoefile, c_rbkmap, "_bkg.imh" )
         e_rbkmap = s1
	_rtname ( c_bemap, c_bemap, ".imh")
	 c_bemap=s1
	_rtname ( c_dsmap, c_dsmap, ".imh")
	 c_dsmap=s1


        #----------------------------------------------
	# check that be/ds maps exist
        #----------------------------------------------
	if (!access(c_bemap))
	{
	   error(1,"Can not find input bright Earth map.")
	}
	if (!access(c_dsmap))
	{
	   error(1,"Can not find input deep survey map.")
	}

        #----------------------------------------------
	# check if we need to make src_cnts.
        #----------------------------------------------
	if (c_srcfile=="NONE")
	{
	    if (c_src_cnts<0.0)
	    {
		error(1,"Input source counts must not be negative.")
	    }

	    if (display>0)
	    {
		print ("")
		print ("We will be calculating the background map using the input value")
		print ("for the source counts: "//c_src_cnts//".")
	    }
	}
	else  # we need to calculate the source counts!
	{
            #----------------------------------------------
	    # Check if exposure file exists.  If so, we
	    # can simply use this exposure file.
            #----------------------------------------------
	    if (access(e_expfile))
	    {
		if (display>0)
		{
		    print ("")
		    print("Using exposure map "//e_expfile//".")
		}
	    }
	    else
	    {
		if (display>0)
		{
		    print ("")
		    print("Creating exposure map "//e_expfile//" for QPOE file "//e_qpoefile//"...")
		}

                #----------------------------------------------
		# Run exp_make.
		# (note: clobber=no, since we already checked 
		#  if the exp file existed.)
                #----------------------------------------------
		exp_make (e_qpoefile,e_expfile,
			catfile=e_catfile, full_exp=full_exp,
			aspx_res=aspx_res, aspy_res=aspy_res, 
			aspr_res=aspr_res, cell_size=cell_size, 
			exp_max=exp_max,geom_bounds=geom_bounds,clobber=no,
			display=display)
	    }

	    if (display>0)
	    {
		print ("")
		print("Calculating source counts...")
	    }

            #----------------------------------------------
	    # Run src_cnts to find number of source cnts.
            #----------------------------------------------
	    src_cnts (e_qpoefile,c_srcfile,e_expfile,pi_range,
		  br_edge_filt=br_edge_filt, src_rad=src_rad, 
		  bkgd_ann_in=bkgd_ann_in, bkgd_ann_out=bkgd_ann_out, 
		  soft_cmsc=soft_cmsc, soft_cprc=soft_cprc,
		  hard_cmsc=hard_cmsc, hard_cprc=hard_cprc, display=display)
	    c_src_cnts=src_cnts.src_cts

            #----------------------------------------------
	    # Set input parameter "src_cnts" to equal the
	    # number of counts.  This will allow the user
	    # to not have to calculate source counts each
	    # time if they are using the same input params.
            #----------------------------------------------
	    src_cnts=c_src_cnts
	}

        #----------------------------------------------
	# Run bkfac_make.  Note: we are allowed to 
	# overwrite the intermediate bkfac table, so
	# clobber is set to yes.
        #----------------------------------------------
	bkfac_make (e_qpoefile,e_bkfac_tab,pi_range,
		use_obi=use_obi, gti_ext=gti_ext, obi_name=obi_name,
		br_edge_filt=br_edge_filt, max_off_diff=max_off_diff, 
		dist_to_edge=dist_to_edge,clobber=yes, display=display)
	
        #----------------------------------------------
	# Run calc_factors.
        #----------------------------------------------

	calc_factors (e_qpoefile,e_bkfac_tab,pi_range,c_src_cnts,no,
		c_bemap,c_dsmap,br_edge_reg=br_edge_reg,
		br_edge_filt=br_edge_filt, min_grp_time=min_grp_time,
		display=display)

	if (display>0)
	{
	    print("")
	    print("Creating final background map...")
	}

        #----------------------------------------------
	# Run be_ds_rotate.
        #----------------------------------------------
	be_ds_rotate(e_qpoefile,e_bkfac_tab,e_rbkmap,  
		pi_band=pi_range,original_data=no,defmaps=no,
		bemap=c_bemap,dsmap=c_dsmap,xscale=xscale,yscale=yscale,
		br_edge_reg=br_edge_reg,xsample=xsample, ysample=ysample,
		interpolant=interpolant, boundary=boundary, 
		constant=constant, nxblock=nxblock, nyblock=nyblock, 
		clobber=clobber, display=display)
end
