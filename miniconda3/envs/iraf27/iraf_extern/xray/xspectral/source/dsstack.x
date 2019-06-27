#$Header: /home/pros/xray/xspectral/source/RCS/dsstack.x,v 11.0 1997/11/06 16:42:01 prosb Exp $
#$Log: dsstack.x,v $
#Revision 11.0  1997/11/06 16:42:01  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:29:21  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:30:48  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:54:54  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:49:35  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:43:55  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  18:14:02  prosb
#General Release 2.0:  April 1992
#
#Revision 3.2  92/03/05  13:34:49  orszak
#jso - added background OAH for upgraded qpspec
#
#Revision 3.1  91/09/22  19:05:36  wendy
#Added
#
#Revision 3.0  91/08/02  01:58:02  prosb
#General Release 1.1
#
#Revision 2.2  91/07/12  15:55:20  prosb
#jso - made spectral.h system wide
#
#Revision 2.1  91/04/15  17:42:31  john
#Add a free of the Offaxis Histogram record to plug a memory leak.
#
#Revision 2.0  91/03/06  23:02:28  pros
#General Release 1.0
#
# Project:      PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
#
#  dsstack.x   ---   prepare stack of pointers to observed datasets
#

include  <ext.h>
include  <spectral.h>

#  parameter string definitions
define  OBS_DATA_DESCRIPTOR     "observed"

define	SZ_OBS		SZ_LINE

#
#	MAKE_OBSER_STACK -- make the observed data set stack
#
int  procedure  make_obser_stack( fp )

pointer fp				# i: frame pointer
char	obs[SZ_OBS]			# l: data set descriptor
int	status				# l: return from ons_parse
bool	strne()				# l: string compare
int	obs_parse()			# l: parse obs data set string

begin
	# reset the bin count
	FP_NBINS(fp) = 0
	# reset the number of channels to fit
	FP_CHANNELS(fp) = 0
	# reset the number of datas sets
	FP_DATASETS(fp) = 0

	# get the observed data set descriptor
	call clgstr(OBS_DATA_DESCRIPTOR, obs, SZ_OBS)
	# check for no data sets
	if( strne("", obs) ){	
	    # parse the data set descriptor and construct the ds records
	    status = obs_parse(obs, fp, 0)
	    if(status == NO)
		return(0)
	}

	# set current data set
	FP_CURDATASET(fp) = min( 1, FP_DATASETS(fp))
	return (FP_DATASETS(fp))
end

#
#  MAKE_PRED_STACK -- make the observed and predicted data set stack
#
procedure  make_pred_stack(fp, n)

pointer fp				# i: frame pointer
int	n				# i: predicted to open in each set

char	prdname[SZ_PATHNAME]		# l: predicted data set name
int	i				# l: number of data sets
pointer	dsname				# l: data set name
pointer	ds				# l: current data set
pointer	tp				# l: table pointer
pointer	cp				# l: column pointers
int	tbtacc()			# l: test for table existence

begin
	# try to read the predicted data files
	do i = 1, FP_DATASETS(fp)  {
	    dsname = DS_FILENAME(FP_OBSERSTACK(fp, i))
	    # get predicted file name from observed
	    call get_prdname(Memc[dsname], prdname, SZ_PATHNAME)
	    # see if the data set exists
	    if( tbtacc(prdname) == NO ){
		call printf("warning: predicted data set %s does not exist\n")
		call pargstr(prdname)
		next
	    }
	    # open the predicted data set
	    call ds_openpre(prdname, tp, cp, n)
	    # get the current predicted data set from the table
	    ds = FP_OBSERSTACK(fp,i)
	    call ds_getpre(tp, cp, ds)
	    # close the table file
	    call tbtclo(tp)
	    # free up allocated column space
	    call mfree(cp, TY_INT)	
	}
end

#
#  MAKE_DATA_STACK -- make the observed and predicted data set stack
#
int  procedure  make_data_stack( fp )

pointer fp				# i: frame pointer
int	got				# l: number of data sets
int	make_obser_stack()		# l: make observed stack

begin
	# first make the observed stack
	got = make_obser_stack(fp)
	# if we got observed, get the current predicted
	if( got >0 )
	    call make_pred_stack(fp, 0)
	return(got)
end

#
# RAZE_OBSER_STACK -- release space for all data sets
#
procedure raze_obser_stack(fp)

pointer	fp					# i: frame pointer
int	dataset					# l: data set number

begin
	if( FP_DATASETS(fp) > 0 )  {
	    do dataset = 1, FP_DATASETS(fp)
		call raze_ds (FP_OBSERSTACK(fp,dataset))
	}
end

#
# RAZE_DS -- release space for 1 data set
#
procedure  raze_ds ( ds )

pointer	 ds				# structure pointer

begin
	call mfree( DS_FILENAME(ds), TY_CHAR )
	call mfree( DS_LO_ENERGY(ds), TY_REAL )
	call mfree( DS_HI_ENERGY(ds), TY_REAL )
	call mfree( DS_OBS_DATA(ds), TY_REAL )
	call mfree( DS_OBS_ERROR(ds), TY_REAL )
	call mfree( DS_CHANNEL_FIT(ds), TY_INT )
	call mfree( DS_PRED_DATA(ds), TY_REAL )
	call mfree( DS_CHISQ_CONTRIB(ds), TY_REAL )
	call mfree( DS_SOURCE(ds), TY_REAL )
	call mfree( DS_BKGD(ds), TY_REAL )
	call mfree( DS_BAL_HISTGRAM(ds), TY_STRUCT)

	if ( DS_NOAH(ds) != 0 ) {
	    call mfree( DS_OAHPTR(ds), TY_REAL)
	    call mfree( DS_BK_OAHPTR(ds), TY_REAL)
	}

        call mfree( ds, TY_INT )
end

define  OUT_DIRECTORY 		"prd_dir"

#
#  GET_PRDNAME -- get predicted data set name from observed
#
procedure get_prdname(obsname, prdname, len)

char	obsname[ARB]			# i: observed data set name
char	prdname[ARB]			# o: predicted data set name
int	len				# i: length of output string

int	junk				# l: output from fnroot
char	odir[SZ_PATHNAME]		# l: output directory name
int	fnroot()			# l: get fila name root
int	strlen()			# l: string length

begin
	# get output directory name
	call clgstr(OUT_DIRECTORY, odir, SZ_PATHNAME)
	# start with user-specified directory path
	call strcpy(odir, prdname, SZ_PATHNAME)
	# add the file name part of the obs data set
	junk = fnroot(obsname, prdname[strlen(prdname)+1], SZ_PATHNAME)
	# change extension to prd
	call chngextname(prdname,  EXT_PRD, SZ_PATHNAME)
end
