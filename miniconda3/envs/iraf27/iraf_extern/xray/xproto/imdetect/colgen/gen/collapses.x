#------------------------------------------------------------------------
# COLLAPSE -> horizontally sum an input line over the summing interval
#------------------------------------------------------------------------

procedure collapses(inbuf, xbuf, outbuf, factor, pixels, smooth)

# Input/Ouput Variables

short inbuf[ARB]			# input line for summing
real  outbuf[ARB]			# output horizontally summed line
short xbuf[ARB]

int  pixels				# number of pixels
int  factor
int  smooth

# Local Variables

int  i, j, k				# array pointers
int	first

begin

 	call aclrs(xbuf,pixels)
# 	call aclr$t(outbuf,pixels)
 	call aclrr(outbuf,pixels)

	j = 1
#        pixels = factor*resolution

# Scan line over each summing interval

	if( factor == 1)
	    call amovs(inbuf,xbuf,pixels)
	else
	{
	    for (i=1; i<=pixels; i=i+1)
	    {
	        xbuf[j] = xbuf[j] + inbuf[i]

                if ( mod(i,factor) == 0 )
	            j = j + 1
	     }
	 }
	 first = smooth / 2
	 for (i=1+first; i<=pixels/factor-first; i=i+1)
	 {
	    do k=1,smooth
		outbuf[i] = outbuf[i] + xbuf[i-first+k-1]
	}
	
end
