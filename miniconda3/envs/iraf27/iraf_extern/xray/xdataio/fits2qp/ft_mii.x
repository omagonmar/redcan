#$Header: /home/pros/xray/xdataio/fits2qp/RCS/ft_mii.x,v 11.1 2001/03/26 20:20:29 prosb Exp $
#$Log: ft_mii.x,v $
#Revision 11.1  2001/03/26 20:20:29  prosb
#Modified code from STScI (Phil Hodges) to handle double precision correctly
#
#Revision 9.0  1995/11/16  18:59:15  prosb
#General Release 2.4
#
#Revision 1.2  1995/02/16  21:21:14  prosb
#Modified FITS2QP to correctly apply TSCAL/TZERO on extensions with
#columns which contain an array of values.  Also modified FITS2QP to
#not be so picky as to force the final index number to match the number
#of fields in an extension.  (I.e., if an extension has 8 columns, and
#TFIELD is set to 8, we can have "TUNIT5" as the final header card.)
#
#Revision 1.1  94/09/16  16:45:40  dvs
#Initial revision
#
#
# Module:	ft_mii.x
# Project:	PROS -- ROSAT RSDC
# Purpose:	
# Description:	< opt, if sophisticated family>
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989.  You may do anything you like with this
#		file except remove this copyright
# Modified:	
#		{n} <who> -- <does what> -- <when>
#
include <mach.h>
include <mii.h>
include <ctype.h>
include "fits2qp.h"

###
#  MII_SCALE_UNPACK - Unpack from mii (FITS) structure to PROS buffer.
#		      Also performs scaling, if needed.
#
###
procedure mii_scale_unpack(ibuf, obuf, nrecs, typedef, ext, scale)

pointer ibuf               # i: pointer to input buffer [TY_SHORT]
pointer obuf               # o: pointer to output buffer [TY_SHORT]
int     nrecs              # i: number of records
char    typedef[ARB]       # i: typedef definition
pointer ext		   # i: extension structure
bool	scale		   # i: apply TZERO/TSCAL scaling?

int     i, j                    # l: loop counters
int     ioffset                 # l: current offset in ibuf - in bytes
int     ooffset                 # l: current offset in obuf - in bytes

char    otype                   # output type
int     otypesize               # (in bytes)

int     omaxsize	   # maximum size of type in output buffer

int     colindex  	   # which column are we working on?
int     extindex  	   # which extension is this column in?
			   # (differs from colindex when using arrays.)
char    conv_type()
int     byte_size()
int	find_extindex()

begin
        ioffset = 0
        ooffset = 0

        omaxsize = SZ_INT*SZB_CHAR

        # for each record in the array of records
        do i=1, nrecs{

            colindex=1   
            j = 1  # index into typedef
            # convert each element of the typedef descriptor

            while( typedef[j] != EOS ){
                switch(typedef[j]){
                case '{', '}', ',', ' ':
                    ;
                case ':':
                  repeat{
                    j = j + 1
                  }until( !IS_ALNUM(typedef[j]) && (typedef[j] != '_'))

                case 't','s','i','l','r','d','x':

		    # find correct index into ext array (due to repcnts)
		    extindex = find_extindex(ext,colindex)

		    # find output type                
                    otype=conv_type(EXT(ext,extindex),typedef[j],scale)

                    # make sure output buffer is aligned properly
                    otypesize = byte_size(otype)

                    if (mod(ooffset,otypesize)!=0)
                       ooffset=ooffset+otypesize-mod(ooffset,otypesize)

		    # move data
                    call mii_mv_data(ibuf,ioffset,typedef[j],obuf,ooffset,otype,
                                        EXT(ext,extindex), scale)

		    # increment offsets
                    ooffset = ooffset + otypesize
                    ioffset = ioffset + byte_size(typedef[j])
                    colindex=colindex+1

                    omaxsize=max(omaxsize,otypesize)
                    
                default:
                    call errstr(1, "miitypedef - illegal character in eventdef",
                                    typedef)
                }
                j = j + 1
            }

            # increment ooffset for final record bounds
            if (mod(ooffset,omaxsize)!=0)
                       ooffset=ooffset+omaxsize-mod(ooffset,omaxsize)

        }
end

###
# CONV_TYPE - converts input type (itype) into new type -- might
#             need promotion if there is scaling involved.
###

char procedure conv_type(ext,itype,scale)
pointer ext     	# i: pointer to extension record
char    itype   	# i: input type
bool	scale		# i: scale (apply scaling?)

char    otype   # [returns] output type

bool	is_scale()
bool	is_both_scale()
begin
        # only promote types if we're not keying on main index keys
	if (EXT_IS_EV_INDEX(ext)==YES)
	{
	   otype=itype  
	}
	else switch(itype)
        {
           case 's','t':

                # switch to 'l' if one of zero/scale is nontrivial.
                # switch to 'r' if both are nontrivial.
                if (is_both_scale(ext,scale))
                   otype='r'
                else if (is_scale(ext,scale))
                   otype='i'
                else
                   otype='s'

           case 'i','l':
                if (is_scale(ext,scale))	# changed from is_both_scale
                   otype='d'			# changed from 'r', 2000/09/13
                else
                   otype=itype

           case 'r','d','x':
              otype=itype

           default:
              call error(1, "unknown data type")
        }
        

        return otype
end

###
# MII_MV_DATA - Move data from input to output buffer, unpacking and
#		scaling as necessary.
###

procedure mii_mv_data(ibuf,ioffset,itype,obuf,ooffset,otype,ext,scale)
pointer ibuf            # i: input ptr to shorts
int     ioffset         # i: offset in bytes
char    itype		# i: input type
pointer obuf		# io: output buffer (ptr to shorts)
int     ooffset         # i: output offset (in bytes)
char    otype           # i: output type
pointer ext		# i: extension buffer
bool	scale		# i: does user mind scaling?

short   temp[8]         # l: temp to hold up to 8 shorts worth.
real    rtemp
double  dtemp
int     itemp
long    ltemp
short   stemp
complex xtemp

equivalence (rtemp,dtemp,itemp,ltemp,stemp,xtemp)

int     byte_size()
bool	is_scale()

begin
	# Fill temp buffer with input data.  
        call bytmov (Mems[ibuf], ioffset+1, temp, 1, byte_size(itype))

        # apply scaling, if needed.
        if (is_scale(ext,scale))
        {
            # unpack into temporary buffer...
            call mii_upkg(temp,xtemp,itype)

            # ...apply scaling...
            switch (itype)
            {
                case 's','t':
                   rtemp=stemp*EXT_SCALE(ext)+EXT_ZERO(ext)
                
                   if (otype=='i')
                   {
                      itemp=nint(rtemp)
                   }

                   if (otype=='s')
                   {
                      stemp=nint(rtemp)
                   }

                case 'i':
                   dtemp=double(itemp)*EXT_SCALE(ext)+EXT_ZERO(ext) # 2000/09/13

                   if (otype=='i')
                   {
                      itemp=nint(dtemp)				# 2000/09/13
                   }

                case 'l':
                   dtemp=double(ltemp)*EXT_SCALE(ext)+EXT_ZERO(ext) # 2000/09/13

                   if (otype=='l')
                   {
                      ltemp=nint(dtemp)				# 2000/09/13
                   }

                case 'r':
                   rtemp=rtemp*EXT_SCALE(ext)+EXT_ZERO(ext)

                case 'd':
                   dtemp=dtemp*EXT_SCALE(ext)+EXT_ZERO(ext)

                case 'x':
                   xtemp=xtemp*EXT_SCALE(ext)+EXT_ZERO(ext)

                default:
                   call error(1, "unknown data type")
            }

            # ...then write out to output buffer!
            call bytmov (xtemp, 1, Mems[obuf], ooffset+1, byte_size(otype))
        }
        else
        {
           # just unpack into the output buffer!           
           call mii_upkg(temp, Mems[obuf+ooffset/(SZ_SHORT*SZB_CHAR)], itype)
        }
end

###
# MII_UPKG -- generic unpacking
###

procedure mii_upkg(ibuf,obuf,type)
short   ibuf[8]
short   obuf[8]
char    type

begin

        switch (type)
        {
            case 't':
                call miiupk8(ibuf, obuf, 1, TY_SHORT)
            case 's':
                call miiupk16(ibuf, obuf, 1, TY_SHORT)
            case 'i':
                call miiupk32(ibuf, obuf, 1, TY_INT)
            case 'l':
                call miiupk32(ibuf, obuf, 1, TY_LONG)
            case 'r':
                call miiupkr(ibuf, obuf, 1, TY_REAL)
            case 'd':
                call miiupkd(ibuf, obuf, 1, TY_DOUBLE)
            case 'x':
                call miiupkr(ibuf, obuf, 1, TY_REAL)
                call miiupkr(ibuf[SZ_REAL/SZ_SHORT+1],
                             obuf[SZ_REAL/SZ_SHORT+1], 1, TY_REAL) 
            default:
                call error(1, "unknown data type")
        }

end

# Finds the extension index within the EXT corresponding to the
# passed in column.
#
# For instance, if EXT_REPCNT contains:
#
#      1 1 1 10 1 1 8
#
# then column 1 is in extension 1,
#      column 4 is in extension 4,
#      column 5 is in extension 4,
#      column 13 is in extension 4,
#      column 14 is in extension 5,
#      column 18 is in extension 7.

int procedure find_extindex(ext,colindex)
pointer ext
int	colindex

int extindex    # l:
int curcol	# l:

begin

	# set curcol to end of first extension
	extindex=1
	curcol=EXT_REPCNT(EXT(ext,extindex))

	while (curcol<colindex )
	{
	   extindex = extindex+1
	   curcol = curcol+EXT_REPCNT(EXT(ext,extindex))
	}

	return extindex
end

bool procedure is_scale(ext,scale)
pointer	ext
bool scale  # does user want us to apply scaling?
begin
	return (scale && (EXT_SCALE(ext)!=1.0d0 || EXT_ZERO(ext)!=0.0d0))
end

bool procedure is_both_scale(ext,scale)
pointer	ext
bool	scale # does user want us to apply scaling?
begin
	return (scale && EXT_SCALE(ext)!=1.0d0 && EXT_ZERO(ext)!=0.0d0)
end
