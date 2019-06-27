#$Header: /home/pros/xray/xspatial/imcnts/RCS/imcntsubs.x,v 11.0 1997/11/06 16:32:50 prosb Exp $
#$Log: imcntsubs.x,v $
#Revision 11.0  1997/11/06 16:32:50  prosb
#General Release 2.5
#
#Revision 9.1  1997/05/09 18:04:42  prosb
#JCC(11/17/96)- Updated to display the count as double when it
#               exceeds the MAX_INT limit.
#
#Revision 9.0  95/11/16  18:52:13  prosb
#General Release 2.4
#
#Revision 8.1  1994/08/12  14:24:48  janet
#jd - debugging gt problem - no real change made, only added a pair of parens.
#
#Revision 8.0  94/06/27  15:14:48  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:35:46  prosb
#General Release 2.3
#
#Revision 6.3  93/12/03  01:05:58  dennis
#Added poisserr, to select Poisson or Gaussian error estimation from data.
#
#Revision 6.2  93/10/15  23:48:52  dennis
#Changed computation of estimated errors, to use one_sigma().
#
#Revision 6.1  93/07/16  21:45:13  dennis
#In cnt_bstype(), corrected error of taking background file name that 
#begins with a number, as a constant value.
#
#Revision 6.0  93/05/24  16:20:19  prosb
#General Release 2.2
#
#Revision 5.2  93/04/30  03:20:04  dennis
#Moved writing newline at end of column headings line out of conditional 
#statement in cnt_finaldisp(). preventing run-on line.
#
#Revision 5.1  93/04/27  00:18:53  dennis
#Regions system rewrite.
#
#Revision 5.0  92/10/29  21:34:04  prosb
#General Release 2.1
#
#Revision 4.4  92/09/08  21:18:21  dennis
#In cnt_filltable(), skip over the first smin - 1 notes strings, to put 
#the correct strings in the rows of the table.
#
#Revision 4.3  92/09/04  17:06:41  mo
#MC	9/4/92		Replaced ctod to new ck_dval
#
#Revision 4.2  92/08/07  18:04:32  dennis
#New dependency on <regparse.h>:
#        Correct buffer sizes for bkgd, bkgdregion;
#        Replace literal 70 with SZ_NOTELINE;
#Change nullstr from static array to dynamically allocated.
#
#Revision 4.1  92/07/07  23:47:52  dennis
#Added minimum region number as parameter to cnt_rawdisp(), cnt_finaldisp(),
#cnt_filltable(), and cnt_profile(), to get the correct region numbers and 
#parameters (radii and angles) when the minimum region number in a mask is 
#not 1.
#Changed type of "indices" from long to int, for consistency, in 
#cnt_finaldisp(), cnt_profile(), and cnt_brightness().
#
#Revision 4.0  92/04/27  14:41:20  prosb
#General Release 2.0:  April 1992
#
#Revision 3.2  92/04/04  01:14:52  dennis
#According to matchbkgd, if same number of background regions as source 
#regions then match them one-to-one instead of averaging background.
#
#Revision 3.1  92/04/04  01:13:45  dennis
#(MC) Use dynamic or static EXPTIME, and tell which
#
#Revision 3.0  91/08/02  01:27:26  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:12:45  pros
#General Release 1.0
#
# Module:       IMCNTSUBS
# Project:      PROS -- ROSAT RSDC
# Purpose:      Subroutines to support counting photons in regions
# External:     < routines which can be called by applications>
# Local:        < routines which are NOT intended to be called by applications>
# Description:  < opt, if sophisticated family>
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} EGM -- initial version <when>    
#               {1} MC  -- Update comments  -- 2/91
#               {n} <who> -- <does what> -- <when>
#

include <ctype.h>
include <fset.h>
include <pmset.h>
include <mach.h>

include <qpoe.h>
include <plhead.h>
include	<regparse.h>
include "imcnts.h"

#
# CNT_BSTYPE -- get relationship between bkgd and source
#
procedure cnt_bstype(source, region, bkgd, bkgdregion, bkgdvalue, type)

char	source[ARB]		# source file name
char	region[ARB]		# source region descr
char	bkgd[ARB]		# bkgd file name
char	bkgdregion[ARB]		# bkgd region descr
double	bkgdvalue		# bkgd value - counts/pixel
int	type			# type of source/bkgd relation - see above
int	ip			# pointer into string for ctod
bool	bjunk			# unneeded bool return value
pointer	sp			# stack pointer
pointer nullstr			# null string
int	sz_nullstr		# length of nullstr
int	imaccess()
bool	ck_dval()
bool	streq()			# string comparison for equal
bool	strne()			# string comparison for not equal

begin
	# mark the stack
	call smark(sp)

	# set up null string
	sz_nullstr = max(SZ_PATHNAME, SZ_REGINPUTLINE)
	call salloc(nullstr, sz_nullstr, TY_CHAR)
	call strcpy("", Memc[nullstr], sz_nullstr)

	# check for null strings in the bkgd specifications
	if( streq(bkgd, Memc[nullstr]) )
	    call strcpy(source, bkgd, SZ_PATHNAME)
	if( streq(bkgdregion, Memc[nullstr]) )
	    call strcpy(region, bkgdregion, SZ_REGINPUTLINE)

	# check for background file
	if (imaccess(bkgd, READ_ONLY)== YES) {
	    bkgdvalue = -1.0
	} else {
	    call strcpy(Memc[nullstr], bkgd, SZ_PATHNAME)
	    call strcpy(Memc[nullstr], bkgdregion, SZ_REGINPUTLINE)
	    ip = 1
	    bjunk = ck_dval(bkgd, ip, bkgdvalue)
	    type = CONSTANT_BKGD
	    return
	}

	# now get the type
	if( streq(source, Memc[nullstr]) )
	    type = NO_SOURCE
	else if( streq(source, bkgd) && streq(region, bkgdregion) )
	    type = SAME_SAME
	else if( streq(source, bkgd) && strne(region, bkgdregion) )
	    type = SAME_OTHER
	else if( strne(source, bkgd) && streq(region, bkgdregion) )
	    type = OTHER_SAME
	else if( strne(source, bkgd) && strne(region, bkgdregion) )
	    type = OTHER_OTHER

	# free the stack
	call sfree(sp)
end

#
# CNT_INITABLE -- open the table file and create column headers
#
procedure cnt_initable(table, tp, cp, type, bkgdvalue, doberr, nflag)

char	table[ARB]		# i: table name
pointer tp			# i: table pointer
pointer	cp[ARB]			# i: column pointers
int	type			# i: type of source/bkgd relationship
double	bkgdvalue 		# i: constant bkgd/sq pixel
int	doberr			# i: add bkgd to error calculation?
int	nflag			# i: 0: no pie, no annulus in descriptor tree;
				#    PIEFLAG: pie, no annulus in descriptor;
				#    ANNFLAG: annulus, no pie in descriptor;
				#    or(PIEFLAG,ANNFLAG): both pie & annulus 
				#    	in descriptor tree

pointer tbtopn()		# l: table I/O routines

begin
	# Open a new table	
	tp = tbtopn(table, NEW_FILE, 0)

	# Define columns
	call tbcdef(tp, REGIONS_CP[cp], "region", "", "%-5d", TY_INT, 1, 1)
	call tbcdef(tp, SIGNAL_CP[cp], "raw", "", "%-6d", TY_INT, 1, 1)
	call tbcdef(tp, PIXELS_CP[cp], "pixels", "", "%-7d", TY_INT, 1, 1)
	call tbcdef(tp, BKGD_CP[cp], "bkgd", "", "%-9.2f", TY_REAL, 1, 1)
	if( doberr == YES )
	    call tbcdef(tp, BERROR_CP[cp], "bkgderr", "", "%-9.4f",TY_REAL,1,1)
	call tbcdef(tp, SOURCE_CP[cp], "net", "", "%-9.2f", TY_REAL, 1, 1)
	call tbcdef(tp, ERROR_CP[cp],  "neterr", "", "%-9.4f", TY_REAL, 1, 1)
	call tbcdef(tp, CTSPIXEL_CP[cp], "cnt/pix", "", "%-9.4f", TY_REAL, 1,1)
	call tbcdef(tp, ERRPIXEL_CP[cp], "err/pix", "", "%-9.4f", TY_REAL, 1,1)

	# If annulus/annuli in descriptor, add columns for profile and radii
	if( and(nflag, ANNFLAG) == ANNFLAG )  {
	    call tbcdef(tp,PROFILE_CP[cp],"profile","", "%-9.4f", TY_REAL, 1,1)
	    call tbcdef(tp, RAD1_CP[cp], "rad1", "", "%-9.2f", TY_REAL, 1,1)
	    call tbcdef(tp, RAD2_CP[cp], "rad2", "", "%-9.2f", TY_REAL, 1,1)
	}
	# If pie/pies in descriptor, add columns for angles
	if( and(nflag, PIEFLAG) == PIEFLAG )  {
	    call tbcdef(tp, ANG1_CP[cp], "ang1", "", "%-9.2f", TY_REAL, 1,1)
	    call tbcdef(tp, ANG2_CP[cp], "ang2", "", "%-9.2f", TY_REAL, 1,1)
	}
	# 1-region descriptor string column
        call tbcdef(tp, NSTRING_CP[cp],  "Region_string", "", "%s",
							-SZ_ONEREGDESC, 1, 1)

	# Now actually create it
	call tbtcre(tp)
end

#
# CNT_RAWDISP -- display the counts and area of the separate regions
#

procedure cnt_rawdisp(title, counts, area, minindex, indices)

char	title[ARB]		# i: title
double	counts[ARB]		# i: buffer for counts
double	area[ARB]		# i: buffer for area
int	minindex		# i: minimum region number
int	indices			# i: number of separate regions
int	i			# l: loop counter

begin
	# display title
	call printf("\n%s:\n")
	call pargstr(title)
	call printf("REGION\t\tCOUNTS\t\tPIXELS\t\t\n")

# JCC (11/17/96) - Updated to display the count as double when 
#                  it exceeds the MAX_INT limit.
	# display each count level and area
	for(i=1; i<=indices; i=i+1){
          if ( counts[i] < MAX_INT )      # jcc - add
	  {  call printf("%-10d\t%-10d\t%-10d\n")
	     call pargi(minindex - 1 + i)
	     call pargi(int(counts[i]))
	     call pargi(int(area[i]))
          }
          else                            # jcc - add
          {  call printf("%-10d\t%-10f\t%-10d\n")
             call pargi(minindex - 1 + i)
             call pargd(counts[i])
             call pargi(int(area[i]))
          }
	}
end

#
# CNT_WRBKGD -- write the raw bkgd counts and area into the table
#
procedure cnt_wrbkgd(tp, counts, area, indices)

pointer tp			# i: table pointer
double	counts[ARB]		# i: buffer for counts
double	area[ARB]		# i: buffer for area
int	indices			# i: number of separate regions
int	i			# l: loop counter
pointer	cbuf			# l: pointer to count buffer
pointer	abuf			# l: pointer to area buffer
pointer	sp			# l: stack pointer
int	strlen()		# l: string length

begin
	# mark the stack
	call smark(sp)
	# allocate memory space
	call salloc(cbuf, SZ_LINE, TY_CHAR)
	call salloc(abuf, SZ_LINE, TY_CHAR)
	# zero them out
	Memc[cbuf] = EOS
	Memc[abuf] = EOS
	# create strings with the counts and area in them
	for(i=1; i<=indices; i=i+1){
	    call sprintf(Memc[cbuf+strlen(Memc[cbuf])], SZ_LINE, "%d ")
	    call pargi(int(counts[i]))
	    call sprintf(Memc[abuf+strlen(Memc[abuf])], SZ_LINE, "%d ")
	    call pargi(int(area[i]))
	}
	# write the params to the table
	call tbhadt(tp, "bkgd_cnts", Memc[cbuf])
	call tbhadt(tp, "bkgd_area", Memc[abuf])
	# free the stack
	call sfree(sp)
end

#
# CNT_BKGDSUB -- normalize the background and subtract from source
#
procedure cnt_bkgdsub(type, matchbkgd, scounts, sarea, sindices, 
		bcounts, barea, bindices,
		bscounts, bsarea, bserrors, bncounts, bnerrors,
		serrors, berrors, poisserr, 
		bkgdvalue, bkgderr, normfactor, doberr, sdpp, bdpp)

int	type				# i/o: type of source/bkgd relation
bool	matchbkgd			# i: match bkgd, source regions
double	scounts[ARB]			# i: counts in source
double	sarea[ARB]			# i: area in source
int	sindices			# i: number of source regions
double	bcounts[ARB]			# i: counts in bkgd
double	barea[ARB]			# i: area in bkgd
int	bindices			# i: number of bkgd regions
double	bscounts[ARB]			# o: counts in bkgd-subtracted source
double	bsarea[ARB]			# o: area in bkgd-subtracted source
double	bserrors[ARB]			# o: error on bscounts
double	bncounts[ARB]			# o: counts in normalized bkgd
double	bnerrors[ARB]			# o: error on bncounts
pointer	berrors				# i: bkgd errors from external file
pointer	serrors				# i: source errors from external file
int	poisserr			# i: YES/NO:  Poisson/Gaussian errors 
					#     (if estimating errors from data)
double	bkgdvalue			# i: bkgd value, if there is one
double	bkgderr				# i: bkgd error, if there is one
double	normfactor			# i: constant normalization factor
int	doberr				# i: add bkgd to error calculation?
real	sdpp				# i: source deg/pixel
real	bdpp				# i: bkgd deg/pixel
int	i				# l: loop counter
double	area				# l: temp area
double	counts				# l: temp counts
double	errors				# l: sum of bkgd errors from file
real	temperr				# l: error estimated by one_sigma()
double	tempnorm			# l: temp normalization

begin
	if (matchbkgd && bindices == sindices) {
	    type = MATCHED
	}
	switch(type){
	case SAME_OTHER, OTHER_OTHER:
	    counts = 0.0D0
	    area = 0.0D0
	    errors = 0.0D0
	    # total up bkgd counts and area
	    for(i=1; i<=bindices; i=i+1){
	    	counts = counts + bcounts[i]
	    	area = area + barea[i]
		# sum up total error on external bkgd
		if( berrors != NULL )
		    if( Memd[berrors+i-1] < 0.0 )
			call error(1, 
				"bkgd error file contains negative values")
		    else
			errors = errors + Memd[berrors+i-1]
	    }
	    # check for null bkgd area
	    if( area == 0.0D0 )
		call error(1, "bkgd has zero area")
	    # subtract entire normalized background from each source region
	    for(i=1; i<=sindices; i=i+1){
		# norm has area, degrees/pixel and user norm as components
	    	tempnorm = (sarea[i]/area) * (sdpp/bdpp) * (sdpp/bdpp) *
			    normfactor
		# bkgd-subtracted area
	    	bsarea[i] = sarea[i]
		# normalized bkgd counts
		bncounts[i] = counts * tempnorm
		# bkgd-subtracted source counts
	    	bscounts[i] = scounts[i] - bncounts[i]
		# error on normalized bkgd
		if( doberr == YES ){
		    if( berrors == NULL ){
			# error on normalized bkgd counts from data
			if( counts < 0.0 )
			    bnerrors[i] = 0.0
			else {
			    call one_sigma(real(counts), 1, poisserr, temperr)
			    bnerrors[i] = temperr * tempnorm
			}
		    }
		    else{
			# error on normalized bkgd counts from external file
			bnerrors[i] = sqrt(errors) * tempnorm
		    }
		}
		else
		    bnerrors[i] = 0.0D0
		# error on bkgd-subtracted counts
		if( serrors == NULL ){
		    # error on bkgd-subtracted source counts from data
		    if( scounts[i] < 0.0 )
			bserrors[i] = 0.0
		    else {
			call one_sigma(real(scounts[i]), 1, poisserr, temperr)
		        bserrors[i] = 
			    sqrt(temperr * temperr + bnerrors[i] * bnerrors[i])
		    }
		}
		else{
		    if( Memd[serrors+i-1] < 0.0 )
			call error(1, 
				"src error file contains negative values")
		    # error on bkgd-subtracted source counts from external file
		    bserrors[i] = 
			    sqrt(Memd[serrors+i-1] + bnerrors[i] * bnerrors[i])
		}
	    }
	case OTHER_SAME, MATCHED:
	    # here the bkgd region is the same as or is matched to 
	    # the source region,
	    # except that the deg/pix might be different 
	    # Do the normalized bkgd subtraction
	    # in each of the individual corresponding areas.
	    for(i=1; i<=sindices; i=i+1){
		# norm has area, degrees/pixel and user norm as components
#	    	tempnorm = normfactor
	    	tempnorm = (sarea[i]/barea[i]) * (sdpp/bdpp) * (sdpp/bdpp) *
			    normfactor
		# bkgd counts (un-normalized)
	    	counts = bcounts[i]
		# bkgd-subtracted  area
	    	bsarea[i] = sarea[i]
		# normalized bkgd counts
		bncounts[i] = counts * tempnorm
		# bkgd-subtracted source counts
	    	bscounts[i] = scounts[i] - bncounts[i]
		# error on normalized bkgd
		if( doberr == YES ){
		    if( berrors == NULL ){
			# error on normalized bkgd counts from data
			if( counts < 0.0 )
			    bnerrors[i] = 0.0
			else {
			    call one_sigma (real(counts), 1, poisserr, temperr)
			    bnerrors[i] = temperr * tempnorm
			}
		    }
		    else{
			# error on normalized bkgd counts from external file
			if( Memd[berrors+i-1] < 0.0 )
			    call error(1, 
				"bkgd error file contains negative values")
			bnerrors[i] = sqrt(Memd[berrors+i-1]) * tempnorm
		    }
		}
		else
		    bnerrors[i] = 0.0D0
		# error on bkgd-subtracted counts
		if( serrors == NULL ){
		    # error on bkgd-subtracted source counts from data
		    if( scounts[i] < 0.0 )
			bserrors[i] = 0.0
		    else {
			call one_sigma(real(scounts[i]), 1, poisserr, temperr)
		        bserrors[i] = 
			    sqrt(temperr * temperr + bnerrors[i] * bnerrors[i])
		    }
		}
		else{
		    # error on bkgd-subtracted source counts from external file
		    if( Memd[serrors+i-1] < 0.0 )
			call error(1, 
				"src error file contains negative values")
	    	    bserrors[i] = 
			    sqrt(Memd[serrors+i-1] + bnerrors[i] * bnerrors[i])
		}
	    }
	case CONSTANT_BKGD:
	    # subtract constant background
	    for(i=1; i<=sindices; i=i+1){
	    	tempnorm = sarea[i] * normfactor
		# bkgd-subtracted area
	    	bsarea[i] = sarea[i]
		# normalized bkgd counts
		bncounts[i] = bkgdvalue * tempnorm
		# bkgd-subtracted source counts
	    	bscounts[i] = scounts[i] - bncounts[i]
		# error on normalized bkgd
		if( doberr == YES )
		    # error on constant bkgd
	 	    bnerrors[i] = bkgderr * tempnorm
		else
		    bnerrors[i] = 0.0D0
		# error on bkgd-subtracted counts
		if( serrors == NULL ){
		    # error on bkgd-subtracted source counts from data
		    if( scounts[i] < 0.0 )
			bserrors[i] = 0.0
		    else {
			call one_sigma(real(scounts[i]), 1, poisserr, temperr)
		        bserrors[i] = 
			    sqrt(temperr * temperr + bnerrors[i] * bnerrors[i])
		    }
		}
		else{
		    # error on bkgd-subtracted source counts from external file
		    if( Memd[serrors+i-1] < 0.0 )
			call error(1, 
				"src error file contains negative values")
	    	    bserrors[i] = 
			    sqrt(Memd[serrors+i-1] + bnerrors[i] * bnerrors[i])
		}
	    }
	default:
	    call error(1, "unknown source/bkgd type")	
	}
end

#
# CNT_FINALDISP -- display results: counts, area, errors, etc.
#
procedure cnt_finaldisp(counts, area, errors, bncounts, bnerrors,
				brightness, errness, profile, notes, 
				minindex, indices, nflag, doberr)

double	counts[ARB]		# i: buffer for counts
double	area[ARB]		# i: buffer for area
double	errors[ARB]		# i: error on counts
double	bncounts[ARB]		# i: buffer for bkgd counts
double	bnerrors[ARB]		# i: error on bkgd counts
double	brightness[ARB]		# i: counts/pixel
double	errness[ARB]		# i: error/pixel
double	profile[ARB]		# i: profile
pointer	notes			# i: pointer to linked list of notes
int	minindex		# i: minimum region number
int	indices			# i: number of separate regions
int	nflag			# i: 0: no pie, no annulus in descriptor tree;
				#    PIEFLAG: pie, no annulus in descriptor;
				#    ANNFLAG: annulus, no pie in descriptor;
				#    or(PIEFLAG,ANNFLAG): both pie & annulus 
				#    	in descriptor tree
int	doberr			# i: add bkgd to error calculation?

pointer	note			# l: pointer to current note structure
int	i			# l: loop counters, temp index

begin
	# Display title
	call printf("\nBKGD-SUBTRACTED DATA:\n")

	# Display column headings
	if( doberr == YES )
	    call printf("REG%3wCOUNTS%5wERROR%6wBKGD%7wBERROR%5wPIXELS%3wCNT/PIX%4wERR/PIX%4w")
	else
	    call printf("REG%3wCOUNTS%5wERROR%6wBKGD%7wPIXELS%3wCNT/PIX%4wERR/PIX%4w")

	# Turn to the first note structure (if any)
	note = notes

	if( notes != NULL )  {
	    # If annulus/annuli in descriptor, add headings for profile & radii
	    if( and(nflag, ANNFLAG) == ANNFLAG )
		call printf("PROFILE%4wRAD1%7wRAD2%7w")

	    # If pie/pies in descriptor, add headings for angles
	    if( and(nflag, PIEFLAG) == PIEFLAG )
		call printf("ANG1%7wANG2%7w")

	    # Skip notes for regions before region minindex
	    for (i = 1;  i < minindex;  i = i + 1)  {
		note = ORN_NEXT(note)
		if (note == NULL)
		    break
	    }
	}

	call printf("\n")

	# Display each set of counts, brightness, error, etc.
	do i=1, indices{
	    if( doberr == YES )
	        call printf(
		"%-4d%2w%-9.2f%2w%-9.4f%2w%-9.2f%2w%-9.4f%2w%-7d%2w%-9.4f%2w%-9.4f")
	    else
	        call printf(
		"%-4d%2w%-9.2f%2w%-9.4f%2w%-9.2f%2w%-7d%2w%-9.4f%2w%-9.4f")
	    call pargi(minindex - 1 + i)
	    call pargd(counts[i])
	    call pargd(errors[i])
	    call pargd(bncounts[i])
	    if( doberr == YES )
		call pargd(bnerrors[i])
	    call pargl(int(area[i]))
	    call pargd(brightness[i])
	    call pargd(errness[i])

	    if( note != NULL )  {
		# If annulus/annuli in descriptor, display profile datum 
		#  and inner radius and outer radius
		if( and(nflag, ANNFLAG) == ANNFLAG )  {
		    call printf("%2w%-9.4f%2w%-9.2f%2w%-9.2f")
		    call pargd(profile[i])
		    call pargr(ORN_BEGANN(note))
		    call pargr(ORN_ENDANN(note))
		}
		# If pie/pies in descriptor, display beginning angle & 
		#  ending angle
		if( and(nflag, PIEFLAG) == PIEFLAG )  {
		    call printf("%2w%-9.2f%2w%-9.2f")
		    call pargr(ORN_BEGPIE(note))
		    call pargr(ORN_ENDPIE(note))
		}
		# Advance to the next note structure
		note = ORN_NEXT(note)
	    }
	    call printf("\n")
	}
end

#
# CNT_FILLTABLE -- fill table file with results
#
procedure cnt_filltable(scounts, bcounts, bscounts, bsarea, bserrors,
		bncounts, bnerrors, brightness, errness, profile, notes,
		smin, sindices, nflag, doberr, tp, cp)

double	scounts[ARB]		# i: counts in source
double	bcounts[ARB]		# i: counts in bkgd
double	bscounts[ARB]		# i: counts in bkgd-subtracted source
double	bsarea[ARB]		# i: area in bkgd-subtracted source
double	bserrors[ARB]		# i: error on bscounts
double	bncounts[ARB]		# i: counts in normalized bgd
double	bnerrors[ARB]		# i: error on bncounts
double	brightness[ARB]		# i: counts/pixel
double	errness[ARB]		# i: err/pixel
double	profile[ARB]		# i: profile
pointer	notes			# i: pointer to linked list of notes
int	smin			# i: minimum source region number
int	sindices		# i: total indices for source regions
int	nflag			# i: 0: no pie, no annulus in descriptor tree;
				#    PIEFLAG: pie, no annulus in descriptor;
				#    ANNFLAG: annulus, no pie in descriptor;
				#    or(PIEFLAG,ANNFLAG): both pie & annulus 
				#    	in descriptor tree
int	doberr			# i: add bkgd to error calculation?
pointer tp			# i: table pointer
pointer	cp[ARB]			# i: column pointers

pointer	note			# l: pointer to current note structure
int	i			# l: loop counters, temp index

begin
	# Turn to the first note structure (if any)
	note = notes

	if( notes != NULL )  {
	    # Skip notes for regions before region smin
	    for (i = 1;  i < smin;  i = i + 1)  {
		note = ORN_NEXT(note)
		if (note == NULL)
		    break
	    }
	}

	# Loop through all the regions
	for(i=1; i<=sindices; i=i+1){
	    call tbrpti(tp, REGIONS_CP[cp], smin-1+i, 1, i)
	    call tbrptr(tp, SIGNAL_CP[cp], real(scounts[i]), 1, i)
	    call tbrpti(tp, PIXELS_CP[cp], int(bsarea[i]), 1, i)
	    call tbrptr(tp, BKGD_CP[cp], real(bncounts[i]), 1, i)
	    if( doberr == YES )
		call tbrptr(tp, BERROR_CP[cp], real(bnerrors[i]), 1, i)
	    call tbrptr(tp, SOURCE_CP[cp], real(bscounts[i]), 1, i)
	    call tbrptr(tp, ERROR_CP[cp], real(bserrors[i]), 1, i)
	    call tbrptr(tp, CTSPIXEL_CP[cp], real(brightness[i]), 1, i)
	    call tbrptr(tp, ERRPIXEL_CP[cp], real(errness[i]), 1, i)

	    if( note != NULL )  {
		# If annulus/annuli in descriptor, put profile datum 
		#  and inner radius and outer radius in table
		if( and(nflag, ANNFLAG) == ANNFLAG )  {
		    call tbrptr(tp, PROFILE_CP[cp], real(profile[i]), 1, i)
	            call tbrptr(tp, RAD1_CP[cp], ORN_BEGANN(note), 1, i)
	            call tbrptr(tp, RAD2_CP[cp], ORN_ENDANN(note), 1, i)
		}
		# If pie/pies in descriptor, put beginning angle and 
		#  ending angle in table
		if( and(nflag, PIEFLAG) == PIEFLAG )  {
	            call tbrptr(tp, ANG1_CP[cp], ORN_BEGPIE(note), 1, i)
	            call tbrptr(tp, ANG2_CP[cp], ORN_ENDPIE(note), 1, i)
		}
		call tbrptt(tp, NSTRING_CP[cp], ORN_DESCBUF(note), 
							SZ_ONEREGDESC, 1, i)
		# Advance to the next note structure
		note = ORN_NEXT(note)
	    }
	}
end

#
# CNT_BRIGHTNESS -- calculate cnt/pixel
#
procedure cnt_brightness(counts, error, area, brightness, errness, indices)

double	counts[ARB]		# i: buffer for counts
double	error[ARB]		# i: buffer for error on counts
double	area[ARB]		# i: buffer for area
double	brightness[ARB]		# i: cnts/pixel
double	errness[ARB]		# i: err/pixel
int	indices			# i: number of separate regions
int	i			# l: loop counter

begin
	for(i=1; i<=indices; i=i+1){
	    if ( area[i] == 0 ) next;

	    brightness[i] = counts[i]/area[i]
	    errness[i] = error[i]/area[i]
	}
end

#
# CNT_NORM -- create the final norm factor from the user norm and
#		the time norm
#
procedure cnt_norm(sim, bim, tp, normfactor, type, dotimenorm, dotable)

long	sim				# i: source image handle
long	bim				# i: bkgd image handle
pointer tp				# i: table pointer
double	normfactor			# i/o: constant normalization factor
int	type				# i: type of source/bkgd relation
int	dotimenorm			# i: add time normalization
int	dotable				# i: output to table?

pointer	shead				# l: source header
pointer	bhead				# l: bkgd header
double	slive				# l: source live time
double	blive				# l: bkgd live time
double	tnorm				# l: time normalization
double	unorm				# l: copy of input user norm

int	is_imhead()			# l: check for xray imheader

begin
	# init time normalization factor and save initial normalization
	tnorm = 1.0D0
	unorm = normfactor
	# init STDOUT display
	call printf("\n")

	# see if we are doing time normalization
	if( dotimenorm == NO )
	    goto 99

	# get source and bkgd live times
	if( type == CONSTANT_BKGD )
	    call printf("no bkgd file - using 1.0 for time norm factor\n")
	else{
	    # try to get xray header
	    if( (is_imhead(sim) == YES)
	     && (is_imhead(bim) == YES ) ){
		call get_imhead(sim, shead)
		call get_imhead(bim, bhead)
		slive = QP_EXPTIME(shead) 
		if( slive < 0.0D0 ){
		    slive = QP_ONTIME(shead)
		    call printf("Using dynamic EXPTIME for source: %.2f\n")
			call pargd(slive)
		}
		else{
		    call printf("Using static EXPTIME for source: %.2f\n")
			call pargd(slive)
		}
		slive = slive * QP_DEADTC(shead)
		blive = QP_EXPTIME(bhead) 
		if( blive < 0.0D0 ){
		    blive = QP_ONTIME(shead)
		    call printf("Using dynamic EXPTIME for bkgd: %.2f\n")
			call pargd(blive)
		}
		else{
		    call printf("Using static EXPTIME for bkgd: %.2f\n")
			call pargd(blive)
		}
		blive = blive * QP_DEADTC(bhead)
		# display live times
#		call printf("source live time: %.2f\n")
#	        call pargd(slive)
#		call printf("bkgd live time: %.2f\n")
#	        call pargd(blive)
		if( (slive <=EPSILOND) || (blive<= EPSILOND) ){
		    call printf("bad live time - using 1.0 for time norm factor\n")
		    tnorm = 1.0D0
		}
		else
		    # calc final normalization factor
		    tnorm = slive / blive
		# free up space
		call mfree(shead, TY_STRUCT)
		call mfree(bhead, TY_STRUCT)
	    }
	    else{
		call printf("no live time available - using 1.0 for time norm factor\n")
		tnorm = 1.0D0
	    }
	}

	# display original user normalization factor
99	call printf("user normalization: %.2f\n")
	call pargd(unorm)
	# display the time normalization
	call printf("time normalization: %.2f\n")
	call pargd(tnorm)
	# calculate final normalization factor
	normfactor = unorm * tnorm
	# display final norm factor
	call printf("final normalization: %.2f\n")
	    call pargd(normfactor)
	# write the time normalization to the table
	if( dotable == YES ){
	    call tbhadr(tp, "u_norm", real(unorm))
            call tbhadr(tp, "t_norm", real(tnorm))
            call tbhadr(tp, "norm", real(normfactor))
	}
end

#
# CNT_PROFILE -- calculate profile for radial regions
# we do a separate profile for each set of equal angles
# so that combining pies and annuli gets several meaningful profiles
#
procedure cnt_profile(counts, profile, minindex, indices, notes, nflag)

double	counts[ARB]		# i: buffer for counts
double	profile[ARB]		# i: profile array
int	minindex		# i: minimum region number
int	indices			# i: number of separate regions
pointer	notes			# i: pointer to linked list of notes
int	nflag			# i: 0: no pie, no annulus in descriptor tree;
				#    PIEFLAG: pie, no annulus in descriptor;
				#    ANNFLAG: annulus, no pie in descriptor;
				#    or(PIEFLAG,ANNFLAG): both pie & annulus 
				#    	in descriptor tree

pointer	note			# l: pointer to current note structure
int	i			# l: counts notes for regions before minindex
int	cur			# l: base offset for this batch of profiles
int	n			# l: number of profiles in this batch
real	profbegpie		# l: beginning angle for a single profile

begin
	# If no notes, or no annulus/annuli in descriptor, return
	if( (notes == NULL) || (and(nflag, ANNFLAG) != ANNFLAG) )
	    return

	# Turn to the first note structure
	note = notes

	# Skip notes for regions before region minindex
	for (i = 1;  i < minindex;  i = i + 1)  {
	    note = ORN_NEXT(note)
	    if (note == NULL)
		return
	}

	# Set starting index (into profile[]) for first profile
	cur = 1

	# Repeatedly, do a profile
	while( (note != NULL) && (cur <= indices) )  {

	    # Get angle defining this profile
	    profbegpie = ORN_BEGPIE(note)

	    # Initialize number of regions in this profile
	    n = 1

	    # Look at the next note structure
	    note = ORN_NEXT(note)

	    # Add each successive region that begins at the same angle 
	    #  (which may be 0, if no pie slice) to this profile
	    while( (note != NULL) && ((cur+n) <= indices) )  {
		if( ORN_BEGPIE(note) == profbegpie )  {
		    n=n+1
		    # Move to the next note structure
		    note = ORN_NEXT(note)
		} else 
		    break
	    }

	    # Do the profile
	    call cnt_prof1(counts[cur], profile[cur], n)

	    # Set starting index (into profile[]) for next profile
	    cur = cur + n
	}
end

#
#  CNT_PROF1 -- get profile for 1 batch of radials
#  (having a constant angle)
#
procedure cnt_prof1(counts, profile, n)

double	counts[ARB]		# i: buffer for counts
double	profile[ARB]		# i: profile array
int	n			# i: number of regions in this profile
		
int	i			# l: loop counter
double	total			# l: total counts
double	partial			# l: integrated counts

begin
	# first get the total counts
	total = 0.0D0
	for(i=1; i<=n; i=i+1)
	    total = total + counts[i]
	# make sure there are counts
	if( total < EPSILON ){
	    call printf("\nwarning: no counts for profile\n")
	    return
	}
	# for each bin, get integrated total
	partial = 0.0D0
	for(i=1; i<=n; i=i+1){
	    profile[i] = (partial+counts[i])/total
	    partial = partial+counts[i]
	}
end

#
#  CNT_ZEROAREA -- check for zero area
#
procedure cnt_zeroarea(name, area, indices)

char	name[ARB]				# i: source or bkgd
double	area[ARB]				# i: area array
int	indices					# i: number of areas
int	i					# l: loop counter

begin
	# look for at least one non-zero area
	do i=1, indices{
	    if( area[i] > 0.0 )
		return
	}
	# no area found!
	call errstr(1, "zero area found", name)
end
